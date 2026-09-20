const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const connectDB = require('../config/db');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const User = require('../models/User');
const Doctor = require('../models/Doctor');
const Specialty = require('../models/Specialty');
const Appointment = require('../models/Appointment');
const { verifyToken, authorizeRoles } = require('../middleware/authMiddleware');

dotenv.config({ path: path.resolve(__dirname, '../../.env') });
connectDB();
const app = express();
app.use(cors());
app.use(express.json());

// Reuse all original API modules.
app.use('/api/auth', require('../routes/authRoutes'));
app.use('/api/users', require('../routes/userRoutes'));
app.use('/api/specialties', require('../routes/specialtyRoutes'));
app.use('/api/doctors', require('../routes/doctorRoutes'));
app.use('/api/medical-records', require('../routes/medicalRecordRoutes'));
app.use('/api/appointments', require('../routes/appointmentRoutes'));
app.use('/api/reviews', require('../routes/reviewRoutes'));

// ---------------- Patient convenience APIs ----------------
app.patch('/api/patient/appointments/:id/cancel', verifyToken, authorizeRoles('PATIENT'), async (req, res) => {
  try {
    const appt = await Appointment.findOneAndUpdate(
      { _id: req.params.id, patientId: req.user.id, status: { $in: ['PENDING', 'CONFIRMED'] } },
      { status: 'CANCELLED' },
      { new: true }
    );
    if (!appt) return res.status(404).json({ message: 'Không tìm thấy lịch hẹn hoặc lịch đã không thể hủy.' });
    res.json({ message: 'Đã hủy lịch hẹn.', appointment: appt });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// Get appointments of current doctor.
app.get('/api/doctor/appointments', verifyToken, authorizeRoles('DOCTOR'), async (req, res) => {
  try {
    const doctor = await Doctor.findOne({ userId: req.user.id });
    if (!doctor) return res.status(404).json({ message: 'Chưa có hồ sơ bác sĩ.' });
    const items = await Appointment.find({ doctorId: doctor._id })
      .populate('patientId', 'fullName email phoneNumber')
      .sort({ date: 1, createdAt: -1 });
    res.json(items);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// ---------------- Admin APIs ----------------
app.get('/api/admin/stats', verifyToken, authorizeRoles('ADMIN'), async (req, res) => {
  try {
    const [users, doctors, specialties, appointments] = await Promise.all([
      User.countDocuments(), Doctor.countDocuments(), Specialty.countDocuments(), Appointment.countDocuments()
    ]);
    const [pending, confirmed, completed, cancelled] = await Promise.all([
      Appointment.countDocuments({ status: 'PENDING' }),
      Appointment.countDocuments({ status: 'CONFIRMED' }),
      Appointment.countDocuments({ status: 'COMPLETED' }),
      Appointment.countDocuments({ status: 'CANCELLED' }),
    ]);
    res.json({ users, doctors, specialties, appointments, pending, confirmed, completed, cancelled });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.get('/api/admin/users', verifyToken, authorizeRoles('ADMIN'), async (req, res) => {
  try { res.json(await User.find().select('-password').sort({ createdAt: -1 })); }
  catch (e) { res.status(500).json({ message: e.message }); }
});

app.post('/api/admin/users', verifyToken, authorizeRoles('ADMIN'), async (req, res) => {
  try {
    const { fullName, email, password, phoneNumber = '', role = 'PATIENT' } = req.body;
    if (!fullName || !email || !password) return res.status(400).json({ message: 'Vui lòng nhập họ tên, email và mật khẩu.' });
    if (await User.findOne({ email: email.toLowerCase().trim() })) return res.status(400).json({ message: 'Email đã tồn tại.' });
    const hashed = await bcrypt.hash(password, 10);
    const user = await User.create({ fullName, email: email.toLowerCase().trim(), password: hashed, phoneNumber, role });
    const safe = user.toObject(); delete safe.password;
    res.status(201).json(safe);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.patch('/api/admin/users/:id/status', verifyToken, authorizeRoles('ADMIN'), async (req, res) => {
  try {
    const { status } = req.body;
    if (!['ACTIVE', 'INACTIVE', 'BLOCKED'].includes(status)) return res.status(400).json({ message: 'Trạng thái không hợp lệ.' });
    const user = await User.findByIdAndUpdate(req.params.id, { status }, { new: true }).select('-password');
    if (!user) return res.status(404).json({ message: 'Không tìm thấy người dùng.' });
    res.json(user);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.delete('/api/admin/users/:id', verifyToken, authorizeRoles('ADMIN'), async (req, res) => {
  try {
    if (String(req.user.id) === String(req.params.id)) return res.status(400).json({ message: 'Không thể tự xóa tài khoản admin đang đăng nhập.' });
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) return res.status(404).json({ message: 'Không tìm thấy người dùng.' });
    res.json({ message: 'Đã xóa người dùng.' });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.get('/api/admin/appointments', verifyToken, authorizeRoles('ADMIN'), async (req, res) => {
  try {
    const items = await Appointment.find()
      .populate('patientId', 'fullName email phoneNumber')
      .populate({ path: 'doctorId', populate: [{ path: 'userId', select: 'fullName email' }, { path: 'specialtyId', select: 'name' }] })
      .sort({ createdAt: -1 });
    res.json(items);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.patch('/api/admin/appointments/:id/status', verifyToken, authorizeRoles('ADMIN'), async (req, res) => {
  try {
    const { status } = req.body;
    if (!['PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED'].includes(status)) return res.status(400).json({ message: 'Trạng thái không hợp lệ.' });
    const item = await Appointment.findByIdAndUpdate(req.params.id, { status }, { new: true });
    if (!item) return res.status(404).json({ message: 'Không tìm thấy lịch hẹn.' });
    res.json(item);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.get('/api/health', (req, res) => res.json({ ok: true, service: 'healthcare-booking-api' }));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Healthcare complete API running on port ${PORT}`));
