const bcrypt = require("bcryptjs");
const userModel = require("../models/userModel.js");
const jwt = require("jsonwebtoken");

// Emails are stored lowercase, so they are compared that way too
const normaliseEmail = (email) => (typeof email === "string" ? email.trim().toLowerCase() : "");

//register user
const registerUser = async (req, res) => {
  // Get the user data from register page /body
  try {
    const { name, phone, password, gender, dob } = req.body;
    const email = normaliseEmail(req.body.email);

    if (!email || !phone || !password) {
      return res.status(400).json({
        message: "Email, phone and password are required",
      });
    }

    const userExists = await userModel.findOne({ email });

    //Check if email exists
    if (userExists) {
      return res.status(400).json({
        message: "Email already registered",
      });
    }

    // The schema only sees the hash, so the length rule is checked here
    if (String(password).length < 6) {
      return res.status(400).json({
        message: "Password must be at least 6 characters",
      });
    }

    // Hash the password
    const hashedPass = await bcrypt.hash(password, 10);

    //create new user. The role is never taken from the request: every
    //account registered here is a patient.
    const user = await userModel.create({
      name,
      phone,
      email,
      password: hashedPass,
      gender: gender || undefined,
      dob: dob || undefined,
    });

    res.status(201).json({
      // Send success response
      user: {
        _id: user._id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    // A rule in the schema failed, e.g. a phone number that is not 10 digits
    if (error.name === "ValidationError" || error.name === "CastError") {
      const first = error.errors ? Object.values(error.errors)[0] : null;
      return res.status(400).json({
        message: first ? first.message : error.message,
      });
    }
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
    const { password } = req.body;
    const email = normaliseEmail(req.body.email);

    if (!email || !password) {
      return res.status(400).json({
        message: "Email and password are required",
      });
    }

    //Find user by email
    const user = await userModel.findOne({ email });

    //Check if user exists. The same message is used for a wrong password so
    //the response does not reveal which emails are registered.
    if (!user) {
      return res.status(400).json({
        message: "Invalid email or password",
      });
    }

    //comparing entered password with hash password
    const correctPassword = await bcrypt.compare(password, user.password);

    //Check passoword
    if (!correctPassword) {
      return res.status(400).json({
        message: "Invalid email or password",
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
        name: user.name,
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
