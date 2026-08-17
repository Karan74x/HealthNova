const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const roleMiddleware = require("../middleware/roleMiddleware");

const router = express.Router();

// Only doctors can access this route
router.get(
  "/dashboard",
  authMiddleware,
  roleMiddleware("doctor"),
  (req, res) => {
    res.status(200).json({
      message: "Welcome Doctor",
      user: req.user,
    });
  },
);

module.exports = router;
