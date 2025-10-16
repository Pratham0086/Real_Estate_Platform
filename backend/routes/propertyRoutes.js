// backend/routes/propertyRoutes.js

const express = require('express');
const Property = require('../models/Property');
const authMiddleware = require('../middleware/authMiddleware');
const uploader = require('../config/cloudinary');

const router = express.Router();

// ## CREATE ##
router.post('/', authMiddleware, uploader.array('images'), async (req, res) => {
    try {
        const { title, description, price, location, bedrooms, bathrooms, area, propertyType } = req.body;
        const imageUrls = req.files ? req.files.map(file => file.path) : [];
        const newProperty = new Property({
            title, description, price, location, bedrooms, bathrooms, area, propertyType,
            owner: req.user.id, imageUrls,
        });
        let savedProperty = await newProperty.save();
        savedProperty = await savedProperty.populate('owner', 'name email');
        res.status(201).json(savedProperty);
    } catch (error) {
        res.status(500).json({ message: "Server error creating property.", error: error.message });
    }
});

// ## READ (ALL + SEARCH & FILTER) ##
router.get('/', async (req, res) => {
    try {
        console.log('Received filter query:', req.query); // We keep this for debugging
        const filters = {};

        if (req.query.location) {
            filters.location = { $regex: req.query.location, $options: 'i' };
        }
        if (req.query.propertyType) {
            filters.propertyType = req.query.propertyType;
        }
        if (req.query.minPrice || req.query.maxPrice) {
            filters.price = {};
            if (req.query.minPrice) {
                filters.price.$gte = Number(req.query.minPrice);
            }
            if (req.query.maxPrice) {
                filters.price.$lte = Number(req.query.maxPrice);
            }
        }
        if (req.query.bedrooms) {
            // This ensures we find properties with AT LEAST the selected number of bedrooms
            filters.bedrooms = { $gte: Number(req.query.bedrooms) };
        }
        
        console.log('Applying filters to database:', filters); // Final check on the query object

        const properties = await Property.find(filters).populate('owner', 'name email');
        res.status(200).json(properties);
    } catch (error) {
        res.status(500).json({ message: "Server error fetching properties.", error: error.message });
    }
});

// ## READ (SINGLE) ##
router.get('/:id', async (req, res) => {
    try {
        const property = await Property.findById(req.params.id).populate('owner', 'name email phoneNumber');
        if (!property) return res.status(404).json({ message: 'Property not found' });
        res.status(200).json(property);
    } catch (error) {
        res.status(500).json({ message: "Server error fetching property.", error: error.message });
    }
});

// ## UPDATE ##
router.put('/:id', authMiddleware, uploader.array('images'), async (req, res) => {
    try {
        let property = await Property.findById(req.params.id);
        if (!property) return res.status(404).json({ message: 'Property not found' });
        if (property.owner.toString() !== req.user.id) return res.status(401).json({ message: 'User not authorized' });
        
        const newImageUrls = req.files ? req.files.map(file => file.path) : [];
        Object.assign(property, req.body);
        if (newImageUrls.length > 0) {
            property.imageUrls.push(...newImageUrls);
        }
        
        const updatedProperty = await property.save();
        res.status(200).json(updatedProperty);
    } catch (error) {
        res.status(500).json({ message: "Server error while updating property.", error: error.message });
    }
});

// ## DELETE ##
router.delete('/:id', authMiddleware, async (req, res) => {
    try {
        const property = await Property.findById(req.params.id);
        if (!property) return res.status(404).json({ message: 'Property not found' });
        if (property.owner.toString() !== req.user.id) return res.status(401).json({ message: 'User not authorized' });
        
        await Property.findByIdAndDelete(req.params.id);
        res.status(200).json({ message: 'Property deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: "Server error while deleting property.", error: error.message });
    }
});

module.exports = router;