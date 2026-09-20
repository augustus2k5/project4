const User = require("../models/User");

const bcrypt = require('bcryptjs');


const getUsers = async (req, res) => {
    try {
        const users = await User.find().select("-password");

        res.status(200).json(users);
    } catch (error) {
        console.error(error);

        res.status(500).json({
            message: "Lỗi khi lấy danh sách user"
        });
    }
};


const updateProfile = async (req, res) => {
  try {
    const { fullName, phoneNumber, avatar } = req.body;
    

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
    }

    if (fullName) user.fullName = fullName;
    if (phoneNumber) user.phoneNumber = phoneNumber;
    if (avatar) user.avatar = avatar;

    await user.save();

    res.status(200).json({
      message: 'Cập nhật thông tin cá nhân thành công!',

      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        avatar: user.avatar,

        role: user.role
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;

    if (!oldPassword || !newPassword) {
      return res.status(400).json({ message: 'Vui lòng nhập mật khẩu cũ và mật khẩu mới!' });
    }

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
    }

   
    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Mật khẩu cũ không chính xác!' });
    }

    
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);
    await user.save();

    res.status(200).json({ message: 'Đổi mật khẩu thành công!' });
  } catch (error) {
    res.status(500).json({ message: error.message });

  }
};

module.exports = {
    getUsers,

    updateProfile,
    changePassword
};