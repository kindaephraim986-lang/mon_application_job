const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { protect } = require('../middleware/auth');

const UPLOAD_DIR = path.join(__dirname, '../uploads');

function ensureUploadDir() {
    if (!fs.existsSync(UPLOAD_DIR)) {
        fs.mkdirSync(UPLOAD_DIR, { recursive: true });
    }
}

function sanitizeFilename(filename) {
    return filename.replace(/[^a-zA-Z0-9._-]/g, '_');
}

const ALLOWED_EXTENSIONS = ['.pdf', '.doc', '.docx', '.jpg', '.jpeg', '.png'];
const ALLOWED_MIME_TYPES = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'image/jpeg',
    'image/png'
];

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        ensureUploadDir();
        cb(null, UPLOAD_DIR);
    },
    filename: (req, file, cb) => {
        const safeBase = sanitizeFilename(path.parse(file.originalname).name);
        const ext = path.extname(file.originalname).toLowerCase();
        const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
        cb(null, `${unique}-${safeBase}${ext}`);
    }
});

const upload = multer({
    storage,
    limits: {
        fileSize: 10 * 1024 * 1024, // 10 MB max par fichier
    },
    fileFilter: (req, file, cb) => {
        const ext = path.extname(file.originalname).toLowerCase();
        const mime = file.mimetype;
        if (!ALLOWED_EXTENSIONS.includes(ext) || !ALLOWED_MIME_TYPES.includes(mime)) {
            return cb(new Error('Type de fichier non autorisé. Seuls PDF, DOC, DOCX, JPG et PNG sont autorisés.'));
        }
        cb(null, true);
    }
});

router.post('/', protect, upload.single('file'), (req, res) => {
    // Debug logs: authorization header and file presence
    try {
        console.log('[UPLOAD DEBUG] Authorization header:', req.headers.authorization || '(none)');
        console.log('[UPLOAD DEBUG] req.file present:', !!req.file);
        if (req.file) {
            console.log('[UPLOAD DEBUG] file received:', { originalname: req.file.originalname, mimetype: req.file.mimetype, size: req.file.size });
        }
    } catch (e) {
        console.error('[UPLOAD DEBUG] logging error', e);
    }

    if (!req.file) {
        return res.status(400).json({ message: 'Aucun fichier reçu.' });
    }

    const fileUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
    return res.status(201).json({
        success: true,
        url: fileUrl,
        filename: req.file.filename,
        originalName: req.file.originalname,
        mimeType: req.file.mimetype,
        size: req.file.size
    });
});

module.exports = router;
