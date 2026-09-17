const Appointment = require('../models/Appointment');


exports.createAppointment = async (req, res) => {
  try {
    const { patientId, doctorId, date, timeSlot, reason } = req.body;

    // 1. Kiểm tra Bác sĩ đã có lịch chưa
    const doctorBusy = await Appointment.findOne({
      doctorId,
      date,
      timeSlot,
      status: { $ne: 'CANCELLED' } 
    });

    if (doctorBusy) {
      return res.status(400).json({ message: 'Bác sĩ đã có lịch hẹn vào khung giờ này!' });
    }

    // 2. (Mới) Kiểm tra Bệnh nhân có bị trùng giờ khám khác không
    const patientBusy = await Appointment.findOne({
      patientId,
      date,
      timeSlot,
      status: { $ne: 'CANCELLED' }
    });

    if (patientBusy) {
      return res.status(400).json({ message: 'Bạn đã có một lịch khám khác vào khung giờ này!' });
    }

    // 3. Tạo lịch mới
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