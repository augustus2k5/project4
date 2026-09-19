const express = require("express");
const router = express.Router();

const { getUsers,updateProfile  } = require("../controllers/userController");

const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");

router.get("/", verifyToken, authorizeRoles("ADMIN"), getUsers);

router.put("/profile", verifyToken, updateProfile);

module.exports = router;