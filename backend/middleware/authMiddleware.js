// backend/middleware/authMiddleware.js
const jwt = require('jsonwebtoken');
const User = require('../models/user');

const authMiddleware = async (req, res, next) => {
    let token;
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            token = req.headers.authorization.split(' ')[1];

            // --- DEBUG LINES ---
            console.log('--- MIDDLEWARE: Verifying token...');
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            console.log('--- MIDDLEWARE: Token is valid! Decoded User ID:', decoded.id);
            // -------------------

            req.user = await User.findById(decoded.id).select('-password');
            next();
        } catch (error) {
            // --- DEBUG LINE for errors ---
            console.log('--- MIDDLEWARE ERROR: Token verification failed!', error.message);
            res.status(401).json({ message: 'Not authorized, token failed' });
        }
    } else {
        console.log('--- MIDDLEWARE ERROR: No token provided in headers!');
        res.status(401).json({ message: 'Not authorized, no token' });
    }
};

module.exports = authMiddleware;