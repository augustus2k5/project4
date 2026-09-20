const User = require("../models/User");

const bcrypt = require("bcryptjs");

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
    const userId = req.user.id; // Lấy ID từ Token
    const { fullName, email, phoneNumber, currentPassword, newPassword, avatar } = req.body;

    // Bắt buộc phải có mật khẩu hiện tại

    if (!currentPassword) {
      return res.status(400).json({ message: "Vui lòng nhập mật khẩu hiện tại để xác nhận thay đổi!" });
    }
    // Tìm user trong database
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "Không tìm thấy người dùng!" });
    }

    // Kiểm tra mật khẩu hiện tại

    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Mật khẩu hiện tại không chính xác!" });
    }

    // Nếu người dùng đổi Email -> Kiểm tra xem email mới đã có ai dùng chưa

    if (email && email.toLowerCase() !== user.email) {
      const emailExists = await User.findOne({ 
        email: email.toLowerCase(), 
        _id: { $ne: userId } 
      });
      if (emailExists) {

        return res.status(400).json({ message: "Email mới này đã được người khác sử dụng!" });

      }
      user.email = email.toLowerCase();
    }
    // Cập nhật Họ tên, SĐT, Avatar
    if (fullName) user.fullName = fullName;
    if (phoneNumber !== undefined) user.phoneNumber = phoneNumber;
    if (avatar !== undefined) user.avatar = avatar;

    // Nếu người dùng đổi mật khẩu mới

    if (newPassword && newPassword.trim().length > 0) {
      if (newPassword.length < 6) {
        return res.status(400).json({ message: "Mật khẩu mới phải có tối thiểu 6 ký tự!" });
      }
      const salt = await bcrypt.genSalt(10);
      user.password = await bcrypt.hash(newPassword, salt);
    }
    await user.save();
    res.status(200).json({
      message: "Cập nhật hồ sơ thành công!",
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
    console.error("Lỗi updateProfile:", error);
    res.status(500).json({ message: error.message || "Lỗi khi cập nhật hồ sơ!" });
  }
};
const changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;
    if (!oldPassword || !newPassword) {
      return res.status(400).json({ message: "Vui lòng nhập mật khẩu cũ và mật khẩu mới!" });
    }
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: "Không tìm thấy người dùng!" });
    }
    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Mật khẩu cũ không chính xác!" });
    }
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);
    await user.save();
    res.status(200).json({ message: "Đổi mật khẩu thành công!" });
  }  catch (error) {
    res.status(500).json({ message: error.message });
  }
    };




module.exports = {
    getUsers,
    updateProfile,
    changePassword

};