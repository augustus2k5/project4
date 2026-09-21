const express = require('express');

const router = express.Router();

const {
  createDoctor,
  getAllDoctors,
  getDoctorsBySpecialty,
  getDoctorById,
  updateDoctor,
  deleteDoctor
} = require('../controllers/doctorController');

const {
  verifyToken,
  authorizeRoles
} = require('../middleware/authMiddleware');


// GET tất cả bác sĩ
router.get(
  '/',
  verifyToken,
  getAllDoctors
);


// GET bác sĩ theo chuyên khoa
router.get(
  '/specialty/:specialtyId',
  verifyToken,
  getDoctorsBySpecialty
);


// GET chi tiết bác sĩ
router.get(
  '/:id',
  verifyToken,
  getDoctorById
);


// POST thêm bác sĩ
router.post(
  '/',
  verifyToken,
  authorizeRoles('ADMIN'),
  createDoctor
);


// PUT sửa bác sĩ
router.put(
  '/:id',
  verifyToken,
  authorizeRoles('ADMIN'),
  updateDoctor
);


// DELETE xóa bác sĩ
router.delete(
  '/:id',
  verifyToken,
  authorizeRoles('ADMIN'),
  deleteDoctor
);


module.exports = router;
