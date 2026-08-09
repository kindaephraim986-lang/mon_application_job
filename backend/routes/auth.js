const express = require('express');
const { register, login, getMe, updateProfile } = require('../controllers/authController');
const { protect } = require('../middleware/auth');
const { validateRegister, validateProfileUpdate } = require('../middleware/validation');

const router = express.Router();

router.post('/register', validateRegister, register);
router.post('/login', login);
router.get('/me', protect, getMe);
router.put('/profile', protect, validateProfileUpdate, updateProfile);

module.exports = router;
