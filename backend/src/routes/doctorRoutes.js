const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const roleMiddleware = require("../middleware/roleMiddleware");
const doctor = require("../controllers/doctorControllers");

const router = express.Router();

// Every route below is for doctors only
router.use(authMiddleware, roleMiddleware("doctor"));

// Kept from the original implementation: the dashboard uses it to confirm the
// token is valid and the doctor role gate accepts the account.
router.get("/dashboard", (req, res) => {
  res.status(200).json({
    message: "Welcome Doctor",
    user: req.user,
  });
});

//overview counts for the signed-in doctor
router.get("/stats", doctor.getStats);

//the doctor's own profile
router.get("/profile", doctor.getMyProfile);
router.put("/profile", doctor.updateMyProfile);

//the doctor's own appointments
router.get("/appointments", doctor.listMyAppointments);
router.get("/appointments/:id", doctor.getMyAppointment);
router.patch("/appointments/:id/status", doctor.updateMyAppointmentStatus);

//a patient the doctor has an appointment with
router.get("/patients/:id", doctor.getPatient);

module.exports = router;
