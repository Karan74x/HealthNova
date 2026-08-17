const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// Any logged-in user can access profile
router.get("/profile", authMiddleware, (req, res) => {
  res.status(200).json({
    message: "Profile accessed successfully",
    user: req.user,
  });
});



module.exports = router;
