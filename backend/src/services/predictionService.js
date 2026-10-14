/*
 * Client for the Python prediction service (ml_service/).
 *
 * The backend is the only thing that talks to it: the apps call the backend,
 * which validates the user, forwards the inputs, and stores the result. Its
 * address comes from ML_SERVICE_URL and defaults to the local service.
 */

const DEFAULT_URL = "http://127.0.0.1:8000";
const TIMEOUT_MS = 15000;

class PredictionServiceError extends Error {
  constructor(status, message) {
    super(message);
    this.name = "PredictionServiceError";
    this.status = status;
  }
}

const baseUrl = () => (process.env.ML_SERVICE_URL || DEFAULT_URL).replace(/\/+$/, "");

async function request(path, options = {}) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);

  let response;
  try {
    response = await fetch(baseUrl() + path, {
      ...options,
      headers: { "Content-Type": "application/json", ...(options.headers || {}) },
      signal: controller.signal,
    });
  } catch (error) {
    // Connection refused or timed out: the service is not running
    throw new PredictionServiceError(
      503,
      "The prediction service is not available. Start ml_service and try again.",
    );
  } finally {
    clearTimeout(timer);
  }

  let body = null;
  try {
    body = await response.json();
  } catch {
    body = null;
  }

  if (!response.ok) {
    // 422 from the service is a problem with the submitted values: pass its
    // message through, it names the field. Anything else is our fault.
    const status = response.status === 422 ? 400 : response.status === 404 ? 404 : 502;
    throw new PredictionServiceError(
      status,
      (body && body.message) || "The prediction service returned an error.",
    );
  }

  return body;
}

// Form definitions for every disease: fields, units, ranges, options, metrics
async function listModels() {
  const body = await request("/models");
  return body.data;
}

// Run one prediction; inputs are the field values keyed by field name
async function predict(key, inputs) {
  return request(`/predict/${encodeURIComponent(key)}`, {
    method: "POST",
    body: JSON.stringify({ inputs }),
  });
}

module.exports = { listModels, predict, PredictionServiceError };
