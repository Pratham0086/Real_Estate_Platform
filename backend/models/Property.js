// backend/models/Property.js

const mongoose = require('mongoose');

const propertySchema = new mongoose.Schema({
    title: {
        type: String,
        required: true,
        trim: true,
    },
    description: {
        type: String,
        required: true,
    },
    price: {
        type: Number,
        required: true,
    },
    location: {
        type: String,
        required: true,
    },
    bedrooms: {
        type: Number,
        required: true,
    },
    bathrooms: {
        type: Number,
        required: true,
    },
    area: {
        type: Number, // in square feet or meters
        required: true,
    },
    propertyType: {
        type: String,
        required: true,
        enum: ['flat', 'house', 'office', 'villa'],
    },
    imageUrls: {
        type: [String], // An array of image URLs
        default: [],
    },
    // This is the link between a Property and its User (owner)
    owner: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'User', // This refers to our 'User' model
    },
}, {
    timestamps: true
});

const Property = mongoose.model('Property', propertySchema);

module.exports = Property;