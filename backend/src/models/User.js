const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  email: { 
    type: String, 
    required: [true, 'Email là bắt buộc'], 
    unique: true,
    lowercase: true,
    match: [
      /^[^\s@]+@[^\s@]+\.[^\s@]+$/, 
      'Email không đúng định dạng!' 
    ]
  },
  password: { type: String, required: true },
  phoneNumber: { type: String, default: '' },
  avatar:{type:String , default:""},
  role: { 
    type: String, 
    enum: ['PATIENT', 'DOCTOR', 'ADMIN'], 
    default: 'PATIENT' 
  },
  status: {
    type: String,
    enum: ['ACTIVE', 'INACTIVE', 'BLOCKED'],
    default: 'ACTIVE'
  }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);