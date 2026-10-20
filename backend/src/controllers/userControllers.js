const userModel = require("../models/userModel.js");

// Values the user schema accepts for gender
const GENDERS = ["Male", "Female", "other"];

// Fields returned for the signed-in user. The password hash never leaves.
const SELF_FIELDS = "name email phone gender dob profilePicture role createdAt updatedAt";

//the signed-in user's own account
const getMe = async (req, res) => {
  try {
    const user = await userModel.findById(req.user.userId).select(SELF_FIELDS);

    // A valid token for an account that has since been deleted
    if (!user) {
      return res.status(404).json({ message: "Account not found" });
    }

    res.status(200).json({ message: "Account loaded", data: user });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

/*
 * Update the signed-in user's own details.
 *
 * Only personal details can change here. Email, password and role are left
 * out on purpose: changing the email would change how the account signs in,
 * and the role must never be self-assigned.
 */
const updateMe = async (req, res) => {
  try {
    const { name, phone, gender, dob } = req.body;
    const updates = { name, phone, gender, dob };
    const clear = {};
    Object.keys(updates).forEach((key) => {
      if (updates[key] === undefined) delete updates[key];
    });

    // An empty string clears an optional field rather than failing validation
    ["gender", "dob"].forEach((key) => {
      if (updates[key] === "" || updates[key] === null) {
        delete updates[key];
        clear[key] = "";
      }
    });

    // The schema stores "Male", "Female" and "other"; accept any casing
    if (typeof updates.gender === "string") {
      updates.gender = GENDERS.find((value) => value.toLowerCase() === updates.gender.toLowerCase())
        || updates.gender;
    }

    const change = { $set: updates };
    if (Object.keys(clear).length > 0) change.$unset = clear;

    const updated = await userModel.findByIdAndUpdate(req.user.userId, change, {
      runValidators: true,
    });

    if (!updated) {
      return res.status(404).json({ message: "Account not found" });
    }

    // Read back separately with the safe field list, so the password hash can
    // never be part of the response.
    const user = await userModel.findById(req.user.userId).select(SELF_FIELDS);

    res.status(200).json({ message: "Account updated", data: user });
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

module.exports = { getMe, updateMe };
