const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const user = require("../controllers/userControllers");

const router = express.Router();

// Any logged-in user can access profile
// Returns the verified token payload (userId, role, iat, exp); the dashboard
// uses it to show session details.
router.get("/profile", authMiddleware, (req, res) => {
  res.status(200).json({
    message: "Profile accessed successfully",
    user: req.user,
  });
});

// The signed-in user's own account record, and updating their own details
router.get("/me", authMiddleware, user.getMe);
router.put("/me", authMiddleware, user.updateMe);

module.exports = router;
