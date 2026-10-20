import axiosInstance from "./axiosInstance";

/*
 * Doctor endpoints. The backend resolves the doctor from the token, so none
 * of these take a doctor id - a doctor can only ever reach their own records.
 */

export function getStats() {
  return axiosInstance.get("/doctor/stats");
}

export function getMyProfile() {
  return axiosInstance.get("/doctor/profile");
}

export function updateMyProfile(payload) {
  return axiosInstance.put("/doctor/profile", payload);
}

export function listAppointments(status) {
  return axiosInstance.get("/doctor/appointments", { params: status ? { status } : {} });
}

export function getAppointment(id) {
  return axiosInstance.get(`/doctor/appointments/${id}`);
}

export function setAppointmentStatus(id, status) {
  return axiosInstance.patch(`/doctor/appointments/${id}/status`, { status });
}

export function getPatient(id) {
  return axiosInstance.get(`/doctor/patients/${id}`);
}
