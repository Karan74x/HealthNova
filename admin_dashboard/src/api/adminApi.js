import axiosInstance from "./axiosInstance";

/*
 * Administrator endpoints. Every one requires a token and the admin role;
 * the backend answers 403 to anything else.
 */

export function getStats() {
  return axiosInstance.get("/admin/stats");
}

// ------------------------------------------------------------------ doctors
export function listDoctors(search) {
  return axiosInstance.get("/admin/doctors", { params: search ? { search } : {} });
}

export function createDoctor(payload) {
  return axiosInstance.post("/admin/doctors", payload);
}

export function updateDoctor(id, payload) {
  return axiosInstance.put(`/admin/doctors/${id}`, payload);
}

export function deleteDoctor(id) {
  return axiosInstance.delete(`/admin/doctors/${id}`);
}

// ----------------------------------------------------------------- patients
export function listPatients(search) {
  return axiosInstance.get("/admin/patients", { params: search ? { search } : {} });
}

export function deletePatient(id) {
  return axiosInstance.delete(`/admin/patients/${id}`);
}

// ------------------------------------------------------------- appointments
export function listAppointments(status) {
  return axiosInstance.get("/admin/appointments", { params: status ? { status } : {} });
}

export function setAppointmentStatus(id, status) {
  return axiosInstance.patch(`/admin/appointments/${id}/status`, { status });
}

export function deleteAppointment(id) {
  return axiosInstance.delete(`/admin/appointments/${id}`);
}

// -------------------------------------------------------------- predictions
export function listPredictions(patient) {
  return axiosInstance.get("/admin/predictions", { params: patient ? { patient } : {} });
}
