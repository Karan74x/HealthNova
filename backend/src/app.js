const express = require("express"); // Import Express
const cors = require("cors");
const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const adminRoutes = require("./routes/adminRoutes");
const patientRoutes = require("./routes/patientRoutes");
const doctorRoutes = require("./routes/doctorRoutes");
// Creates our Express application.

const app = express();

// Cross-origin access. The React dashboard goes through the Vite proxy and does
// not need this, but the Flutter app running in a browser calls the API
// directly. CORS_ORIGIN can list allowed origins, comma separated; without it
// any origin is allowed, which is fine because authentication uses a token
// header, not cookies.
const allowedOrigins = (process.env.CORS_ORIGIN || "")
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);
app.use(cors(allowedOrigins.length ? { origin: allowedOrigins } : {}));

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

// Health check, handy for confirming the server is up
app.get("/api/health", (req, res) => {
  res.status(200).json({ message: "HealthNova API is running" });
});

// Unknown routes get JSON, not Express's HTML page, so clients can show it
app.use((req, res) => {
  res.status(404).json({ message: `Route not found: ${req.method} ${req.originalUrl}` });
});

// Errors thrown outside the controllers, e.g. a request body that is not valid
// JSON. Kept to four arguments: that is how Express recognises it.
// eslint-disable-next-line no-unused-vars
app.use((error, req, res, next) => {
  if (error.type === "entity.parse.failed") {
    return res.status(400).json({ message: "Request body is not valid JSON" });
  }
  res.status(error.status || 500).json({ message: error.message || "Server Error" });
});

module.exports = app; // Export app so server.js can use it
