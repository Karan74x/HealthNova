import axios from "axios";
import { getToken, clearSession } from "../context/authStorage";

/*
 * Requests go to the relative path /api, which the Vite dev server proxies to
 * the backend (see vite.config.js). Because the request is same-origin from
 * the browser's point of view, the backend's missing CORS middleware does not
 * block it.
 */
const axiosInstance = axios.create({
  baseURL: "/api",
  headers: { "Content-Type": "application/json" },
});

/*
 * backend/src/middleware/authMiddleware.js reads req.headers.authorization and
 * passes it straight to jwt.verify without stripping a scheme. The token must
 * therefore be sent bare - adding the usual "Bearer " prefix returns 401.
 */
axiosInstance.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = token;
  }
  return config;
});

axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      clearSession();
      if (window.location.pathname !== "/login") {
        window.location.replace("/login?expired=1");
      }
    }
    return Promise.reject(error);
  },
);

/*
 * Turns any axios failure into a message that can be shown to the user.
 * The backend replies with { message } on handled errors and
 * { message, error } on server errors.
 */
export function getErrorMessage(error, fallback = "Something went wrong.") {
  if (error.response) {
    return error.response.data?.message || fallback;
  }
  if (error.request) {
    return "Cannot reach the HealthNova backend. Check that the server is running and that VITE_API_TARGET points at the right port.";
  }
  return fallback;
}

export default axiosInstance;
