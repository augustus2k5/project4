const mongoose = require('mongoose');

const MedicalRecord = require('../models/MedicalRecord');
const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');
const User = require('../models/User');

// ============================================================
// HELPER
// ============================================================

const isValidObjectId = (id) => {
  return mongoose.Types.ObjectId.isValid(id);
};

// ============================================================
// LẤY TẤT CẢ HỒ SƠ BỆNH ÁN
// GET /api/medical-records
// ADMIN / DOCTOR
// ============================================================

exports.getAllMedicalRecords = async (req, res) => {
  try {
    const records = await MedicalRecord.find()
      .populate(
        'patientId',
        'fullName email phoneNumber'
      )
      .populate({
        path: 'doctorId',
        populate: [
          {
            path: 'userId',
            select: 'fullName email phoneNumber',
          },
          {
            path: 'specialtyId',
            select: 'name iconUrl',
          },
        ],
      })
      .populate(
        'appointmentId',
        'patientId doctorId date timeSlot reason status'
      )
      .sort({ createdAt: -1 });

    return res.status(200).json(records);
  } catch (error) {
    console.error(
      'getAllMedicalRecords error:',
      error
    );

    return res.status(500).json({
      message: error.message,
    });
  }
};

// ============================================================
// LẤY CHI TIẾT MỘT HỒ SƠ
// GET /api/medical-records/:id
// ============================================================

exports.getMedicalRecordById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        message: 'Medical Record ID không hợp lệ',
      });
    }

    const record = await MedicalRecord.findById(id)
      .populate(
        'patientId',
        'fullName email phoneNumber'
      )
      .populate({
        path: 'doctorId',
        populate: [
          {
            path: 'userId',
            select: 'fullName email phoneNumber',
          },
          {
            path: 'specialtyId',
            select: 'name iconUrl',
          },
        ],
      })
      .populate(
        'appointmentId',
        'patientId doctorId date timeSlot reason status'
      );

    if (!record) {
      return res.status(404).json({
        message: 'Không tìm thấy hồ sơ bệnh án',
      });
    }

    return res.status(200).json(record);
  } catch (error) {
    console.error(
      'getMedicalRecordById error:',
      error
    );

    return res.status(500).json({
      message: error.message,
    });
  }
};

// ============================================================
// LẤY HỒ SƠ THEO BỆNH NHÂN
// GET /api/medical-records/patient/:patientId
// ============================================================

exports.getPatientMedicalRecords = async (req, res) => {
  try {
    const { patientId } = req.params;

    if (!isValidObjectId(patientId)) {
      return res.status(400).json({
        message: 'Patient ID không hợp lệ',
      });
    }

    const records = await MedicalRecord.find({
      patientId,
    })
      .populate(
        'patientId',
        'fullName email phoneNumber'
      )
      .populate({
        path: 'doctorId',
        populate: [
          {
            path: 'userId',
            select: 'fullName email phoneNumber',
          },
          {
            path: 'specialtyId',
            select: 'name iconUrl',
          },
        ],
      })
      .populate(
        'appointmentId',
        'patientId doctorId date timeSlot reason status'
      )
      .sort({ createdAt: -1 });

    return res.status(200).json(records);
  } catch (error) {
    console.error(
      'getPatientMedicalRecords error:',
      error
    );

    return res.status(500).json({
      message: error.message,
    });
  }
};

// ============================================================
// THÊM HỒ SƠ BỆNH ÁN
// POST /api/medical-records
// ADMIN / DOCTOR
// ============================================================

exports.createMedicalRecord = async (req, res) => {
  try {
    const {
      appointmentId,
      patientId,
      doctorId,
      diagnosis,
      notes,
      prescriptions,
    } = req.body;

    // ----------------------------------------------------------
    // Kiểm tra dữ liệu bắt buộc
    // ----------------------------------------------------------

    if (!appointmentId) {
      return res.status(400).json({
        message: 'Vui lòng chọn lịch hẹn',
      });
    }

    if (!patientId) {
      return res.status(400).json({
        message: 'Vui lòng chọn bệnh nhân',
      });
    }

    if (!doctorId) {
      return res.status(400).json({
        message: 'Vui lòng chọn bác sĩ',
      });
    }

    if (!diagnosis || !diagnosis.trim()) {
      return res.status(400).json({
        message: 'Vui lòng nhập chẩn đoán',
      });
    }

    // ----------------------------------------------------------
    // Kiểm tra ObjectId
    // ----------------------------------------------------------

    if (!isValidObjectId(appointmentId)) {
      return res.status(400).json({
        message: 'Appointment ID không hợp lệ',
      });
    }

    if (!isValidObjectId(patientId)) {
      return res.status(400).json({
        message: 'Patient ID không hợp lệ',
      });
    }

    if (!isValidObjectId(doctorId)) {
      return res.status(400).json({
        message: 'Doctor ID không hợp lệ',
      });
    }

    // ----------------------------------------------------------
    // Kiểm tra Patient
    // ----------------------------------------------------------

    const patient = await User.findById(patientId);

    if (!patient) {
      return res.status(404).json({
        message: 'Không tìm thấy bệnh nhân',
      });
    }

    if (patient.role !== 'PATIENT') {
      return res.status(400).json({
        message: 'Tài khoản được chọn không phải bệnh nhân',
      });
    }

    // ----------------------------------------------------------
    // Kiểm tra Doctor
    // ----------------------------------------------------------

    const doctor = await Doctor.findById(doctorId);

    if (!doctor) {
      return res.status(404).json({
        message: 'Không tìm thấy bác sĩ',
      });
    }

    // ----------------------------------------------------------
    // Kiểm tra Appointment
    // ----------------------------------------------------------

    const appointment =
      await Appointment.findById(appointmentId);

    if (!appointment) {
      return res.status(404).json({
        message: 'Không tìm thấy lịch hẹn',
      });
    }

    // ----------------------------------------------------------
    // Kiểm tra lịch hẹn có đúng bệnh nhân / bác sĩ
    // ----------------------------------------------------------

    if (
      appointment.patientId.toString() !==
      patientId.toString()
    ) {
      return res.status(400).json({
        message:
          'Bệnh nhân không khớp với lịch hẹn',
      });
    }

    if (
      appointment.doctorId.toString() !==
      doctorId.toString()
    ) {
      return res.status(400).json({
        message:
          'Bác sĩ không khớp với lịch hẹn',
      });
    }

    // ----------------------------------------------------------
    // Một lịch hẹn chỉ có một hồ sơ
    // ----------------------------------------------------------

    const existingRecord =
      await MedicalRecord.findOne({
        appointmentId,
      });

    if (existingRecord) {
      return res.status(400).json({
        message:
          'Lịch hẹn này đã có hồ sơ bệnh án',
      });
    }

    // ----------------------------------------------------------
    // Chuẩn hóa prescriptions
    // ----------------------------------------------------------

    const normalizedPrescriptions =
      Array.isArray(prescriptions)
        ? prescriptions.map((item) => ({
            drugName: String(
              item.drugName ?? ''
            ).trim(),

            quantity: Number(
              item.quantity ?? 1
            ),

            dosage: String(
              item.dosage ?? ''
            ).trim(),
          }))
        : [];

    // ----------------------------------------------------------
    // Tạo record
    // ----------------------------------------------------------

    const record = new MedicalRecord({
      appointmentId,
      patientId,
      doctorId,
      diagnosis: diagnosis.trim(),
      notes: notes
        ? String(notes).trim()
        : '',
      prescriptions:
        normalizedPrescriptions,
    });

    await record.save();

    // ----------------------------------------------------------
    // Hoàn thành lịch hẹn
    // ----------------------------------------------------------

    if (appointment.status !== 'CANCELLED') {
      appointment.status = 'COMPLETED';
      await appointment.save();
    }

    // ----------------------------------------------------------
    // Populate lại dữ liệu
    // ----------------------------------------------------------

    const createdRecord =
      await MedicalRecord.findById(record._id)
        .populate(
          'patientId',
          'fullName email phoneNumber'
        )
        .populate({
          path: 'doctorId',
          populate: [
            {
              path: 'userId',
              select:
                'fullName email phoneNumber',
            },
            {
              path: 'specialtyId',
              select:
                'name iconUrl',
            },
          ],
        })
        .populate(
          'appointmentId',
          'patientId doctorId date timeSlot reason status'
        );

    return res.status(201).json({
      message:
        'Tạo hồ sơ bệnh án thành công',
      record: createdRecord,
    });
  } catch (error) {
    console.error(
      'createMedicalRecord error:',
      error
    );

    return res.status(500).json({
      message: error.message,
    });
  }
};

// ============================================================
// SỬA HỒ SƠ BỆNH ÁN
// PUT /api/medical-records/:id
// ADMIN / DOCTOR
// ============================================================

exports.updateMedicalRecord = async (req, res) => {
  try {
    const { id } = req.params;

    const {
      patientId,
      doctorId,
      appointmentId,
      diagnosis,
      notes,
      prescriptions,
    } = req.body;

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        message:
          'Medical Record ID không hợp lệ',
      });
    }

    const record =
      await MedicalRecord.findById(id);

    if (!record) {
      return res.status(404).json({
        message:
          'Không tìm thấy hồ sơ bệnh án',
      });
    }

    // ----------------------------------------------------------
    // Kiểm tra Patient
    // ----------------------------------------------------------

    if (patientId) {
      if (!isValidObjectId(patientId)) {
        return res.status(400).json({
          message:
            'Patient ID không hợp lệ',
        });
      }

      const patient =
        await User.findById(patientId);

      if (!patient) {
        return res.status(404).json({
          message:
            'Không tìm thấy bệnh nhân',
        });
      }

      if (patient.role !== 'PATIENT') {
        return res.status(400).json({
          message:
            'Tài khoản được chọn không phải bệnh nhân',
        });
      }

      record.patientId = patientId;
    }

    // ----------------------------------------------------------
    // Kiểm tra Doctor
    // ----------------------------------------------------------

    if (doctorId) {
      if (!isValidObjectId(doctorId)) {
        return res.status(400).json({
          message:
            'Doctor ID không hợp lệ',
        });
      }

      const doctor =
        await Doctor.findById(doctorId);

      if (!doctor) {
        return res.status(404).json({
          message:
            'Không tìm thấy bác sĩ',
        });
      }

      record.doctorId = doctorId;
    }

    // ----------------------------------------------------------
    // Appointment
    // ----------------------------------------------------------

    if (appointmentId) {
      if (!isValidObjectId(appointmentId)) {
        return res.status(400).json({
          message:
            'Appointment ID không hợp lệ',
        });
      }

      const appointment =
        await Appointment.findById(
          appointmentId
        );

      if (!appointment) {
        return res.status(404).json({
          message:
            'Không tìm thấy lịch hẹn',
        });
      }

      // Nếu đổi appointment thì kiểm tra
      // appointment đó chưa thuộc record khác

      if (
        appointmentId.toString() !==
        record.appointmentId.toString()
      ) {
        const existingRecord =
          await MedicalRecord.findOne({
            appointmentId,
            _id: { $ne: id },
          });

        if (existingRecord) {
          return res.status(400).json({
            message:
              'Lịch hẹn này đã có hồ sơ bệnh án khác',
          });
        }

        record.appointmentId =
          appointmentId;
      }
    }

    // ----------------------------------------------------------
    // Diagnosis
    // ----------------------------------------------------------

    if (
      diagnosis !== undefined
    ) {
      if (!String(diagnosis).trim()) {
        return res.status(400).json({
          message:
            'Chẩn đoán không được để trống',
        });
      }

      record.diagnosis =
        String(diagnosis).trim();
    }

    // ----------------------------------------------------------
    // Notes
    // ----------------------------------------------------------

    if (notes !== undefined) {
      record.notes =
        String(notes).trim();
    }

    // ----------------------------------------------------------
    // Prescriptions
    // ----------------------------------------------------------

    if (prescriptions !== undefined) {
      if (!Array.isArray(prescriptions)) {
        return res.status(400).json({
          message:
            'Danh sách đơn thuốc không hợp lệ',
        });
      }

      record.prescriptions =
        prescriptions.map((item) => ({
          drugName: String(
            item.drugName ?? ''
          ).trim(),

          quantity: Number(
            item.quantity ?? 1
          ),

          dosage: String(
            item.dosage ?? ''
          ).trim(),
        }));
    }

    await record.save();

    const updatedRecord =
      await MedicalRecord.findById(id)
        .populate(
          'patientId',
          'fullName email phoneNumber'
        )
        .populate({
          path: 'doctorId',
          populate: [
            {
              path: 'userId',
              select:
                'fullName email phoneNumber',
            },
            {
              path: 'specialtyId',
              select:
                'name iconUrl',
            },
          ],
        })
        .populate(
          'appointmentId',
          'patientId doctorId date timeSlot reason status'
        );

    return res.status(200).json({
      message:
        'Cập nhật hồ sơ bệnh án thành công',
      record: updatedRecord,
    });
  } catch (error) {
    console.error(
      'updateMedicalRecord error:',
      error
    );

    return res.status(500).json({
      message: error.message,
    });
  }
};

// ============================================================
// XÓA HỒ SƠ BỆNH ÁN
// DELETE /api/medical-records/:id
// ADMIN / DOCTOR
// ============================================================

exports.deleteMedicalRecord = async (req, res) => {
  try {
    const { id } = req.params;

    if (!isValidObjectId(id)) {
      return res.status(400).json({
        message:
          'Medical Record ID không hợp lệ',
      });
    }

    const record =
      await MedicalRecord.findById(id);

    if (!record) {
      return res.status(404).json({
        message:
          'Không tìm thấy hồ sơ bệnh án',
      });
    }

    await MedicalRecord.findByIdAndDelete(id);

    return res.status(200).json({
      message:
        'Xóa hồ sơ bệnh án thành công',
    });
  } catch (error) {
    console.error(
      'deleteMedicalRecord error:',
      error
    );

    return res.status(500).json({
      message: error.message,
    });
  }
};