const Review = require('../models/Review');
const Appointment = require('../models/Appointment');

exports.createReview = async (req, res) => {
  try {
    const { appointmentId, patientId, doctorId, rating, comment } = req.body;

    const appointment = await Appointment.findById(appointmentId);
    if (!appointment || appointment.status !== 'COMPLETED') {
      return res.status(400).json({ 
        message: 'Chỉ có thể đánh giá sau khi buổi khám đã hoàn thành!' 
      });
    }

    const existingReview = await Review.findOne({ appointmentId });
    if (existingReview) {
      return res.status(400).json({ message: 'Bạn đã đánh giá cho buổi khám này rồi!' });
    }

    const review = new Review({
      appointmentId,
      patientId,
      doctorId,
      rating,
      comment
    });

    await review.save();
    res.status(201).json({ message: 'Cảm ơn bạn đã gửi đánh giá!', review });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


exports.getDoctorReviews = async (req, res) => {
  try {
    const { doctorId } = req.params;
    const reviews = await Review.find({ doctorId })
      .populate('patientId', 'fullName')
      .sort({ createdAt: -1 });

    res.json(reviews);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};