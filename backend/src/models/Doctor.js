const mongoose = require('mongoose');

const doctorSchema = new mongoose.Schema(
  {
    // ==========================================================
    // TÀI KHOẢN USER
    // ==========================================================

    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true
    },

    // ==========================================================
    // CHUYÊN KHOA
    // ==========================================================

    specialtyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Specialty',
      required: true
    },

    // ==========================================================
    // GIÁ KHÁM
    // ==========================================================

    price: {
      type: Number,
      required: true,
      min: 0
    },

    // ==========================================================
    // GIỚI THIỆU
    // ==========================================================

    bio: {
      type: String,
      default: ''
    },

    // ==========================================================
    // KINH NGHIỆM
    // ==========================================================

    experienceYears: {
      type: Number,
      default: 0,
      min: 0
    },
    // ==========================================================
    // Điểm đánh giá trung bình & tổng số lượt đánh giá
    // ==========================================================
    rating: {
      type: Number,
      default: 5.0,
      min: 0,
      max: 5
    },
    totalReviews: {
      type: Number,
      default: 0,
      min: 0
    }
  },
  {
    timestamps: true
  }
);

module.exports =
  mongoose.model(
    'Doctor',
    doctorSchema
  );
