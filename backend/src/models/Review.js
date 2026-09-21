const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  appointmentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Appointment',
    default: null
  },
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
     default: null
  },
  customAuthorName: {
        type: String,
        default: '',
        trim: true,
      },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Doctor',
    required: [true, 'Vui lòng cung cấp ID bác sĩ']
  },
  rating: { 
    type: Number, 
    required: [true, 'Vui lòng chọn số sao đánh giá'],
    min: 1, 
    max: 5 
  }, 
  comment: { type: String, default: '' },
  images: [{type: String}],
  isAnonymous: {type: Boolean,default: false},
  adminReply: {comment: { type: String, default: '' },repliedAt: { type: Date, default: null }}
}, { timestamps: true });
// Đảm bảo 1 lịch hẹn chỉ có 1 review (chỉ áp dụng khi có appointmentId)
reviewSchema.index({ appointmentId: 1 }, { unique: true, sparse: true });
module.exports = mongoose.model('Review', reviewSchema);