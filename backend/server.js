require("dotenv").config(); //  Load .env variables

const app = require("./src/app.js");

// Import DB connection
const ConnectDB = require("./src/config/db.js");

// Gets the port from .env, falling back to the port the dashboard expects
const port = process.env.PORT || 5000;

if (!process.env.JWT_SECRET) {
  console.log("JWT_SECRET is not set in backend/.env - sign-in will not work");
  process.exit(1);
}

ConnectDB();

// Starts our express server.
app.listen(port, () => {
  console.log(`HealthNova server is running on port ${port}`);
});
