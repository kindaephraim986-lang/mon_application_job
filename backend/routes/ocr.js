const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { verifyDocumentData, extractDocumentText } = require('../controllers/ocrController');
const { protect } = require('../middleware/auth');

const router = express.Router();

const OCR_TEMP_DIR = path.join(__dirname, '../uploads/ocr_temp');
if (!fs.existsSync(OCR_TEMP_DIR)) {
  fs.mkdirSync(OCR_TEMP_DIR, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, OCR_TEMP_DIR),
  filename: (req, file, cb) => {
    const timestamp = Date.now();
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${timestamp}-${Math.round(Math.random() * 1e9)}${ext}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowedExtensions = ['.jpg', '.jpeg', '.png'];
    const allowedMime = ['image/jpeg', 'image/png'];
    const ext = path.extname(file.originalname).toLowerCase();
    const isAllowedExt = allowedExtensions.includes(ext);
    const isAllowedMime = allowedMime.includes(file.mimetype);

    // Require a matching extension AND a known image mime type
    if (!isAllowedExt || !isAllowedMime) {
      return cb(new Error('Seuls JPG et PNG sont autorisés pour l’OCR'));
    }
    cb(null, true);
  }
});

// Protect OCR endpoints: require authenticated users to use OCR operations
router.post('/extract', protect, upload.single('file'), extractDocumentText);
router.post('/verify', protect, verifyDocumentData);

module.exports = router;
