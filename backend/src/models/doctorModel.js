const mongoose = require("mongoose");

// Doctor profile. The login account lives in the User collection; this holds
// the professional details that only apply to a doctor.
const doctorSchema = new mongoose.Schema(
  {
    // The user account this profile belongs to
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "User reference is required"],
      unique: true,
    },

    //specialization
    specialization: {
      type: String,
      required: [true, "Specialization is required"],
      trim: true,
    },

    //qualification
    qualification: {
      type: String,
      required: [true, "Qualification is required"],
      trim: true,
    },

    //years of experience
    experience: {
      type: Number,
      min: [0, "Experience cannot be negative"],
      default: 0,
    },

    //affiliated hospital or clinic
    hospital: {
      type: String,
      trim: true,
    },

    //consultation fee
    fee: {
      type: Number,
      min: [0, "Fee cannot be negative"],
      default: 0,
    },

    //available days and time slots, free text for now
    availability: {
      type: String,
      trim: true,
    },
  },
  {
    // Automatically adds createdAt and updatedAt
    timestamps: true,
  },
);

module.exports = mongoose.model("Doctor", doctorSchema);
