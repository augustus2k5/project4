const Appointment = require('../models/Appointment');


exports.createAppointment = async (req, res) => {
  try {
    const { patientId, doctorId, date, timeSlot, reason } = req.body;

    
    const existingAppointment = await Appointment.findOne({
      doctorId,
      date,
      timeSlot,
      status: { $ne: 'CANCELLED' } 
    });

    if (existingAppointment) {
      return res.status(400).json({ message: 'Bác sĩ đã có lịch hẹn vào khung giờ này!' });
    }

    const appointment = new Appointment({
      patientId,
      doctorId,
      date,
      timeSlot,
      reason
    });

    await appointment.save();
    res.status(201).json({ message: 'Đặt lịch khám thành công!', appointment });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


exports.getPatientAppointments = async (req, res) => {
  try {
    const { patientId } = req.params;
    const appointments = await Appointment.find({ patientId })
      .populate({
        path: 'doctorId',
        populate: [
          { path: 'userId', select: 'fullName email phoneNumber' },
          { path: 'specialtyId', select: 'name iconUrl' }
        ]
      })
      .sort({ createdAt: -1 });

    res.json(appointments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


exports.updateAppointmentStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body; // PENDING, CONFIRMED, CANCELLED, COMPLETED

    const appointment = await Appointment.findByIdAndUpdate(
      id,
      { status },
      { new: true }
    );

    if (!appointment) {
      return res.status(404).json({ message: 'Không tìm thấy lịch hẹn!' });
    }

    res.json({ message: 'Cập nhật trạng thái thành công!', appointment });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
// lấy toàn bộ AllAppointments
exports.getAllAppointments = async (req, res) => {
  try {
    const appointments = await Appointment.find()
      .populate('patientId', 'fullName email phoneNumber')
      .populate({
        path: 'doctorId',
        populate: [
          { path: 'userId', select: 'fullName email phoneNumber' },
          { path: 'specialtyId', select: 'name' }
        ]
      })
      .sort({ createdAt: -1 });
    res.status(200).json(appointments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.cancelAppointment = async (req, res) => {
  try {
    const { id } = req.params;

    const appointment = await Appointment.findById(id);
    if (!appointment) {
      return res.status(404).json({ message: 'Không tìm thấy lịch hẹn!' });
    }

    // Kiểm tra nếu lịch đã hoàn thành thì không cho hủy
    if (appointment.status === 'COMPLETED') {
      return res.status(400).json({ message: 'Lịch hẹn đã hoàn thành, không thể hủy!' });
    }

    // Cập nhật trạng thái thành CANCELLED
    appointment.status = 'CANCELLED';
    await appointment.save();

    res.status(200).json({
      message: 'Hủy lịch hẹn thành công!',
      appointment
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};