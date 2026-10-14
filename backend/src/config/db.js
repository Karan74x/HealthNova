const mongoose = require("mongoose");  // Import Mongoose


// Function for database connection
const ConnectDB = async () => {
  if (!process.env.MONGO_URI) {
    console.log("MongoDB Connection Failed: MONGO_URI is not set in backend/.env");
    process.exit(1);
  }

  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("MongoDB Connected Successfully");
  } catch (error) {
    // The reason matters: an IP not on the Atlas allowlist, a wrong password
    // and a mistyped host all fail here with different messages.
    console.log("MongoDB Connection Failed:", error.message);
    process.exit(1);
  }
};

module.exports = ConnectDB;
