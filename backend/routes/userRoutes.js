// backend/routes/userRoutes.js

const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const brokerAuthMiddleware = require('../middleware/brokerAuthMiddleware');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// --- Public Routes ---

router.post('/register', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Check if user already exists
        const existingUser = await User.findOne({ email: email });
        if (existingUser) {
            return res.status(400).json({ message: "An account with this email already exists." });
        }

        // Hash the password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Create a new user with all the data sent from the frontend
        const newUser = new User({
            ...req.body, // Use all fields from the request body
            password: hashedPassword,
        });

        const savedUser = await newUser.save();
        res.status(201).json({ message: "User registered successfully!", userId: savedUser._id });

    } catch (error) {
        res.status(500).json({ message: "Server error during registration.", error: error.message });
    }
});

// in backend/routes/userRoutes.js

router.post('/login', async (req, res) => {
  try {
    const { loginId, password, role } = req.body; // loginId can be email or phone

    // 1. Determine if loginId is an email or a phone number
    const isEmail = loginId.includes('@');

    // 2. Build the query to find the user
    const query = {
      role: role, // We also check the role to distinguish between a customer and broker
    };

    if (isEmail) {
      query.email = loginId.toLowerCase();
    } else {
      query.phoneNumber = loginId;
    }

    const user = await User.findOne(query);

    if (!user) {
      return res.status(400).json({ message: "Invalid credentials or role." });
    }

    // 3. Compare password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid credentials or role." });
    }

    // 4. Create JWT and send response (no changes here)
    const payload = { id: user._id, name: user.name, role: user.role };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1d' });
    res.status(200).json({
      message: "Logged in successfully!",
      token: token,
      user: { id: user._id, name: user.name, email: user.email, role: user.role }
    });

  } catch (error) {
    res.status(500).json({ message: "Server error during login.", error: error.message });
  }
});

// --- Broker-Only Route ---
// This is the route that was missing from your file
router.get('/customers', brokerAuthMiddleware, async (req, res) => {
    try {
        const customers = await User.find({ role: 'customer' }).select('-password');
        res.status(200).json(customers);
    } catch (error) {
        res.status(500).json({ message: "Server error fetching customers.", error: error.message });
    }
});

// ## GET /api/users/brokers
// ## Get all users with the 'broker' role
router.get('/brokers', authMiddleware, async (req, res) => {
    try {
        const brokers = await User.find({ role: 'broker' }).select('name companyName operatingAreas');
        res.status(200).json(brokers);
    } catch (error) {
        res.status(500).json({ message: "Server error fetching brokers.", error: error.message });
    }
});

module.exports = router;