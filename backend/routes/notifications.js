const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { protect } = require('../middleware/auth');
const { body, param, validationResult } = require('express-validator');

// Simple rate limiter for notifications creation per user
const notifRate = new Map();
const NOTIF_RATE_LIMIT = 20; // per minute
const NOTIF_RATE_INTERVAL = 60 * 1000;
function allowNotification(userId) {
    const now = Date.now();
    const state = notifRate.get(userId) || { tokens: NOTIF_RATE_LIMIT, last: now };
    const elapsed = now - state.last;
    const refill = Math.floor(elapsed / NOTIF_RATE_INTERVAL) * NOTIF_RATE_LIMIT;
    state.tokens = Math.min(NOTIF_RATE_LIMIT, state.tokens + refill);
    state.last = now;
    if (state.tokens > 0) {
        state.tokens -= 1;
        notifRate.set(userId, state);
        return true;
    }
    notifRate.set(userId, state);
    return false;
}

const validate = (checks) => [
    ...checks,
    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) return res.status(422).json({ success: false, errors: errors.array() });
        return next();
    }
];

// GET /api/notifications — Obtenir mes notifications
router.get('/', protect, async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT * FROM notifications 
             WHERE utilisateur_id = ? 
             ORDER BY date_notification DESC 
             LIMIT 50`,
            [req.user.id]
        );
        res.json(rows);
    } catch (error) {
        console.error('GET NOTIFICATIONS ERROR:', error);
        res.status(500).json({ message: error.message });
    }
});

// PUT /api/notifications/:id/read — Marquer comme lu
router.put('/:id/read', protect, async (req, res) => {
    try {
        await db.query(
            'UPDATE notifications SET est_lu = 1 WHERE id = ? AND utilisateur_id = ?',
            [req.params.id, req.user.id]
        );
        res.json({ success: true, message: 'Notification marquée comme lue' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// PUT /api/notifications/read-all — Marquer toutes comme lues
router.put('/mark/all', protect, async (req, res) => {
    try {
        await db.query(
            'UPDATE notifications SET est_lu = 1 WHERE utilisateur_id = ?',
            [req.user.id]
        );
        res.json({ success: true, message: 'Toutes les notifications marquées comme lues' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// POST /api/notifications — Créer une notification (interne)
router.post('/', protect, validate([
  body('utilisateurId').exists().withMessage('utilisateurId requis').bail().isInt({ gt: 0 }),
  body('message').exists().withMessage('message requis').bail().trim().isLength({ min: 1, max: 1000 })
]), async (req, res) => {
    try {
        const { utilisateurId, message, type } = req.body;
        const actorId = Number(req.user.id);
        if (!allowNotification(actorId)) return res.status(429).json({ success: false, message: 'Trop de notifications, réessayez plus tard' });

        const [result] = await db.query(
            `INSERT INTO notifications (utilisateur_id, message, type_notification)
             VALUES (?, ?, ?)`,
            [utilisateurId, message, type || null]
        );

        res.status(201).json({ success: true, id: result.insertId, message: 'Notification créée' });
    } catch (error) {
        console.error('CREATE NOTIFICATION ERROR:', error);
        res.status(500).json({ message: 'Erreur serveur lors de la création de la notification' });
    }
});

// DELETE /api/notifications/:id — Supprimer une notification
router.delete('/:id', protect, async (req, res) => {
    try {
        const [result] = await db.query(
            'DELETE FROM notifications WHERE id = ? AND utilisateur_id = ?',
            [req.params.id, req.user.id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Notification non trouvée' });
        }

        res.json({ success: true, message: 'Notification supprimée' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
