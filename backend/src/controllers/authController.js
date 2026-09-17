const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.register = async (req, res) => {
  try {
    const {
      fullName,
      email,
      password,
      phoneNumber,
      role
    } = req.body;

    let user = await User.findOne({ email });

    if (user) {
      return res.status(400).json({
        message: 'Email này đã được sử dụng!'
      });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    user = new User({
      fullName,
      email,
      password: hashedPassword,
      phoneNumber,
      role
    });

    await user.save();

    res.status(201).json({
      message: 'Đăng ký tài khoản thành công!'
    });

  } catch (error) {
    res.status(500).json({
      message: error.message
    });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Tìm tài khoản
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(400).json({
        message: 'Email hoặc mật khẩu không đúng!'
      });
    }

    // Kiểm tra trạng thái tài khoản
    if (user.status !== 'ACTIVE') {
      return res.status(403).json({
        message: 'Tài khoản của bạn đã bị khóa hoặc ngừng hoạt động!'
      });
    }

    // Kiểm tra mật khẩu
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({
        message: 'Email hoặc mật khẩu không đúng!'
      });
    }

    // ==============================
    // CHỈ CHO ADMIN ĐĂNG NHẬP
    // ==============================
    // if (user.role !== 'ADMIN') {
    //   return res.status(403).json({
    //     message: 'Chỉ tài khoản ADMIN mới được đăng nhập vào trang quản trị!'
    //   });
    // }

    // Tạo JWT
    const token = jwt.sign(
      {
        id: user._id,
        role: user.role
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '7d'
      }
    );

    // Trả kết quả
    res.status(200).json({
      message: 'Đăng nhập Admin thành công!',
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        role: user.role
      }
    });

  } catch (error) {
    res.status(500).json({
      message: error.message
    });
  }
};