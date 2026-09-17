const Doctor = require('../models/Doctor');
const User = require('../models/User');

exports.createDoctor = async (req, res) => {
  try {
    const { userId, specialtyId, price, bio, experienceYears } = req.body;

    const user = await User.findById(userId);
    if (!user || user.role !== 'DOCTOR') {
      return res.status(400).json({ message: 'User không tồn tại hoặc không phải là Bác sĩ!' });
    }

    const existingDoctor = await Doctor.findOne({ userId });
    if (existingDoctor) {
      return res.status(400).json({ message: 'Bác sĩ này đã có profile trên hệ thống!' });
    }

    const doctor = new Doctor({ userId, specialtyId, price, bio, experienceYears });
    await doctor.save();

    res.status(201).json({ message: 'Tạo thông tin Bác sĩ thành công!', doctor });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAllDoctors = async (req, res) => {
  try {
    const doctors = await Doctor.find()
      .populate('userId', 'fullName email phoneNumber')
      .populate('specialtyId', 'name iconUrl');
    res.json(doctors);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


exports.getDoctorsBySpecialty = async (req, res) => {
  try {
    const { specialtyId } = req.params;
    const doctors = await Doctor.find({ specialtyId })
      .populate('userId', 'fullName email phoneNumber')
      .populate('specialtyId', 'name iconUrl');
    res.json(doctors);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};