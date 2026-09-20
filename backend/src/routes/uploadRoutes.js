const express = require('express');
const router = express.Router();
const uploadLocal = require('../middleware/uploadMiddleware');
const { verifyToken } = require('../middleware/authMiddleware');

router.post('/single', verifyToken, uploadLocal.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: 'Vui lòng chọn file ảnh!' });
  }

  const imageUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;

  res.status(200).json({
    message: 'Tải ảnh lên thành công!',
    url: imageUrl
  });
});

module.exports = router;