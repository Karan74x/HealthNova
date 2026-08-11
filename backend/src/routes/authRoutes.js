const express = require("express");
const { registerUser } = require("../controllers/authControllers");

// a mini express application to specifically handle routes
const router = express.Router();

//register user
router.post("/register", registerUser);

module.exports = router;
