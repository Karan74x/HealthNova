const express = require("express"); // Import Express
const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const adminRoutes = require("./routes/adminRoutes");
const patientRoutes = require("./routes/patientRoutes");
const doctorRoutes = require("./routes/doctorRoutes");
// Creates our Express application.

const app = express();

// middleware to Parse JSON request body
app.use(express.json());

//Authentication route
app.use("/api/auth", authRoutes);

//user
app.use("/api/user", userRoutes);

//Admin
app.use("/api/admin", adminRoutes);

//Doctor
app.use("/api/doctor", doctorRoutes);

//Patient
app.use("/api/patient", patientRoutes);
module.exports = app; // Export app so server.js can use it
