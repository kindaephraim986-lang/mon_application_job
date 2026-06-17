const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { protect } = require('../middleware/auth');

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, path.join(__dirname, '../uploads'));
    },
    filename: (req, file, cb) => {
        const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, unique + path.extname(file.originalname));
    }
});

const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB max
    fileFilter: (req, file, cb) => {
        const allowedExt = /jpeg|jpg|png|gif|pdf|doc|docx/;
        const allowedMime = /jpeg|jpg|png|gif|pdf|msword|officedocument/;
        const ext = allowedExt.test(path.extname(file.originalname).toLowerCase());
        const mime = allowedMime.test(file.mimetype);
        if (ext && mime) {
            cb(null, true);
        } else {
            cb(new Error('Seuls les fichiers image et PDF sont autorisés'));
        }
    }
});

// POST /api/upload
router.post('/', protect, upload.single('file'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'Aucun fichier reçu' });
    }
    const fileUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
    res.json({
        success: true,
        url: fileUrl,
        filename: req.file.filename
    });
});

module.exports = router;
