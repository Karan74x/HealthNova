const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const roleMiddleware = require("../middleware/roleMiddleware");
const admin = require("../controllers/adminControllers");

const router = express.Router();

// Every route below is for administrators only
router.use(authMiddleware, roleMiddleware("admin"));

// Kept from the original implementation: the dashboard uses it to confirm the
// token is valid and the admin role gate accepts the account.
router.get("/dashboard", (req, res) => {
  res.status(200).json({
    message: "Welcome Admin",
  });
});

//overview counts
router.get("/stats", admin.getStats);

//doctors
router.get("/doctors", admin.listDoctors);
router.post("/doctors", admin.createDoctor);
router.get("/doctors/:id", admin.getDoctor);
router.put("/doctors/:id", admin.updateDoctor);
router.delete("/doctors/:id", admin.deleteDoctor);

//patients
router.get("/patients", admin.listPatients);
router.delete("/patients/:id", admin.deletePatient);

//appointments
router.get("/appointments", admin.listAppointments);
router.patch("/appointments/:id/status", admin.updateAppointmentStatus);
router.delete("/appointments/:id", admin.deleteAppointment);

//prediction history, read-only
router.get("/predictions", admin.listPredictions);

module.exports = router;
