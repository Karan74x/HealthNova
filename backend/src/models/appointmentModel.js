const mongoose = require("mongoose");

// Allowed appointment states. Exported so the controllers validate against one
// list instead of repeating the strings.
const APPOINTMENT_STATUSES = ["Pending", "Approved", "Rejected", "Completed"];

const appointmentSchema = new mongoose.Schema(
  {
    //patient who booked the appointment
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "Patient is required"],
    },

    //doctor the appointment is with
    doctor: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Doctor",
      required: [true, "Doctor is required"],
    },

    //appointment date
    date: {
      type: Date,
      required: [true, "Appointment date is required"],
    },

    //appointment time slot
    time: {
      type: String,
      required: [true, "Appointment time is required"],
      trim: true,
    },

    //reason or notes provided by the patient
    reason: {
      type: String,
      trim: true,
    },

    //current status
    status: {
      type: String,
      enum: {
        values: APPOINTMENT_STATUSES,
        message: "Status must be one of: " + APPOINTMENT_STATUSES.join(", "),
      },
      default: "Pending",
    },
  },
  {
    // Automatically adds createdAt and updatedAt
    timestamps: true,
  },
);

// Listing a doctor's own appointments is the most frequent query
appointmentSchema.index({ doctor: 1, date: -1 });
appointmentSchema.index({ patient: 1, date: -1 });

const Appointment = mongoose.model("Appointment", appointmentSchema);

module.exports = Appointment;
module.exports.APPOINTMENT_STATUSES = APPOINTMENT_STATUSES;
