const mongoose = require('mongoose');
const Review = require('../models/Review');
const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');

// ============================================================
// HELPER: CẬP NHẬT ĐIỂM TRUNG BÌNH & TỔNG ĐÁNH GIÁ CỦA BÁC SĨ
// ============================================================
const updateDoctorRatingStats = async (doctorId) => {
  try {
    const stats = await Review.aggregate([
      { $match: { doctorId: new mongoose.Types.ObjectId(doctorId) } },
      {
        $group: {
          _id: '$doctorId',
          averageRating: { $avg: '$rating' },
          totalReviews: { $sum: 1 }
        }
      }
    ]);

    if (stats.length > 0) {
      await Doctor.findByIdAndUpdate(doctorId, {
        rating: Math.round(stats[0].averageRating * 10) / 10,
        totalReviews: stats[0].totalReviews
      });
    } else {
      // Nếu không còn review nào
      await Doctor.findByIdAndUpdate(doctorId, {
        rating: 5.0,
        totalReviews: 0
      });
    }
  } catch (error) {
    console.error('Lỗi khi tính lại điểm trung bình bác sĩ:', error);
  }
};

// ============================================================
// 1. TẠO ĐÁNH GIÁ (BỆNH NHÂN)
// POST /api/reviews
// ============================================================
exports.createReview = async (req, res) => {
  try {
    const { appointmentId, rating, comment, images, isAnonymous } = req.body;
    const patientId = req.user.id || req.user._id;

    if (!appointmentId || !rating) {
      return res.status(400).json({ message: 'Vui lòng cung cấp lịch hẹn và số sao đánh giá!' });
    }

    const appointment = await Appointment.findById(appointmentId);
    if (!appointment) {
      return res.status(404).json({ message: 'Không tìm thấy lịch hẹn!' });
    }

    // Kiểm tra quyền sở hữu lịch hẹn
    if (appointment.patientId.toString() !== patientId.toString()) {
      return res.status(403).json({ message: 'Bạn không có quyền đánh giá lịch hẹn này!' });
    }

    // Kiểm tra trạng thái đã hoàn thành chưa
    if (appointment.status !== 'COMPLETED') {
      return res.status(400).json({ message: 'Chỉ có thể đánh giá sau khi buổi khám đã hoàn thành!' });
    }

    // Kiểm tra thời hạn 1 năm (365 ngày)
    const appointmentDate = new Date(appointment.updatedAt || appointment.createdAt);
    const oneYearAgo = new Date();
    oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);
    if (appointmentDate < oneYearAgo) {
      return res.status(400).json({ message: 'Đã quá thời hạn 1 năm để đánh giá buổi khám này!' });
    }

    // Kiểm tra xem đã đánh giá chưa
    const existingReview = await Review.findOne({ appointmentId });
    if (existingReview) {
      return res.status(400).json({ message: 'Bạn đã đánh giá cho buổi khám này rồi!' });
    }

    const review = new Review({
      appointmentId,
      patientId,
      doctorId: appointment.doctorId,
      rating: Number(rating),
      comment: comment || '',
      images: Array.isArray(images) ? images : [],
      isAnonymous: Boolean(isAnonymous)
    });

    await review.save();
    await updateDoctorRatingStats(appointment.doctorId);

    res.status(201).json({
      message: 'Cảm ơn bạn đã gửi đánh giá!',
      review
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ============================================================
// 2. CHỈNH SỬA ĐÁNH GIÁ (BỆNH NHÂN)
// PUT /api/reviews/:id
// ============================================================
exports.updateReview = async (req, res) => {
  try {
    const { id } = req.params;
    const { rating, comment, images, isAnonymous } = req.body;
    const patientId = req.user.id || req.user._id;

    const review = await Review.findById(id);
    if (!review) {
      return res.status(404).json({ message: 'Không tìm thấy đánh giá!' });
    }

    if (review.patientId.toString() !== patientId.toString()) {
      return res.status(403).json({ message: 'Bạn không có quyền chỉnh sửa đánh giá này!' });
    }

    if (rating) review.rating = Number(rating);
    if (comment !== undefined) review.comment = comment;
    if (images !== undefined) review.images = images;
    if (isAnonymous !== undefined) review.isAnonymous = Boolean(isAnonymous);

    await review.save();
    await updateDoctorRatingStats(review.doctorId);

    res.json({ message: 'Cập nhật đánh giá thành công!', review });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ============================================================
// 3. XÓA ĐÁNH GIÁ (BỆNH NHÂN TỰ XÓA)
// DELETE /api/reviews/:id
// ============================================================
exports.deleteReview = async (req, res) => {
  try {
    const { id } = req.params;
    const patientId = req.user.id || req.user._id;

    const review = await Review.findById(id);
    if (!review) {
      return res.status(404).json({ message: 'Không tìm thấy đánh giá!' });
    }

    if (review.patientId.toString() !== patientId.toString()) {
      return res.status(403).json({ message: 'Bạn không có quyền xóa đánh giá này!' });
    }

    const doctorId = review.doctorId;
    await Review.findByIdAndDelete(id);
    await updateDoctorRatingStats(doctorId);

    res.json({ message: 'Đã xóa đánh giá thành công!' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ============================================================
// 4. LẤY ĐÁNH GIÁ CỦA 1 BÁC SĨ (DÀNH CHO APP - CHI TIẾT BÁC SĨ)
// GET /api/reviews/doctor/:doctorId
// ============================================================
exports.getDoctorReviews = async (req, res) => {
  try {
    const { doctorId } = req.params;

    const reviews = await Review.find({ doctorId })
      .populate('patientId', 'fullName avatar')
      .sort({ createdAt: -1 });

    // Tính phân bổ sao (star breakdown)
    const breakdown = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
    let totalScore = 0;

    const formattedReviews = reviews.map((r) => {
      const roundedStar = Math.round(r.rating);
      if (breakdown[roundedStar] !== undefined) {
        breakdown[roundedStar] += 1;
      }
      totalScore += r.rating;

      let authorName = 'Bệnh nhân';
      let authorAvatar = '';

      if (r.isAnonymous) {
        authorName = 'Bệnh nhân ẩn danh';
        authorAvatar = '';
      } else if (r.customAuthorName) {
        authorName = r.customAuthorName;
      } else if (r.patientId) {
        authorName = r.patientId.fullName || 'Bệnh nhân';
        authorAvatar = r.patientId.avatar || '';
      }

      return {
        _id: r._id,
        appointmentId: r.appointmentId,
        patientId: r.patientId ? r.patientId._id : null,
        doctorId: r.doctorId,
        rating: r.rating,
        comment: r.comment,
        images: r.images,
        isAnonymous: r.isAnonymous,
        authorName,
        authorAvatar,
        adminReply: r.adminReply,
        createdAt: r.createdAt
      };
    });

    const totalReviews = reviews.length;
    const averageRating = totalReviews > 0 ? Math.round((totalScore / totalReviews) * 10) / 10 : 5.0;

    res.json({
      averageRating,
      totalReviews,
      breakdown,
      reviews: formattedReviews
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ============================================================
// 5. KIỂM TRA REVIEW THEO LỊCH HẸN
// GET /api/reviews/appointment/:appointmentId
// ============================================================
exports.getAppointmentReview = async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const review = await Review.findOne({ appointmentId });
    res.json({ reviewed: !!review, review });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ============================================================
// 6. ADMIN: LẤY TOÀN BỘ ĐÁNH GIÁ (KÈM BỘ LỌC)
// GET /api/reviews/admin/all
// ============================================================
exports.adminGetAllReviews = async (req, res) => {
  try {
    const { doctorId, rating, search } = req.query;
    let filter = {};

    if (doctorId && mongoose.Types.ObjectId.isValid(doctorId)) {
      filter.doctorId = doctorId;
    }
    if (rating) {
      filter.rating = Number(rating);
    }

    const reviews = await Review.find(filter)
      .populate('patientId', 'fullName email phoneNumber avatar')
      .populate({
        path: 'doctorId',
        populate: { path: 'userId', select: 'fullName email' }
      })
      .sort({ createdAt: -1 });

    res.json(reviews);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ============================================================
// 7. ADMIN: TẠO ĐÁNH GIÁ MẪU/TỰ DO
// POST /api/reviews/admin
// ============================================================
exports.adminCreateReview = async (req, res) => {
  try {
    const { doctorId, customAuthorName, rating, comment, images, isAnonymous } = req.body;

    if (!doctorId || !rating) {
      return res.status(400).json({ message: 'Vui lòng chọn bác sĩ và số sao!' });
    }

    const review = new Review({
      doctorId,
      customAuthorName: customAuthorName || 'Khách hàng',
      rating: Number(rating),
      comment: comment || '',
      images: Array.isArray(images) ? images : [],
      isAnonymous: Boolean(isAnonymous)
    });

    await review.save();
    await updateDoctorRatingStats(doctorId);

    res.status(201).json({ message: 'Thêm đánh giá thành công!', review });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ============================================================
// 8. ADMIN: SỬA ĐÁNH GIÁ
// PUT /api/reviews/admin/:id
// ============================================================
exports.adminUpdateReview = async (req, res) => {
  try {
    const { id } = req.params;
    const { rating, comment, customAuthorName, isAnonymous } = req.body;

    const review = await Review.findById(id);
    if (!review) {
      return res.status(404).json({ message: 'Không tìm thấy đánh giá!' });
    }

    if (rating) review.rating = Number(rating);
    if (comment !== undefined) review.comment = comment;
    if (customAuthorName !== undefined) review.customAuthorName = customAuthorName;
    if (isAnonymous !== undefined) review.isAnonymous = Boolean(isAnonymous);

    await review.save();
    await updateDoctorRatingStats(review.doctorId);

    res.json({ message: 'Cập nhật đánh giá thành công!', review });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ============================================================
// 9. ADMIN: PHẢN HỒI ĐÁNH GIÁ (REPLY)
// POST /api/reviews/admin/:id/reply
// ============================================================
exports.adminReplyReview = async (req, res) => {
  try {
    const { id } = req.params;
    const { replyComment } = req.body;

    if (!replyComment) {
      return res.status(400).json({ message: 'Vui lòng nhập nội dung phản hồi!' });
    }

    const review = await Review.findById(id);
    if (!review) {
      return res.status(404).json({ message: 'Không tìm thấy đánh giá!' });
    }

    review.adminReply = {
      comment: replyComment,
      repliedAt: new Date()
    };

    await review.save();
    res.json({ message: 'Đã gửi phản hồi thành công!', review });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ============================================================
// 10. ADMIN: XÓA ĐÁNH GIÁ (HARD DELETE)
// DELETE /api/reviews/admin/:id
// ============================================================
exports.adminDeleteReview = async (req, res) => {
  try {
    const { id } = req.params;

    const review = await Review.findById(id);
    if (!review) {
      return res.status(404).json({ message: 'Không tìm thấy đánh giá!' });
    }

    const doctorId = review.doctorId;
    await Review.findByIdAndDelete(id);
    await updateDoctorRatingStats(doctorId);

    res.json({ message: 'Đã xóa vĩnh viễn đánh giá thành công!' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
