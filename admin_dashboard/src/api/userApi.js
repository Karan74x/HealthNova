import axiosInstance from "./axiosInstance";

/*
 * GET /api/user/profile
 * Requires a token. Returns { message, user } where user is the decoded JWT
 * payload - { userId, role, iat, exp } - and not the stored user document.
 * The profile page uses it for the session expiry; account details come from
 * GET /api/user/me below.
 */
export function getProfile() {
  return axiosInstance.get("/user/profile");
}

/*
 * GET /api/user/me
 * The signed-in user's own account record (name, email, phone, gender, dob,
 * role). Unlike /user/profile this is the stored document, not the token.
 */
export function getMe() {
  return axiosInstance.get("/user/me");
}

/*
 * PUT /api/user/me
 * Update the signed-in user's own name, phone, gender or date of birth.
 * Email, password and role cannot be changed here.
 */
export function updateMe(payload) {
  return axiosInstance.put("/user/me", payload);
}
