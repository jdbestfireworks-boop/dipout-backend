const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// AUTH ROUTES
router.post('/register', userController.register);
router.post('/login', userController.login);
router.get('/me', userController.me);   // <-- REQUIRED FOR YOUR FRONTEND

// USER ROUTES
router.get('/:id', userController.getUser);

// OTP ROUTES
router.post('/send-otp', userController.sendOtp);
router.post('/verify-otp', userController.verifyOtp);
router.post('/resend-otp', userController.resendOtp);

module.exports = router;
