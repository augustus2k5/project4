const mongoose = require('mongoose');

const specialtySchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true }, 
  description: { type: String, default: '' },           
  iconUrl: { type: String, default: '' }               
}, { timestamps: true });

module.exports = mongoose.model('Specialty', specialtySchema);