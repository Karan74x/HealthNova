import axiosInstance from "./axiosInstance";

/*
 * GET /api/user/profile
 * Requires a token. Returns { message, user } where user is the decoded JWT
 * payload - { userId, role, iat, exp } - and not the stored user document.
 * Email and phone are therefore taken from the login response instead.
 */
export function getProfile() {
  return axiosInstance.get("/user/profile");
}

/*
 * GET /api/admin/dashboard
 * Requires a token and role "admin". Returns { message: "Welcome Admin" }.
 * There is no data payload yet, so this serves as a live check that the
 * role gate accepts the signed-in user.
 */
export function getAdminDashboard() {
  return axiosInstance.get("/admin/dashboard");
}
