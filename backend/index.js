// backend/index.js

const express = require('express');
const mongoose = require('mongoose');
require('dotenv').config();
const userRoutes = require('./routes/userRoutes');
const propertyRoutes = require('./routes/propertyRoutes'); // <-- 1. IMPORT PROPERTY ROUTES
const inquiryRoutes = require('./routes/inquiryRoutes'); 

const app = express();
const PORT = process.env.PORT || 3000;

// --- Middlewares ---
app.use(express.json()); // <-- 2. ADD MIDDLEWARE TO PARSE JSON

// --- Database Connection ---
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('✅ MongoDB connected successfully'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// --- API Routes ---
app.use('/api/users', userRoutes); // <-- 3. TELL EXPRESS TO USE YOUR ROUTES
app.use('/api/properties', propertyRoutes);
app.use('/api/inquiries', inquiryRoutes);

// --- A simple route for checking if the server is up ---
app.get('/', (req, res) => {
  res.send('The Real Estate App Backend is running!');
});


app.listen(PORT, () => {
  console.log(`✅ Server is running on http://localhost:${PORT}`);
});