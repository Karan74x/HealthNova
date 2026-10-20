const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const roleMiddleware = require("../middleware/roleMiddleware");
const patient = require("../controllers/patientControllers");

const router = express.Router();

// Every route below is for patients only
router.use(authMiddleware, roleMiddleware("patient"));

// Kept from the original implementation
router.get("/dashboard", (req, res) => {
  res.status(200).json({
    message: "Welcome Patient",
    user: req.user,
  });
});

//browse doctors
router.get("/doctors", patient.listDoctors);
router.get("/doctors/:id", patient.getDoctor);

//appointments belonging to the signed-in patient
router.post("/appointments", patient.bookAppointment);
router.get("/appointments", patient.listMyAppointments);
router.delete("/appointments/:id", patient.cancelMyAppointment);

//disease-risk prediction: the forms, running one, and the patient's history
router.get("/prediction-models", patient.listPredictionModels);
router.post("/predictions", patient.createPrediction);
router.get("/predictions", patient.listMyPredictions);

module.exports = router;
