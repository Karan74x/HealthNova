const express = require("express"); // Import Express
const authRoutes = require("./routes/authRoutes");

// Creates our Express application.
const app = express();

// middleware to Parse JSON request body
app.use(express.json());

//Authentication route
app.use("/api/auth", authRoutes);

app.get("/test", (req, res) => {
  res.json({
    message: "HealthNova server is working",
  });
});

module.exports = app; // Export app so server.js can use it
