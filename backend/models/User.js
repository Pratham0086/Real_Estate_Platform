// backend/models/User.js

const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true,
    },
    email: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        lowercase: true,
    },
    password: {
        type: String,
        required: true,
    },
    phoneNumber: {
        type: String,
        trim: true,
    },
    role: {
        type: String,
        required: true,
        enum: ['customer', 'broker', 'admin'], // Added 'admin' for the future
        default: 'customer',
    },
    // --- Customer-specific fields ---
    userSubType: {
        type: String,
        enum: ['buyer', 'renter', 'both'],
    },
    locationPreference: {
        type: String,
        trim: true,
    },
    // --- Broker-specific fields ---
    companyName: {
        type: String,
        trim: true,
    },
    operatingAreas: {
        type: String, // Can be a comma-separated list of cities/areas
        trim: true,
    },
}, {
    timestamps: true
});

const User = mongoose.model('User', userSchema);

module.exports = User;