const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    // Phone number
    phone: {
      type: String,
      required: [true, "Phone is required"],
      trim: true,
      match: [/^[0-9]{10}$/, "Phone number must be exactly 10 digits"],
    },

    //email
    email: {
      type: String,
      required: [true, "Email is required"],
      trim: true,
      lowercase: true,
      unique: true,
    },

    // passowrd
    password: {
      type: String,
      required: [true, "Password is required"],
      minlength: [6, "Password must be atleast 6 characters"],
    },

    //gender
    gender: {
      type: String,
      enum: ["Male", "Female", "other"],
    },

    //dob
    dob: {
      type: Date,
    },

    //profile picture
    profilePicture: {
      type: String,
      trim: true,
    },

    // role
    role: {
      type: String,
      enum: ["patient", "admin", "doctor"],
      default: "patient",
    },
  },
  {
    // Automatically adds createdAt and updatedAt
    timestamps: true,
  },
);

module.exports = mongoose.model("User", userSchema);
