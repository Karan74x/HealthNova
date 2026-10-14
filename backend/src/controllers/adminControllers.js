const bcrypt = require("bcryptjs");
const mongoose = require("mongoose");

const userModel = require("../models/userModel.js");
const doctorModel = require("../models/doctorModel.js");
const appointmentModel = require("../models/appointmentModel.js");
const predictionModel = require("../models/predictionModel.js");

const { APPOINTMENT_STATUSES } = appointmentModel;

// Fields safe to return for a user. The password hash is never included.
const USER_FIELDS = "name email phone gender dob role createdAt";

//Reject an id that Mongo cannot cast, so a bad id gives 404 and not a 500
const isValidId = (id) => mongoose.Types.ObjectId.isValid(id);

//Emails are stored lower-case, so compare them the same way
const normaliseEmail = (email) => (typeof email === "string" ? email.trim().toLowerCase() : email);

//First readable message from a Mongoose validation or cast error
const validationMessage = (error) => {
  if (error.name === "ValidationError") {
    return Object.values(error.errors)[0]?.message || error.message;
  }
  if (error.name === "CastError") {
    return `${error.path} has an invalid value`;
  }
  return null;
};

//Build a case-insensitive search filter across a few fields
const searchFilter = (search, fields) => {
  if (!search) return {};
  // Matched literally, so "(" or "*" in a search cannot break the query
  const pattern = new RegExp(search.trim().replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "i");
  return { $or: fields.map((field) => ({ [field]: pattern })) };
};

//dashboard counts
const getStats = async (req, res) => {
  try {
    const [patients, doctors, appointments, predictions] = await Promise.all([
      userModel.countDocuments({ role: "patient" }),
      doctorModel.countDocuments(),
      appointmentModel.countDocuments(),
      predictionModel.countDocuments(),
    ]);

    res.status(200).json({
      message: "Statistics loaded",
      data: { patients, doctors, appointments, predictions },
    });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ------------------------------------------------------------------ doctors

//list doctors
const listDoctors = async (req, res) => {
  try {
    const { search } = req.query;

    // The searchable name and email live on the user account, so when a search
    // term is given the matching users are found first.
    let filter = {};
    if (search) {
      const users = await userModel
        .find({ role: "doctor", ...searchFilter(search, ["name", "email"]) })
        .select("_id");

      filter = {
        $or: [
          { user: { $in: users.map((user) => user._id) } },
          ...searchFilter(search, ["specialization", "hospital"]).$or,
        ],
      };
    }

    const doctors = await doctorModel
      .find(filter)
      .populate("user", USER_FIELDS)
      .sort({ createdAt: -1 });

    res.status(200).json({ message: "Doctors loaded", data: doctors });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//single doctor
const getDoctor = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) {
      return res.status(404).json({ message: "Doctor not found" });
    }

    const doctor = await doctorModel
      .findById(req.params.id)
      .populate("user", USER_FIELDS);

    if (!doctor) {
      return res.status(404).json({ message: "Doctor not found" });
    }

    res.status(200).json({ message: "Doctor loaded", data: doctor });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

/*
 * Create a doctor.
 *
 * registerUser always assigns the patient role and ignores anything else, so a
 * doctor account cannot be created through the public API. This creates both
 * halves: the login account with role "doctor" and the professional profile.
 */
const createDoctor = async (req, res) => {
  try {
    const {
      name,
      phone,
      password,
      specialization,
      qualification,
      experience,
      hospital,
      fee,
      availability,
    } = req.body;
    const email = normaliseEmail(req.body.email);

    if (!email || !phone || !password) {
      return res.status(400).json({
        message: "Email, phone and password are required",
      });
    }

    if (!specialization || !qualification) {
      return res.status(400).json({
        message: "Specialization and qualification are required",
      });
    }

    // The schema only sees the hash, so the length is checked here
    if (String(password).length < 6) {
      return res.status(400).json({ message: "Password must be at least 6 characters" });
    }

    const userExists = await userModel.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: "Email already registered" });
    }

    const hashedPass = await bcrypt.hash(password, 10);

    const user = await userModel.create({
      name,
      phone,
      email,
      password: hashedPass,
      role: "doctor",
    });

    let doctor;
    try {
      doctor = await doctorModel.create({
        user: user._id,
        specialization,
        qualification,
        experience,
        hospital,
        fee,
        availability,
      });
    } catch (profileError) {
      // Without a transaction the account would otherwise be left behind with
      // no profile, and its email would block a retry.
      await userModel.findByIdAndDelete(user._id);
      throw profileError;
    }

    const created = await doctorModel
      .findById(doctor._id)
      .populate("user", USER_FIELDS);

    res.status(201).json({ message: "Doctor created", data: created });
  } catch (error) {
    const message = validationMessage(error);
    if (message) {
      return res.status(400).json({ message });
    }
    if (error.code === 11000) {
      return res.status(400).json({ message: "Email already registered" });
    }
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//update doctor
const updateDoctor = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) {
      return res.status(404).json({ message: "Doctor not found" });
    }

    const doctor = await doctorModel.findById(req.params.id);
    if (!doctor) {
      return res.status(404).json({ message: "Doctor not found" });
    }

    const { specialization, qualification, experience, hospital, fee, availability } =
      req.body;

    const profileUpdates = {
      specialization,
      qualification,
      experience,
      hospital,
      fee,
      availability,
    };
    Object.keys(profileUpdates).forEach((key) => {
      if (profileUpdates[key] === undefined) delete profileUpdates[key];
    });

    await doctorModel.updateOne(
      { _id: doctor._id },
      { $set: profileUpdates },
      { runValidators: true },
    );

    // Contact details belong to the account, not the profile
    const { name, phone } = req.body;
    const accountUpdates = { name, phone, email: normaliseEmail(req.body.email) };
    Object.keys(accountUpdates).forEach((key) => {
      if (accountUpdates[key] === undefined) delete accountUpdates[key];
    });

    if (Object.keys(accountUpdates).length > 0) {
      if (accountUpdates.email) {
        const taken = await userModel.findOne({
          email: accountUpdates.email,
          _id: { $ne: doctor.user },
        });
        if (taken) {
          return res.status(400).json({ message: "Email already registered" });
        }
      }
      await userModel.updateOne(
        { _id: doctor.user },
        { $set: accountUpdates },
        { runValidators: true },
      );
    }

    const updated = await doctorModel
      .findById(doctor._id)
      .populate("user", USER_FIELDS);

    res.status(200).json({ message: "Doctor updated", data: updated });
  } catch (error) {
    const message = validationMessage(error);
    if (message) {
      return res.status(400).json({ message });
    }
    if (error.code === 11000) {
      return res.status(400).json({ message: "Email already registered" });
    }
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//delete doctor, its login account and its appointments
const deleteDoctor = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) {
      return res.status(404).json({ message: "Doctor not found" });
    }

    const doctor = await doctorModel.findById(req.params.id);
    if (!doctor) {
      return res.status(404).json({ message: "Doctor not found" });
    }

    await appointmentModel.deleteMany({ doctor: doctor._id });
    await userModel.findByIdAndDelete(doctor.user);
    await doctorModel.findByIdAndDelete(doctor._id);

    res.status(200).json({ message: "Doctor deleted", data: { _id: doctor._id } });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ----------------------------------------------------------------- patients

//list patients
const listPatients = async (req, res) => {
  try {
    const { search } = req.query;

    const patients = await userModel
      .find({ role: "patient", ...searchFilter(search, ["name", "email", "phone"]) })
      .select(USER_FIELDS)
      .sort({ createdAt: -1 });

    res.status(200).json({ message: "Patients loaded", data: patients });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//delete a patient and everything belonging to them
const deletePatient = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) {
      return res.status(404).json({ message: "Patient not found" });
    }

    const patient = await userModel.findOne({
      _id: req.params.id,
      role: "patient",
    });
    if (!patient) {
      return res.status(404).json({ message: "Patient not found" });
    }

    await appointmentModel.deleteMany({ patient: patient._id });
    await predictionModel.deleteMany({ patient: patient._id });
    await userModel.findByIdAndDelete(patient._id);

    res.status(200).json({ message: "Patient deleted", data: { _id: patient._id } });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ------------------------------------------------------------- appointments

//list appointments
const listAppointments = async (req, res) => {
  try {
    const { status } = req.query;

    if (status && !APPOINTMENT_STATUSES.includes(status)) {
      return res.status(400).json({
        message: "Status must be one of: " + APPOINTMENT_STATUSES.join(", "),
      });
    }

    const appointments = await appointmentModel
      .find(status ? { status } : {})
      .populate("patient", USER_FIELDS)
      .populate({ path: "doctor", populate: { path: "user", select: USER_FIELDS } })
      .sort({ date: -1 });

    res.status(200).json({ message: "Appointments loaded", data: appointments });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//approve, reject or complete an appointment
const updateAppointmentStatus = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    const { status } = req.body;
    if (!APPOINTMENT_STATUSES.includes(status)) {
      return res.status(400).json({
        message: "Status must be one of: " + APPOINTMENT_STATUSES.join(", "),
      });
    }

    // Updated in one operation rather than load-then-save, so two
    // administrators acting at once cannot overwrite each other.
    const updated = await appointmentModel
      .findOneAndUpdate(
        { _id: req.params.id },
        { $set: { status } },
        { returnDocument: "after", runValidators: true },
      )
      .populate("patient", USER_FIELDS)
      .populate({ path: "doctor", populate: { path: "user", select: USER_FIELDS } });

    if (!updated) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    res.status(200).json({ message: "Appointment updated", data: updated });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

//delete an appointment
const deleteAppointment = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    const appointment = await appointmentModel.findByIdAndDelete(req.params.id);
    if (!appointment) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    res.status(200).json({
      message: "Appointment deleted",
      data: { _id: appointment._id },
    });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// -------------------------------------------------------------- predictions

//prediction history, read-only for administrators
const listPredictions = async (req, res) => {
  try {
    const { patient } = req.query;

    if (patient && !isValidId(patient)) {
      return res.status(400).json({ message: "Invalid patient id" });
    }

    const predictions = await predictionModel
      .find(patient ? { patient } : {})
      .populate("patient", USER_FIELDS)
      .sort({ createdAt: -1 });

    res.status(200).json({ message: "Predictions loaded", data: predictions });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

module.exports = {
  getStats,
  listDoctors,
  getDoctor,
  createDoctor,
  updateDoctor,
  deleteDoctor,
  listPatients,
  deletePatient,
  listAppointments,
  updateAppointmentStatus,
  deleteAppointment,
  listPredictions,
};
