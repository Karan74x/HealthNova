const bcrypt = require("bcryptjs");
const userModel = require("../models/userModel.js");
const jwt = require("jsonwebtoken");

//register user
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

//login user
const loginUser = async (req, res) => {
  try {
    //Get login data from request body
    const { email, password } = req.body;

    //Find user by email
    const user = await userModel.findOne({ email });

    //Check if user exists
    if (!user) {
      return res.status(400).json({
        message: "Invalid emal or password",
      });
    }

    //comparing entered password with hash password
    const correctPassword = await bcrypt.compare(password, user.password);

    //Check passoword
    if (!correctPassword) {
      return res.status(400).json({
        message: "Invalid Email or password",
      });
    }

    //Creating JWT
    const token = jwt.sign(
      { userId: user._id, role: user.role },
      process.env.JWT_SECRET,
      {
        expiresIn: "7d",
      },
    );

    // Login
    res.status(200).json({
      message: "Login Successful",
      token: token,
      user: {
        _id: user._id,
        phone: user.phone,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    //TO handle server errors
    res.status(500).json({
      message: "Server Error",
      error: error.message,
    });
  }
};
module.exports = {
  registerUser,
  loginUser,
};
