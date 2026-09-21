const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const path = require('path');

dotenv.config();

connectDB();

const app = express();

app.use(cors());
app.use(express.json());


app.use('/api/auth', require('./routes/authRoutes'));

app.use('/api/users', require('./routes/userRoutes'));

app.use(
  '/api/patients',
  require('./routes/patientRoutes')
);
app.use(
  '/api/specialties',
  require('./routes/specialtyRoutes')
);

app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

app.use('/api/upload', require('./routes/uploadRoutes'));

app.use(
  '/api/doctors',
  require('./routes/doctorRoutes')
);

app.use('/api/medical-records', require('./routes/medicalRecordRoutes'));

app.use('/api/appointments', require('./routes/appointmentRoutes'));
app.use('/api/patient/appointments', require('./routes/appointmentRoutes'));
app.use('/api/reviews', require('./routes/reviewRoutes'));

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});