const TOKEN_KEY = "healthnova_token";
const USER_KEY = "healthnova_user";

export function getToken() {
  return localStorage.getItem(TOKEN_KEY);
}

export function getStoredUser() {
  const raw = localStorage.getItem(USER_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

export function saveSession(token, user) {
  localStorage.setItem(TOKEN_KEY, token);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function clearSession() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

/*
 * Reads the payload of a JWT without verifying it. Verification is the
 * backend's job - this only lets the UI drop an obviously expired token
 * instead of firing a request that is certain to 401.
 */
export function decodeToken(token) {
  try {
    const payload = token.split(".")[1];
    const base64 = payload.replace(/-/g, "+").replace(/_/g, "/");
    return JSON.parse(atob(base64));
  } catch {
    return null;
  }
}

export function isTokenExpired(token) {
  const payload = decodeToken(token);
  if (!payload?.exp) return false;
  return payload.exp * 1000 <= Date.now();
}
