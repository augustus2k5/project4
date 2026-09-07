const mongoose = require('mongoose');

const medicalRecordSchema = new mongoose.Schema({
  appointmentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Appointment',
    required: true,
    unique: true
  },
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
  diagnosis: { type: String, required: true }, 
  notes: { type: String, default: '' },       
  prescriptions: [                             
    {
      drugName: { type: String, required: true },
      quantity: { type: Number, required: true }, 
      dosage: { type: String, required: true }   
    }
  ]
}, { timestamps: true });

module.exports = mongoose.model('MedicalRecord', medicalRecordSchema);