const mongoose = require('mongoose');

const medicalRecordSchema = new mongoose.Schema(
  {
    // ============================================================
    // LỊCH HẸN
    // ============================================================
    appointmentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Appointment',
      required: true,
      unique: true,
    },

    // ============================================================
    // BỆNH NHÂN
    // Lưu User._id của bệnh nhân
    // ============================================================
    patientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    // ============================================================
    // BÁC SĨ
    // Lưu Doctor._id
    // ============================================================
    doctorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Doctor',
      required: true,
    },

    // ============================================================
    // CHẨN ĐOÁN
    // ============================================================
    diagnosis: {
      type: String,
      required: true,
      trim: true,
    },

    // ============================================================
    // GHI CHÚ
    // ============================================================
    notes: {
      type: String,
      default: '',
      trim: true,
    },

    // ============================================================
    // ĐƠN THUỐC
    // ============================================================
    prescriptions: [
      {
        drugName: {
          type: String,
          required: true,
          trim: true,
        },

        quantity: {
          type: Number,
          required: true,
          min: 1,
        },

        dosage: {
          type: String,
          required: true,
          trim: true,
        },
      },
    ],
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model(
  'MedicalRecord',
  medicalRecordSchema
);