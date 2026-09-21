const Patient = require('../models/Patient');
const User = require('../models/User');

// ============================================================
// HÀM FORMAT PATIENT
// Chuyển dữ liệu MongoDB thành dạng Flutter dễ sử dụng
// ============================================================
const formatPatient = (patient) => {
  const user = patient.userId;

  return {
    _id: patient._id,

    // QUAN TRỌNG:
    // Flutter cần userId là String
    userId: user?._id
      ? user._id.toString()
      : patient.userId?.toString(),

    patientCode: patient.patientCode,

    dateOfBirth: patient.dateOfBirth,

    gender: patient.gender,

    identityCard: patient.identityCard || '',

    address: patient.address || '',

    medicalHistory: patient.medicalHistory || '',

    allergies: patient.allergies || '',

    // Thông tin User
    fullName: user?.fullName || '',

    email: user?.email || '',

    phoneNumber: user?.phoneNumber || '',

    role: user?.role || 'PATIENT',

    status: user?.status || 'ACTIVE',

    createdAt: patient.createdAt,

    updatedAt: patient.updatedAt,
  };
};

// ============================================================
// LẤY TẤT CẢ BỆNH NHÂN
// GET /api/patients
// ============================================================
const getPatients = async (req, res) => {
  try {
    const patients = await Patient.find()
      .populate(
        'userId',
        'fullName email phoneNumber role status'
      )
      .sort({ createdAt: -1 });

    const result = patients.map(formatPatient);

    res.status(200).json(result);
  } catch (error) {
    console.error('getPatients error:', error);

    res.status(500).json({
      message: 'Không thể lấy danh sách bệnh nhân',
      error: error.message,
    });
  }
};

// ============================================================
// LẤY CHI TIẾT BỆNH NHÂN
// GET /api/patients/:id
// ============================================================
const getPatientById = async (req, res) => {
  try {
    const patient = await Patient.findById(req.params.id)
      .populate(
        'userId',
        'fullName email phoneNumber role status'
      );

    if (!patient) {
      return res.status(404).json({
        message: 'Không tìm thấy bệnh nhân',
      });
    }

    res.status(200).json(formatPatient(patient));
  } catch (error) {
    console.error('getPatientById error:', error);

    res.status(500).json({
      message: 'Không thể lấy thông tin bệnh nhân',
      error: error.message,
    });
  }
};

// ============================================================
// TẠO HỒ SƠ BỆNH NHÂN
// POST /api/patients
// ============================================================
const createPatient = async (req, res) => {
  try {
    const {
      userId,
      patientCode,
      dateOfBirth,
      gender,
      identityCard,
      address,
      medicalHistory,
      allergies,
    } = req.body;

    // --------------------------------------------------------
    // KIỂM TRA USER ID
    // --------------------------------------------------------
    if (!userId) {
      return res.status(400).json({
        message: 'Vui lòng chọn tài khoản bệnh nhân',
      });
    }

    // --------------------------------------------------------
    // TÌM USER
    // --------------------------------------------------------
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({
        message: 'Không tìm thấy tài khoản',
      });
    }

    // --------------------------------------------------------
    // KIỂM TRA ROLE
    // --------------------------------------------------------
    if (user.role !== 'PATIENT') {
      return res.status(400).json({
        message: 'Tài khoản được chọn không phải bệnh nhân',
      });
    }

    // --------------------------------------------------------
    // MỖI USER CHỈ CÓ 1 HỒ SƠ
    // --------------------------------------------------------
    const existingPatient = await Patient.findOne({
      userId: userId,
    });

    if (existingPatient) {
      return res.status(400).json({
        message: 'Tài khoản này đã có hồ sơ bệnh nhân',
      });
    }

    // --------------------------------------------------------
    // KIỂM TRA MÃ BỆNH NHÂN
    // --------------------------------------------------------
    if (!patientCode || patientCode.trim() === '') {
      return res.status(400).json({
        message: 'Vui lòng nhập mã bệnh nhân',
      });
    }

    const existingCode = await Patient.findOne({
      patientCode: patientCode.trim(),
    });

    if (existingCode) {
      return res.status(400).json({
        message: 'Mã bệnh nhân đã tồn tại',
      });
    }

    // --------------------------------------------------------
    // TẠO PATIENT
    // --------------------------------------------------------
    const patient = await Patient.create({
      userId: userId,

      patientCode: patientCode.trim(),

      dateOfBirth: dateOfBirth
        ? dateOfBirth
        : null,

      gender: gender || 'OTHER',

      identityCard:
        identityCard || '',

      address:
        address || '',

      medicalHistory:
        medicalHistory || '',

      allergies:
        allergies || '',
    });

    // --------------------------------------------------------
    // LẤY LẠI + POPULATE USER
    // --------------------------------------------------------
    const result = await Patient.findById(
      patient._id
    ).populate(
      'userId',
      'fullName email phoneNumber role status'
    );

    // --------------------------------------------------------
    // TRẢ VỀ
    // --------------------------------------------------------
    res.status(201).json(
      formatPatient(result)
    );
  } catch (error) {
    console.error(
      'createPatient error:',
      error
    );

    res.status(500).json({
      message: 'Không thể tạo hồ sơ bệnh nhân',
      error: error.message,
    });
  }
};

// ============================================================
// CẬP NHẬT BỆNH NHÂN
// PUT /api/patients/:id
// ============================================================
// ============================================================
// UPDATE PATIENT
// PUT /api/patients/:id
// ============================================================

const updatePatient = async (req, res) => {
  try {
    const {
      patientCode,
      dateOfBirth,
      gender,
      identityCard,
      address,
      medicalHistory,
      allergies,
      status,
    } = req.body;

    const patient = await Patient.findById(req.params.id);

    if (!patient) {
      return res.status(404).json({
        message: 'Không tìm thấy bệnh nhân',
      });
    }

    // Cập nhật thông tin hồ sơ bệnh nhân
    patient.patientCode = patientCode;
    patient.dateOfBirth = dateOfBirth || null;
    patient.gender = gender;
    patient.identityCard = identityCard || '';
    patient.address = address || '';
    patient.medicalHistory = medicalHistory || '';
    patient.allergies = allergies || '';

    await patient.save();

    // =====================================================
    // CẬP NHẬT TRẠNG THÁI TÀI KHOẢN USER
    // =====================================================

    if (status) {
      const allowedStatus = [
        'ACTIVE',
        'INACTIVE',
        'BLOCKED',
      ];

      if (!allowedStatus.includes(status.toUpperCase())) {
        return res.status(400).json({
          message: 'Trạng thái không hợp lệ',
        });
      }

      const user = await User.findById(patient.userId);

      if (!user) {
        return res.status(404).json({
          message: 'Không tìm thấy tài khoản bệnh nhân',
        });
      }

      user.status = status.toUpperCase();

      await user.save();
    }

    // Lấy lại dữ liệu mới nhất
    const updatedPatient = await Patient.findById(req.params.id)
      .populate(
        'userId',
        'fullName email phoneNumber role status',
      );

    return res.status(200).json({
      message: 'Cập nhật bệnh nhân thành công',
      patient: updatedPatient,
    });
  } catch (error) {
    console.error('Update patient error:', error);

    return res.status(500).json({
      message: 'Lỗi server',
      error: error.message,
    });
  }
};

// ============================================================
// XÓA HỒ SƠ BỆNH NHÂN
// DELETE /api/patients/:id
// ============================================================
const deletePatient = async (req, res) => {
  try {
    const patient =
      await Patient.findById(
        req.params.id
      );

    if (!patient) {
      return res.status(404).json({
        message: 'Không tìm thấy bệnh nhân',
      });
    }

    // Chỉ xóa hồ sơ Patient
    // Không xóa User
    await Patient.findByIdAndDelete(
      req.params.id
    );

    res.status(200).json({
      message:
        'Xóa hồ sơ bệnh nhân thành công. Tài khoản vẫn được giữ lại.',
    });
  } catch (error) {
    console.error(
      'deletePatient error:',
      error
    );

    res.status(500).json({
      message: 'Không thể xóa bệnh nhân',
      error: error.message,
    });
  }
};

// ============================================================
// EXPORT
// ============================================================
module.exports = {
  getPatients,
  getPatientById,
  createPatient,
  updatePatient,
  deletePatient,
};