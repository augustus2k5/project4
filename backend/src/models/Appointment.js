const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
  patientId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  doctorId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Doctor', 
    required: true 
  },
  date: { type: String, required: true },     
  timeSlot: { type: String, required: true },  
  reason: { type: String, default: '' },        
  status: { 
    type: String, 
    enum: ['PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED'], 
    default: 'PENDING' 
  }
}, { timestamps: true });

module.exports = mongoose.model('Appointment', appointmentSchema);