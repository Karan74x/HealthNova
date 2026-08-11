const mongoose = require("mongoose");  // Import Mongoose


// Function for database connection
const ConnectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("MongoDB Connected Successfully");
  } catch (error) {
    console.log("MongoDB Connection Failed");
    process.exit(1);
  }
};

module.exports = ConnectDB;
