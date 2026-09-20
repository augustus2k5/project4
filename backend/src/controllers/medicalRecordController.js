const MedicalRecord = require('../models/MedicalRecord');
const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');

exports.createMedicalRecord = async (req, res) => {
  try {
    const { appointmentId, patientId, diagnosis, notes, prescriptions } = req.body;

    const doctor = await Doctor.findOne({ userId: req.user.id });
    if (!doctor) {
      return res.status(404).json({ message: 'Không tìm thấy thông tin Bác sĩ!' });
    }

    const existingRecord = await MedicalRecord.findOne({ appointmentId });
    if (existingRecord) {
      return res.status(400).json({ message: 'Lịch hẹn này đã có hồ sơ bệnh án!' });
    }

    const record = new MedicalRecord({
      appointmentId,
      patientId,
      doctorId: doctor._id, 
      diagnosis,
      notes,
      prescriptions
    });

    await record.save();

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