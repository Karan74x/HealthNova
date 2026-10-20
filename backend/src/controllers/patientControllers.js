const mongoose = require("mongoose");

const userModel = require("../models/userModel.js");
const doctorModel = require("../models/doctorModel.js");
const appointmentModel = require("../models/appointmentModel.js");
const predictionModel = require("../models/predictionModel.js");
const predictionService = require("../services/predictionService.js");

const { DISEASE_KEYS } = predictionModel;

const USER_FIELDS = "name email phone gender dob role createdAt";
const DOCTOR_PUBLIC_FIELDS = "specialization qualification experience hospital fee availability";

const isValidId = (id) => mongoose.Types.ObjectId.isValid(id);

// Search text is matched literally: characters such as "(" or "*" must not be
// interpreted as a regular expression.
const literal = (text) => new RegExp(text.trim().replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "i");

//browse doctors
const listDoctors = async (req, res) => {
  try {
    const { search, specialization } = req.query;

    const filter = {};
    if (specialization) {
      filter.specialization = literal(specialization);
    }
    if (search) {
      const pattern = literal(search);
      // A doctor's name lives on their user account, so matching names first
      const named = await userModel.find({ role: "doctor", name: pattern }).select("_id");
      filter.$or = [
        { specialization: pattern },
        { hospital: pattern },
        { user: { $in: named.map((user) => user._id) } },
      ];
    }

    const doctors = await doctorModel
      .find(filter)
      .select(DOCTOR_PUBLIC_FIELDS + " user")
      .populate("user", "name email")
      .sort({ specialization: 1 });

    res.status(200).json({ message: "Doctors loaded", data: doctors });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//one doctor's public details
const getDoctor = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) {
      return res.status(404).json({ message: "Doctor not found" });
    }

    const doctor = await doctorModel
      .findById(req.params.id)
      .select(DOCTOR_PUBLIC_FIELDS + " user")
      .populate("user", "name email");

    if (!doctor) {
      return res.status(404).json({ message: "Doctor not found" });
    }

    res.status(200).json({ message: "Doctor loaded", data: doctor });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//book an appointment
const bookAppointment = async (req, res) => {
  try {
    const { doctor, date, time, reason } = req.body;

    if (!doctor || !date || !time) {
      return res.status(400).json({
        message: "Doctor, date and time are required",
      });
    }

    if (!isValidId(doctor)) {
      return res.status(404).json({ message: "Doctor not found" });
    }

    const exists = await doctorModel.exists({ _id: doctor });
    if (!exists) {
      return res.status(404).json({ message: "Doctor not found" });
    }

    // A bare calendar day ("2026-10-21") is stored at midday UTC, so it shows
    // as the same day in every timezone the apps are likely to run in.
    const when = /^\d{4}-\d{2}-\d{2}$/.test(String(date))
      ? new Date(`${date}T12:00:00Z`)
      : new Date(date);
    if (Number.isNaN(when.getTime())) {
      return res.status(400).json({ message: "Invalid appointment date" });
    }

    // Allow a day of slack for timezones; anything earlier is in the past
    if (when.getTime() < Date.now() - 24 * 60 * 60 * 1000) {
      return res.status(400).json({ message: "Appointment date cannot be in the past" });
    }

    // The patient is taken from the token, so a patient cannot book on behalf
    // of someone else by putting another id in the body.
    const appointment = await appointmentModel.create({
      patient: req.user.userId,
      doctor,
      date: when,
      time,
      reason,
      status: "Pending",
    });

    const created = await appointmentModel
      .findById(appointment._id)
      .populate({ path: "doctor", populate: { path: "user", select: "name email" } });

    res.status(201).json({ message: "Appointment booked", data: created });
  } catch (error) {
    if (error.name === "ValidationError") {
      return res.status(400).json({
        message: Object.values(error.errors)[0]?.message || error.message,
      });
    }
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//the signed-in patient's own appointments
const listMyAppointments = async (req, res) => {
  try {
    const appointments = await appointmentModel
      .find({ patient: req.user.userId })
      .populate({ path: "doctor", populate: { path: "user", select: "name email" } })
      .sort({ date: -1 });

    res.status(200).json({ message: "Appointments loaded", data: appointments });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//cancel one of the signed-in patient's own requests, while still pending
const cancelMyAppointment = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    // The patient is part of the filter, so another patient's appointment is
    // indistinguishable from one that does not exist.
    const appointment = await appointmentModel.findOne({
      _id: req.params.id,
      patient: req.user.userId,
    });

    if (!appointment) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    if (appointment.status !== "Pending") {
      return res.status(400).json({
        message: `This appointment is already ${appointment.status.toLowerCase()} and can no longer be cancelled`,
      });
    }

    await appointmentModel.findByIdAndDelete(appointment._id);

    res.status(200).json({ message: "Appointment cancelled", data: { _id: appointment._id } });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//the prediction forms: fields, units, ranges and options for each disease
const listPredictionModels = async (req, res) => {
  try {
    const models = await predictionService.listModels();
    res.status(200).json({ message: "Prediction models loaded", data: models });
  } catch (error) {
    if (error.name === "PredictionServiceError") {
      return res.status(error.status).json({ message: error.message });
    }
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

/*
 * Run a disease-risk prediction and store it.
 *
 * Body: { disease: "diabetes", inputs: { glucose: 148, ... } }
 *
 * The result comes from the prediction service, never from the client, so a
 * stored prediction is always what the model actually produced.
 */
const createPrediction = async (req, res) => {
  try {
    const { disease, inputs } = req.body;

    if (!disease || !DISEASE_KEYS[disease]) {
      return res.status(400).json({
        message: "Disease must be one of: " + Object.keys(DISEASE_KEYS).join(", "),
      });
    }

    if (!inputs || typeof inputs !== "object" || Array.isArray(inputs)) {
      return res.status(400).json({ message: "Inputs are required" });
    }

    const outcome = await predictionService.predict(disease, inputs);

    const prediction = await predictionModel.create({
      patient: req.user.userId,
      disease: DISEASE_KEYS[disease],
      inputs,
      result: outcome.result,
      riskLevel: outcome.riskLevel,
      confidence: outcome.confidence,
    });

    res.status(201).json({
      message: "Prediction complete",
      data: prediction,
      disclaimer: outcome.disclaimer,
    });
  } catch (error) {
    if (error.name === "PredictionServiceError") {
      return res.status(error.status).json({ message: error.message });
    }
    if (error.name === "ValidationError") {
      return res.status(400).json({ message: error.message });
    }
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//the signed-in patient's own prediction history
const listMyPredictions = async (req, res) => {
  try {
    const predictions = await predictionModel
      .find({ patient: req.user.userId })
      .sort({ createdAt: -1 });

    res.status(200).json({ message: "Predictions loaded", data: predictions });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

module.exports = {
  listDoctors,
  getDoctor,
  bookAppointment,
  listMyAppointments,
  cancelMyAppointment,
  listPredictionModels,
  createPrediction,
  listMyPredictions,
  USER_FIELDS,
};
