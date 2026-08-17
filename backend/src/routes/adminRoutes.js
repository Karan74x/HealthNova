const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const roleMiddleware = require("../middleware/roleMiddleware");

const router = express.Router();
// Only admins can access this route
router.get(
  "/dashboard",
  authMiddleware,
  roleMiddleware("admin"),
  (req, res) => {
    res.status(200).json({
      message: "Welcome Admin",
    });
  },
);

module.exports = router;
