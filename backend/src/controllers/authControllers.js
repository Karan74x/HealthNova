const bcrypt = require("bcryptjs");
const userModel = require("../models/userModel.js");

const registerUser = async (req, res) => {
  // Get the user data from register page /body
  try {
    const { phone, email, password } = req.body;

    const userExists = await userModel.findOne({ email });

    //Check if email exists
    if (userExists) {
      return res.status(400).json({
        message: "Email already registered",
      });
    }

    // Hash the password
    const hashedPass = await bcrypt.hash(password, 10);

    //create new user
    const user = await userModel.create({
      phone,
      email,
      password: hashedPass,
    });

    res.status(201).json({
      // Send success response
      user: {
        _id: user._id,
        phone: user.phone,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    // Handle server errors
    res.status(500).json({
      message: "Server Error",
      error: error.message,
    });
  }
};

module.exports = {
  registerUser,
};
