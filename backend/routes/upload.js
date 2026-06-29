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
    'image/jpg',
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
        if (!ALLOWED_EXTENSIONS.includes(ext)) {
            return cb(new Error('Type de fichier non autorisé. Seuls PDF, DOC, DOCX, JPG et PNG sont autorisés.'));
        }
        // Vérifier aussi le type MIME côté serveur
        if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
            return cb(new Error('Type MIME non autorisé pour ce fichier.'));
        }
        cb(null, true);
    }
});

const uploadSingleFile = (req, res, next) => {
    upload.single('file')(req, res, err => {
        if (err) {
            // Multer errors have a code and message
            console.error('[UPLOAD ERROR]', err && err.message ? err.message : err);
            const status = err.code === 'LIMIT_FILE_SIZE' ? 413 : 400;
            return res.status(status).json({ success: false, message: err.message || 'Erreur lors de l’envoi du fichier.' });
        }
        next();
    });
};

// Allow anonymous uploads for registration flow. If a Bearer token is provided
// we try to parse it and attach a lightweight req.user, but uploads do not
// require authentication anymore.
router.post('/', uploadSingleFile, async (req, res) => {
    try {
        if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
            const token = req.headers.authorization.split(' ')[1];
            try {
                const jwt = require('jsonwebtoken');
                const decoded = jwt.verify(token, process.env.JWT_SECRET || 'afrijob_dev_secret');
                if (decoded && decoded.id) {
                    req.user = { id: decoded.id, type_utilisateur: decoded.type_utilisateur || null };
                }
            } catch (e) {
                console.warn('[UPLOAD DEBUG] invalid token provided, proceeding as anonymous');
            }
        }
    } catch (e) {
        // ignore token parsing errors
    }
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
