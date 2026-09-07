const Specialty = require('../models/Specialty');

// ============================================================
// LẤY TẤT CẢ CHUYÊN KHOA
// GET /api/specialties
// ============================================================
const getSpecialties = async (req, res) => {
  try {
    const specialties = await Specialty.find()
      .sort({ createdAt: -1 });

    res.status(200).json(specialties);
  } catch (error) {
    console.error('Lỗi lấy chuyên khoa:', error);

    res.status(500).json({
      message: 'Không thể lấy danh sách chuyên khoa',
      error: error.message,
    });
  }
};

// ============================================================
// LẤY 1 CHUYÊN KHOA
// GET /api/specialties/:id
// ============================================================
const getSpecialtyById = async (req, res) => {
  try {
    const specialty = await Specialty.findById(req.params.id);

    if (!specialty) {
      return res.status(404).json({
        message: 'Không tìm thấy chuyên khoa',
      });
    }

    res.status(200).json(specialty);
  } catch (error) {
    console.error('Lỗi lấy chuyên khoa:', error);

    res.status(500).json({
      message: 'Không thể lấy chuyên khoa',
      error: error.message,
    });
  }
};

// ============================================================
// THÊM CHUYÊN KHOA
// POST /api/specialties
// ============================================================
const createSpecialty = async (req, res) => {
  try {
    const {
      name,
      description,
      status,
      iconUrl,
    } = req.body;

    if (!name || !name.trim()) {
      return res.status(400).json({
        message: 'Tên chuyên khoa là bắt buộc',
      });
    }

    const existingSpecialty = await Specialty.findOne({
      name: name.trim(),
    });

    if (existingSpecialty) {
      return res.status(400).json({
        message: 'Chuyên khoa đã tồn tại',
      });
    }

    const specialty = await Specialty.create({
      name: name.trim(),
      description: description || '',
      status: status || 'ACTIVE',
      iconUrl: iconUrl || '',
    });

    res.status(201).json({
      message: 'Thêm chuyên khoa thành công',
      specialty,
    });
  } catch (error) {
    console.error('Lỗi thêm chuyên khoa:', error);

    res.status(500).json({
      message: 'Không thể thêm chuyên khoa',
      error: error.message,
    });
  }
};

// ============================================================
// SỬA CHUYÊN KHOA
// PUT /api/specialties/:id
// ============================================================
const updateSpecialty = async (req, res) => {
  try {
    const {
      name,
      description,
      status,
      iconUrl,
    } = req.body;

    const specialty = await Specialty.findByIdAndUpdate(
      req.params.id,
      {
        name: name?.trim(),
        description: description || '',
        status: status || 'ACTIVE',
        iconUrl: iconUrl || '',
      },
      {
        new: true,
        runValidators: true,
      }
    );

    if (!specialty) {
      return res.status(404).json({
        message: 'Không tìm thấy chuyên khoa',
      });
    }

    res.status(200).json({
      message: 'Cập nhật chuyên khoa thành công',
      specialty,
    });
  } catch (error) {
    console.error('Lỗi cập nhật chuyên khoa:', error);

    res.status(500).json({
      message: 'Không thể cập nhật chuyên khoa',
      error: error.message,
    });
  }
};

// ============================================================
// XÓA CHUYÊN KHOA
// DELETE /api/specialties/:id
// ============================================================
const deleteSpecialty = async (req, res) => {
  try {
    const specialty = await Specialty.findByIdAndDelete(
      req.params.id
    );

    if (!specialty) {
      return res.status(404).json({
        message: 'Không tìm thấy chuyên khoa',
      });
    }

    res.status(200).json({
      message: 'Xóa chuyên khoa thành công',
    });
  } catch (error) {
    console.error('Lỗi xóa chuyên khoa:', error);

    res.status(500).json({
      message: 'Không thể xóa chuyên khoa',
      error: error.message,
    });
  }
};

module.exports = {
  getSpecialties,
  getSpecialtyById,
  createSpecialty,
  updateSpecialty,
  deleteSpecialty,
};