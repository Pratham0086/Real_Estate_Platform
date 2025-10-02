// backend/models/Inquiry.js
const mongoose = require('mongoose');

const propertyDetailsSchema = new mongoose.Schema({
    title: String,
    description: String,
    price: Number,
    location: String,
    bedrooms: Number,
    bathrooms: Number,
    area: Number,
    propertyType: String,
}, { _id: false });

const inquirySchema = new mongoose.Schema({
    inquiryType: {
        type: String,
        enum: ['property_contact', 'listing_request'],
        default: 'property_contact',
    },
    property: { // For 'property_contact' type
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Property',
    },
    propertyDetails: propertyDetailsSchema, // For 'listing_request' type
    inquirer: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    // Changed to an array to support multiple brokers
    owners: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
    }],
    message: String,
    status: {
        type: String,
        enum: ['new', 'contacted', 'closed'],
        default: 'new',
    },
}, {
    timestamps: true
});

const Inquiry = mongoose.model('Inquiry', inquirySchema);

module.exports = Inquiry;