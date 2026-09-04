const Specialty = require('../models/Specialty');


exports.createSpecialty = async (req, res) => {
  try {
    const { name, description, iconUrl } = req.body;

    const existingSpecialty = await Specialty.findOne({ name });
    if (existingSpecialty) {
      return res.status(400).json({ message: 'Chuyên khoa này đã tồn tại!' });
    }

    const specialty = new Specialty({ name, description, iconUrl });
    await specialty.save();

    res.status(201).json({ message: 'Thêm chuyên khoa thành công!', specialty });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAllSpecialties = async (req, res) => {
  try {
    const specialties = await Specialty.find();
    res.json(specialties);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};