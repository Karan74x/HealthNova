import axiosInstance from "./axiosInstance";

/*
 * POST /api/auth/login
 * Body:    { email, password }
 * Success: 200 { message, token, user: { _id, phone, email, role } }
 * Failure: 400 { message } - note the backend uses 400, not 401, for bad
 *          credentials, so callers must not treat this as a session expiry.
 */
export function login(email, password) {
  return axiosInstance.post("/auth/login", { email, password });
}
