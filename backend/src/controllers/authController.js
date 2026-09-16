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
    // 1. Tìm tài khoản theo email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({
        message: 'Email hoặc mật khẩu không đúng!'
      });
    }
    // 2. Kiểm tra trạng thái tài khoản
    if (user.status !== 'ACTIVE') {
      return res.status(403).json({
        message: 'Tài khoản của bạn đã bị khóa hoặc ngừng hoạt động!'
      });
    }
    // 3. Kiểm tra mật khẩu
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({
        message: 'Email hoặc mật khẩu không đúng!'
      });
    }
    // 4. Tạo JWT Token
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
    // 5. Trả kết quả cho Client (hỗ trợ cả PATIENT, DOCTOR, ADMIN)
    res.status(200).json({
      message: 'Đăng nhập thành công!',
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        phoneNumber: user.phoneNumber || '',
        role: user.role,
        status: user.status
      }
    });
  } catch (error) {
    res.status(500).json({
      message: error.message
    });
  }
};