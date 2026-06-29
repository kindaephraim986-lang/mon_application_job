const express = require('express');
const router = express.Router();
const multer = require('multer');
const profilePhotoService = require('../services/profilePhotoService');

const storage = multer.memoryStorage();
const upload = multer({ storage, limits: { fileSize: 10 * 1024 * 1024 } });

// Dev-only upload route to test saveProfilePhoto without auth
router.post('/dev/test-upload', upload.single('photo'), async (req, res) => {
  try {
    if (!req.file || !req.file.buffer) {
      return res.status(400).json({ success: false, message: 'No file provided' });
    }

    // Use a fixed test candidatId (1) when running locally
    const candidatId = 1;
    const result = await profilePhotoService.saveProfilePhoto(candidatId, req.file.buffer, req.file.originalname);
    return res.json({ success: true, result });
  } catch (error) {
    console.error('Dev test upload error:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
