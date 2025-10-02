// backend/routes/propertyRoutes.js

const express = require('express');
const Property = require('../models/Property');
const authMiddleware = require('../middleware/authMiddleware');
const uploader = require('../config/cloudinary');

const router = express.Router();

// ## POST /api/properties
// ## Create a new property listing
router.post('/', authMiddleware, uploader.array('images'), async (req, res) => {
    try {
        const { title, description, price, location, bedrooms, bathrooms, area, propertyType } = req.body;
        const imageUrls = req.files ? req.files.map(file => file.path) : [];

        const newProperty = new Property({
            title, description, price, location, bedrooms, bathrooms, area, propertyType,
            owner: req.user.id,
            imageUrls: imageUrls,
        });

        let savedProperty = await newProperty.save();

        // --- THIS IS THE FIX ---
        // After saving, populate the owner field before sending back to the app
        savedProperty = await savedProperty.populate('owner', 'name email');
        // --------------------

        res.status(201).json(savedProperty);
    } catch (error) {
        res.status(500).json({ message: "Server error while creating property.", error: error.message });
    }
});

// READ (ALL + SEARCH)
router.get('/', async (req, res) => {
    try {
        const filters = {};
        if (req.query.location) {
            filters.location = { $regex: req.query.location, $options: 'i' };
        }
        
        const properties = await Property.find(filters).populate('owner', 'name email');

        // --- DEBUG LOGIC ---
        if (properties.length === 0 && req.query.location) {
            const totalCount = await Property.countDocuments();
            return res.status(200).json([{
                _id: 'DEBUG_MODE',
                title: 'DEBUG: No Results Found',
                location: `You searched for: "${req.query.location}"`,
                price: totalCount,
                owner: { name: 'Total properties in DB' }
            }]);
        }
        // --------------------

        res.status(200).json(properties);
    } catch (error) {
        res.status(500).json({ message: "Server error while fetching properties.", error: error.message });
    }
});


// READ (SINGLE)
router.get('/:id', async (req, res) => {
    try {
        const property = await Property.findById(req.params.id).populate('owner', 'name email');
        if (!property) {
            return res.status(404).json({ message: 'Property not found' });
        }
        res.status(200).json(property);
    } catch (error) {
        res.status(500).json({ message: "Server error while fetching property.", error: error.message });
    }
});

// UPDATE
router.put('/:id', authMiddleware, uploader.array('images'), async (req, res) => {
    // ... your existing update code ...
});

// DELETE
router.delete('/:id', authMiddleware, async (req, res) => {
    // ... your existing delete code ...
});

module.exports = router;