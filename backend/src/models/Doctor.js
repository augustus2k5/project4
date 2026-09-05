const mongoose = require('mongoose');

const doctorSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true,
    unique: true 
  },
  specialtyId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Specialty', 
    required: true 
  },
  price: { type: Number, required: true },   
  bio: { type: String, default: '' },            
  experienceYears: { type: Number, default: 0 }  
}, { timestamps: true });

module.exports = mongoose.model('Doctor', doctorSchema);