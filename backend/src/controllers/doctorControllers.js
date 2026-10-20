const mongoose = require("mongoose");

const userModel = require("../models/userModel.js");
const doctorModel = require("../models/doctorModel.js");
const appointmentModel = require("../models/appointmentModel.js");
const predictionModel = require("../models/predictionModel.js");

const { APPOINTMENT_STATUSES } = appointmentModel;

// A doctor may only move an appointment into one of these states
const DOCTOR_STATUSES = ["Approved", "Rejected", "Completed"];

const USER_FIELDS = "name email phone gender dob role createdAt";

const isValidId = (id) => mongoose.Types.ObjectId.isValid(id);

/*
 * Resolve the Doctor profile for the signed-in account.
 *
 * The doctor is always taken from the token, never from a query parameter or
 * the body: a doctor must not be able to read another doctor's appointments by
 * passing a different id.
 */
const profileFor = (req) => doctorModel.findOne({ user: req.user.userId });

//the signed-in doctor's own profile
const getMyProfile = async (req, res) => {
  try {
    const doctor = await profileFor(req);
    if (!doctor) {
      return res.status(404).json({
        message: "This account has no doctor profile yet. Run npm run seed in the backend to add one, "
          + "or sign in with a doctor created from the admin dashboard.",
      });
    }

    const profile = await doctorModel
      .findById(doctor._id)
      .populate("user", USER_FIELDS);

    res.status(200).json({ message: "Profile loaded", data: profile });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//update the parts of the profile a doctor is allowed to change
const updateMyProfile = async (req, res) => {
  try {
    const doctor = await profileFor(req);
    if (!doctor) {
      return res.status(404).json({
        message: "This account has no doctor profile yet. Run npm run seed in the backend to add one, "
          + "or sign in with a doctor created from the admin dashboard.",
      });
    }

    // Specialisation and qualification are deliberately not editable here:
    // those are administrator-controlled credentials.
    const { experience, hospital, fee, availability } = req.body;
    const updates = { experience, hospital, fee, availability };
    Object.keys(updates).forEach((key) => {
      if (updates[key] === undefined) delete updates[key];
    });

    await doctorModel.updateOne(
      { _id: doctor._id },
      { $set: updates },
      { runValidators: true },
    );

    const { name, phone } = req.body;
    const accountUpdates = { name, phone };
    Object.keys(accountUpdates).forEach((key) => {
      if (accountUpdates[key] === undefined) delete accountUpdates[key];
    });
    if (Object.keys(accountUpdates).length > 0) {
      await userModel.updateOne(
        { _id: req.user.userId },
        { $set: accountUpdates },
        { runValidators: true },
      );
    }

    const updated = await doctorModel
      .findById(doctor._id)
      .populate("user", USER_FIELDS);

    res.status(200).json({ message: "Profile updated", data: updated });
  } catch (error) {
    if (error.name === "ValidationError") {
      return res.status(400).json({
        message: Object.values(error.errors)[0]?.message || error.message,
      });
    }
    if (error.name === "CastError") {
      return res.status(400).json({ message: `${error.path} has an invalid value` });
    }
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//counts for the doctor dashboard cards
const getStats = async (req, res) => {
  try {
    const doctor = await profileFor(req);
    if (!doctor) {
      return res.status(404).json({
        message: "This account has no doctor profile yet. Run npm run seed in the backend to add one, "
          + "or sign in with a doctor created from the admin dashboard.",
      });
    }

    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(startOfDay);
    endOfDay.setDate(endOfDay.getDate() + 1);

    const [today, pending, completed, patients] = await Promise.all([
      appointmentModel.countDocuments({
        doctor: doctor._id,
        date: { $gte: startOfDay, $lt: endOfDay },
      }),
      appointmentModel.countDocuments({ doctor: doctor._id, status: "Pending" }),
      appointmentModel.countDocuments({ doctor: doctor._id, status: "Completed" }),
      appointmentModel.distinct("patient", { doctor: doctor._id }),
    ]);

    res.status(200).json({
      message: "Statistics loaded",
      data: {
        todaysAppointments: today,
        pendingRequests: pending,
        completedVisits: completed,
        patientsSeen: patients.length,
      },
    });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//the signed-in doctor's own appointments
const listMyAppointments = async (req, res) => {
  try {
    const doctor = await profileFor(req);
    if (!doctor) {
      return res.status(404).json({
        message: "This account has no doctor profile yet. Run npm run seed in the backend to add one, "
          + "or sign in with a doctor created from the admin dashboard.",
      });
    }

    const { status } = req.query;
    if (status && !APPOINTMENT_STATUSES.includes(status)) {
      return res.status(400).json({
        message: "Status must be one of: " + APPOINTMENT_STATUSES.join(", "),
      });
    }

    const filter = { doctor: doctor._id };
    if (status) filter.status = status;

    const appointments = await appointmentModel
      .find(filter)
      .populate("patient", USER_FIELDS)
      .sort({ date: -1 });

    res.status(200).json({ message: "Appointments loaded", data: appointments });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//one appointment, only if it belongs to the signed-in doctor
const getMyAppointment = async (req, res) => {
  try {
    const doctor = await profileFor(req);
    if (!doctor || !isValidId(req.params.id)) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    // The doctor is part of the query rather than checked afterwards, so
    // another doctor's appointment is indistinguishable from one that does
    // not exist.
    const appointment = await appointmentModel
      .findOne({ _id: req.params.id, doctor: doctor._id })
      .populate("patient", USER_FIELDS);

    if (!appointment) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    res.status(200).json({ message: "Appointment loaded", data: appointment });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//accept, reject or complete one of the doctor's own appointments
const updateMyAppointmentStatus = async (req, res) => {
  try {
    const doctor = await profileFor(req);
    if (!doctor || !isValidId(req.params.id)) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    const { status } = req.body;
    if (!DOCTOR_STATUSES.includes(status)) {
      return res.status(400).json({
        message: "Status must be one of: " + DOCTOR_STATUSES.join(", "),
      });
    }

    // The doctor id is part of the filter, so this both scopes the update to
    // the doctor's own appointment and applies it in a single operation.
    const updated = await appointmentModel
      .findOneAndUpdate(
        { _id: req.params.id, doctor: doctor._id },
        { $set: { status } },
        { returnDocument: "after", runValidators: true },
      )
      .populate("patient", USER_FIELDS);

    if (!updated) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    res.status(200).json({ message: "Appointment updated", data: updated });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//details of a patient the doctor actually has an appointment with
const getPatient = async (req, res) => {
  try {
    const doctor = await profileFor(req);
    if (!doctor || !isValidId(req.params.id)) {
      return res.status(404).json({ message: "Patient not found" });
    }

    const seen = await appointmentModel.exists({
      doctor: doctor._id,
      patient: req.params.id,
    });

    if (!seen) {
      return res.status(404).json({ message: "Patient not found" });
    }

    const patient = await userModel
      .findOne({ _id: req.params.id, role: "patient" })
      .select(USER_FIELDS);

    if (!patient) {
      return res.status(404).json({ message: "Patient not found" });
    }

    // Only this doctor's visits with the patient, but the patient's whole
    // risk-check history, which is what helps during a consultation
    const [appointments, predictions] = await Promise.all([
      appointmentModel
        .find({ doctor: doctor._id, patient: patient._id })
        .sort({ date: -1 }),
      predictionModel
        .find({ patient: patient._id })
        .sort({ createdAt: -1 })
        .limit(20),
    ]);

    res.status(200).json({
      message: "Patient loaded",
      data: { patient, appointments, predictions },
    });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

module.exports = {
  getMyProfile,
  updateMyProfile,
  getStats,
  listMyAppointments,
  getMyAppointment,
  updateMyAppointmentStatus,
  getPatient,
};
