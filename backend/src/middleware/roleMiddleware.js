const roleMiddleware = (CorrectRole) => {
  return (req, res, next) => {
    if (req.user.role !== CorrectRole) {
      return res.status(403).json({
        message: "Access denied",
      });
    }

    next();
  };
};

module.exports = roleMiddleware;
