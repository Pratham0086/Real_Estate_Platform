// backend/middleware/brokerAuthMiddleware.js
const jwt = require('jsonwebtoken');
const User = require('../models/user');

const brokerAuthMiddleware = async (req, res, next) => {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            token = req.headers.authorization.split(' ')[1];
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            req.user = await User.findById(decoded.id).select('-password');

            // --- THE NEW CHECK ---
            if (req.user && req.user.role === 'broker') {
                next(); // User is a broker, proceed
            } else {
                res.status(403).json({ message: 'Forbidden: Access is restricted to brokers' });
            }
            // ---------------------

        } catch (error) {
            res.status(401).json({ message: 'Not authorized, token failed' });
        }
    }

    if (!token) {
        res.status(401).json({ message: 'Not authorized, no token' });
    }
};

module.exports = brokerAuthMiddleware;