const Doctor = require('../models/Doctor');
const User = require('../models/User');
const Appointment = require('../models/Appointment');

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

exports.getMyAppointments = async (req, res) => {
  try {
    const doctor = await Doctor.findOne({ userId: req.user.id });
    if (!doctor) {
      return res.status(404).json({ message: 'Không tìm thấy thông tin Bác sĩ!' });
    }


    const appointments = await Appointment.find({ doctorId: doctor._id })
      .populate('patientId', 'fullName email phone') 
      .sort({ date: 1, timeSlot: 1 });

    res.status(200).json(appointments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};