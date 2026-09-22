const express = require('express');

const router = express.Router();

const {
  getAllMedicalRecords,
  getMedicalRecordById,
  getPatientMedicalRecords,
  createMedicalRecord,
  updateMedicalRecord,
  deleteMedicalRecord,
} = require('../controllers/medicalRecordController');

const {
  verifyToken,
  authorizeRoles,
} = require('../middleware/authMiddleware');

// ============================================================
// LẤY TẤT CẢ HỒ SƠ
// ADMIN / DOCTOR
// ============================================================

router.get(
  '/',
  verifyToken,
  authorizeRoles('ADMIN', 'DOCTOR'),
  getAllMedicalRecords
);

// ============================================================
// LẤY HỒ SƠ THEO BỆNH NHÂN
// ============================================================

router.get(
  '/patient/:patientId',
  verifyToken,
  getPatientMedicalRecords
);

// ============================================================
// LẤY CHI TIẾT
// ADMIN / DOCTOR
// ============================================================

router.get(
  '/:id',
  verifyToken,
  authorizeRoles('ADMIN', 'DOCTOR'),
  getMedicalRecordById
);

// ============================================================
// THÊM
// ADMIN / DOCTOR
// ============================================================

router.post(
  '/',
  verifyToken,
  authorizeRoles('ADMIN', 'DOCTOR'),
  createMedicalRecord
);

// ============================================================
// SỬA
// ADMIN / DOCTOR
// ============================================================

router.put(
  '/:id',
  verifyToken,
  authorizeRoles('ADMIN', 'DOCTOR'),
  updateMedicalRecord
);

// ============================================================
// XÓA
// ADMIN / DOCTOR
// ============================================================

router.delete(
  '/:id',
  verifyToken,
  authorizeRoles('ADMIN', 'DOCTOR'),
  deleteMedicalRecord
);

module.exports = router;