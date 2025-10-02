// backend/routes/inquiryRoutes.js
const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const Inquiry = require('../models/Inquiry');
const Property = require('../models/Property');

const router = express.Router();

// This route now handles both types of inquiries
router.post('/', authMiddleware, async (req, res) => {
    try {
        const { inquiryType, propertyId, message, propertyDetails, brokerIds } = req.body;
        
        const inquiryData = {
            inquirer: req.user.id,
            inquiryType: inquiryType,
        };

        if (inquiryType === 'property_contact') {
            const property = await Property.findById(propertyId);
            if (!property) return res.status(404).json({ message: 'Property not found' });
            inquiryData.property = propertyId;
            inquiryData.owners = [property.owner]; // The owner is an array with one ID
            inquiryData.message = message;
        } 
        else if (inquiryType === 'listing_request') {
            if (!brokerIds || brokerIds.length === 0) return res.status(400).json({ message: 'At least one broker must be selected.'});
            inquiryData.propertyDetails = propertyDetails;
            inquiryData.owners = brokerIds; // Assign to all selected brokers
        }

        const newInquiry = new Inquiry(inquiryData);
        await newInquiry.save();
        res.status(201).json({ message: 'Request submitted successfully.' });

    } catch (error) {
        res.status(500).json({ message: 'Server error.', error: error.message });
    }
});

// This route now searches the 'owners' array
router.get('/my-inquiries', authMiddleware, async (req, res) => {
    try {
        const inquiries = await Inquiry.find({ owners: req.user.id }) // Checks if user's ID is in the 'owners' array
            .populate('property', 'title')
            .populate('inquirer', 'name email phoneNumber');

        res.status(200).json(inquiries);
    } catch (error) {
        res.status(500).json({ message: 'Server error fetching inquiries.', error: error.message });
    }
});

module.exports = router;