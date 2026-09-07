const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/db');

dotenv.config();

connectDB();

const app = express();

app.use(cors());
app.use(express.json());

// ===============================
// AUTH
// ===============================
app.use('/api/auth', require('./routes/authRoutes'));

// ===============================
// USERS
// ===============================
app.use('/api/users', require('./routes/userRoutes'));

// ===============================
// SPECIALTIES
// ===============================
app.use(
  '/api/specialties',
  require('./routes/specialtyRoutes')
);

// ===============================
// DOCTORS
// ===============================
app.use(
  '/api/doctors',
  require('./routes/doctorRoutes')
);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});