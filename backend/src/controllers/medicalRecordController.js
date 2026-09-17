const MedicalRecord = require('../models/MedicalRecord');
const Appointment = require('../models/Appointment');

exports.createMedicalRecord = async (req, res) => {
  try {
    const { appointmentId, patientId, doctorId, diagnosis, notes, prescriptions } = req.body;

    // Kiểm tra xem lịch hẹn đã tạo bệnh án chưa
    const existingRecord = await MedicalRecord.findOne({ appointmentId });
    if (existingRecord) {
      return res.status(400).json({ message: 'Lịch hẹn này đã có hồ sơ bệnh án!' });
    }

    const record = new MedicalRecord({
      appointmentId,
      patientId,
      doctorId,
      diagnosis,
      notes,
      prescriptions
    });

    await record.save();

    // Tự động chuyển trạng thái Lịch hẹn thành COMPLETED
    await Appointment.findByIdAndUpdate(appointmentId, { status: 'COMPLETED' });

    res.status(201).json({ message: 'Tạo hồ sơ bệnh án thành công!', record });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


exports.getPatientMedicalRecords = async (req, res) => {
  try {
    const { patientId } = req.params;
    const records = await MedicalRecord.find({ patientId })
      .populate({
        path: 'doctorId',
        populate: [
          { path: 'userId', select: 'fullName email phoneNumber' },
          { path: 'specialtyId', select: 'name iconUrl' }
        ]
      })
      .populate('appointmentId', 'date timeSlot')
      .sort({ createdAt: -1 });

    res.json(records);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};