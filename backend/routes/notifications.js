const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { protect } = require('../middleware/auth');

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
router.post('/', protect, async (req, res) => {
    try {
        const { utilisateurId, message, type } = req.body;

        if (!utilisateurId || !message) {
            return res.status(400).json({ message: 'Utilisateur et message requis' });
        }

        const [result] = await db.query(
            `INSERT INTO notifications (utilisateur_id, message, type_notification)
             VALUES (?, ?, ?)`,
            [utilisateurId, message, type || null]
        );

        res.status(201).json({
            success: true,
            id: result.insertId,
            message: 'Notification créée'
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
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
