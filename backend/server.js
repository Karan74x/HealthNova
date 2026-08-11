require("dotenv").config(); //  Load .env variables

// Imports Express.
const express = require("express");
const app = require("./src/app.js");

// Import DB connection
const ConnectDB = require("./src/config/db.js");

// Gets the port from .env
const port = process.env.PORT;

ConnectDB();

// Starts our express server.
app.listen(port, () => {
  console.log(`HealthNova server is running on port ${port}`);
});
