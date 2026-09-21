const mongoose = require('mongoose');
const Doctor = require('../models/Doctor');
const User = require('../models/User');

// ============================================================
// THÊM BÁC SĨ
// POST /api/doctors
// ============================================================

exports.createDoctor = async (req, res) => {
  try {
    const {
      userId,
      specialtyId,
      price,
      bio,
      experienceYears
    } = req.body;

    // Kiểm tra userId
    if (!userId) {
      return res.status(400).json({
        message: 'Vui lòng chọn tài khoản bác sĩ'
      });
    }

    // Kiểm tra specialtyId
    if (!specialtyId) {
      return res.status(400).json({
        message: 'Vui lòng chọn chuyên khoa'
      });
    }

    // Kiểm tra userId hợp lệ
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({
        message: 'User ID không hợp lệ'
      });
    }

    // Kiểm tra specialtyId hợp lệ
    if (!mongoose.Types.ObjectId.isValid(specialtyId)) {
      return res.status(400).json({
        message: 'Specialty ID không hợp lệ'
      });
    }

    // Kiểm tra user
    const user = await User.findById(userId);

    if (!user) {
      return res.status(400).json({
        message: 'User không tồn tại'
      });
    }

    // User phải có role DOCTOR
    if (user.role !== 'DOCTOR') {
      return res.status(400).json({
        message: 'Tài khoản được chọn không phải là Bác sĩ'
      });
    }

    // Kiểm tra bác sĩ đã có profile chưa
    const existingDoctor = await Doctor.findOne({
      userId
    });

    if (existingDoctor) {
      return res.status(400).json({
        message: 'Bác sĩ này đã có profile trên hệ thống'
      });
    }

    // Kiểm tra giá
    const doctorPrice = Number(price);

    if (Number.isNaN(doctorPrice) || doctorPrice < 0) {
      return res.status(400).json({
        message: 'Giá khám không hợp lệ'
      });
    }

    // Kiểm tra kinh nghiệm
    const doctorExperience =
      Number(experienceYears ?? 0);

    if (
      Number.isNaN(doctorExperience) ||
      doctorExperience < 0
    ) {
      return res.status(400).json({
        message: 'Số năm kinh nghiệm không hợp lệ'
      });
    }

    // Tạo bác sĩ
    const doctor = new Doctor({
      userId,
      specialtyId,
      price: doctorPrice,
      bio: bio ?? '',
      experienceYears: doctorExperience
    });

    await doctor.save();

    // Lấy lại dữ liệu đã populate
    const createdDoctor = await Doctor.findById(
      doctor._id
    )
      .populate(
        'userId',
        'fullName email phoneNumber'
      )
      .populate(
        'specialtyId',
        'name iconUrl'
      );

    return res.status(201).json({
      message: 'Tạo thông tin Bác sĩ thành công',
      doctor: createdDoctor
    });
  } catch (error) {
    console.error(
      'createDoctor error:',
      error
    );

    return res.status(500).json({
      message: error.message
    });
  }
};


// ============================================================
// LẤY TẤT CẢ BÁC SĨ
// GET /api/doctors
// ============================================================

exports.getAllDoctors = async (req, res) => {
  try {
    const doctors = await Doctor.find()
      .populate(
        'userId',
        'fullName email phoneNumber'
      )
      .populate(
        'specialtyId',
        'name iconUrl'
      );

    return res.status(200).json(doctors);
  } catch (error) {
    console.error(
      'getAllDoctors error:',
      error
    );

    return res.status(500).json({
      message: error.message
    });
  }
};


// ============================================================
// LẤY BÁC SĨ THEO CHUYÊN KHOA
// GET /api/doctors/specialty/:specialtyId
// ============================================================

exports.getDoctorsBySpecialty = async (
  req,
  res
) => {
  try {
    const { specialtyId } = req.params;

    if (
      !mongoose.Types.ObjectId.isValid(
        specialtyId
      )
    ) {
      return res.status(400).json({
        message: 'Specialty ID không hợp lệ'
      });
    }

    const doctors = await Doctor.find({
      specialtyId
    })
      .populate(
        'userId',
        'fullName email phoneNumber'
      )
      .populate(
        'specialtyId',
        'name iconUrl'
      );

    return res.status(200).json(doctors);
  } catch (error) {
    console.error(
      'getDoctorsBySpecialty error:',
      error
    );

    return res.status(500).json({
      message: error.message
    });
  }
};


// ============================================================
// SỬA BÁC SĨ
// PUT /api/doctors/:id
// ============================================================

exports.updateDoctor = async (
  req,
  res
) => {
  try {
    const { id } = req.params;

    const {
      specialtyId,
      price,
      bio,
      experienceYears
    } = req.body;

    // Kiểm tra doctor ID
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Doctor ID không hợp lệ'
      });
    }

    // Kiểm tra specialty ID
    if (!specialtyId) {
      return res.status(400).json({
        message: 'Vui lòng chọn chuyên khoa'
      });
    }

    if (
      !mongoose.Types.ObjectId.isValid(
        specialtyId
      )
    ) {
      return res.status(400).json({
        message: 'Specialty ID không hợp lệ'
      });
    }

    // Tìm bác sĩ
    const doctor = await Doctor.findById(id);

    if (!doctor) {
      return res.status(404).json({
        message: 'Không tìm thấy bác sĩ'
      });
    }

    // Kiểm tra giá
    const doctorPrice = Number(price);

    if (
      Number.isNaN(doctorPrice) ||
      doctorPrice < 0
    ) {
      return res.status(400).json({
        message: 'Giá khám không hợp lệ'
      });
    }

    // Kiểm tra kinh nghiệm
    const doctorExperience =
      Number(experienceYears ?? 0);

    if (
      Number.isNaN(doctorExperience) ||
      doctorExperience < 0
    ) {
      return res.status(400).json({
        message: 'Số năm kinh nghiệm không hợp lệ'
      });
    }

    // Cập nhật
    doctor.specialtyId = specialtyId;
    doctor.price = doctorPrice;
    doctor.bio = bio ?? '';
    doctor.experienceYears =
      doctorExperience;

    await doctor.save();

    // Populate dữ liệu sau khi update
    const updatedDoctor =
      await Doctor.findById(id)
        .populate(
          'userId',
          'fullName email phoneNumber'
        )
        .populate(
          'specialtyId',
          'name iconUrl'
        );

    return res.status(200).json({
      message: 'Cập nhật bác sĩ thành công',
      doctor: updatedDoctor
    });
  } catch (error) {
    console.error(
      'updateDoctor error:',
      error
    );

    return res.status(500).json({
      message: error.message
    });
  }
};


// ============================================================
// XÓA BÁC SĨ
// DELETE /api/doctors/:id
// ============================================================

exports.deleteDoctor = async (
  req,
  res
) => {
  try {
    const { id } = req.params;

    // Kiểm tra ID
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Doctor ID không hợp lệ'
      });
    }

    // Tìm bác sĩ
    const doctor =
      await Doctor.findById(id);

    if (!doctor) {
      return res.status(404).json({
        message: 'Không tìm thấy bác sĩ'
      });
    }

    // Chỉ xóa profile bác sĩ
    // KHÔNG xóa User
    await Doctor.findByIdAndDelete(id);

    return res.status(200).json({
      message: 'Xóa hồ sơ bác sĩ thành công'
    });
  } catch (error) {
    console.error(
      'deleteDoctor error:',
      error
    );

    return res.status(500).json({
      message: error.message
    });
  }
};
// ============================================================
// XEM CHI TIẾT BÁC SĨ
// GET /api/doctors/:id
// ============================================================

exports.getDoctorById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        message: 'Doctor ID không hợp lệ'
      });
    }

    const doctor = await Doctor.findById(id)
      .populate(
        'userId',
        'fullName email phoneNumber'
      )
      .populate(
        'specialtyId',
        'name iconUrl'
      );

    if (!doctor) {
      return res.status(404).json({
        message: 'Không tìm thấy bác sĩ'
      });
    }

    return res.status(200).json(doctor);
  } catch (error) {
    console.error(
      'getDoctorById error:',
      error
    );

    return res.status(500).json({
      message: error.message
    });
  }
};
