const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const roleMiddleware = require("../middleware/roleMiddleware");

const router = express.Router();

// Only patients can access this route
router.get(
  "/dashboard",
  authMiddleware,
  roleMiddleware("patient"),
  (req, res) => {
    res.status(200).json({
      message: "Welcome Patient",
      user: req.user,
    });
  },
);

module.exports = router;
