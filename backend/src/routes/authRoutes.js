const express = require("express");
const { registerUser, loginUser } = require("../controllers/authControllers");

// a mini express application to specifically handle routes
const router = express.Router();

//register user
router.post("/register", registerUser);

//login user
router.post("/login", loginUser);
module.exports = router;
