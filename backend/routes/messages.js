const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { protect } = require('../middleware/auth');

// GET /api/messages/conversations — Obtenir mes conversations
router.get('/conversations', protect, async (req, res) => {
    try {
        let query = '';
        let params = [];

        if (req.user.type_utilisateur === 'candidat') {
            query = `
                SELECT c.id, c.candidat_id, c.entreprise_id, c.date_creation, c.non_lus_candidat,
                       e.nom_societe, e.logo_url,
                       (SELECT texte FROM messages WHERE conversation_id = c.id ORDER BY date_envoi DESC LIMIT 1) AS dernier_message,
                       (SELECT DATE_FORMAT(date_envoi, '%Y-%m-%d %H:%i:%s') FROM messages WHERE conversation_id = c.id ORDER BY date_envoi DESC LIMIT 1) AS date_dernier_message
                FROM conversations c
                JOIN entreprises e ON c.entreprise_id = e.id
                WHERE c.candidat_id = ?
                ORDER BY c.date_creation DESC
            `;
            params = [req.user.id];
        } else {
            query = `
                SELECT c.id, c.candidat_id, c.entreprise_id, c.date_creation, c.non_lus_entreprise,
                       cand.nom_complet, cand.photo_profil_url,
                       (SELECT texte FROM messages WHERE conversation_id = c.id ORDER BY date_envoi DESC LIMIT 1) AS dernier_message,
                       (SELECT DATE_FORMAT(date_envoi, '%Y-%m-%d %H:%i:%s') FROM messages WHERE conversation_id = c.id ORDER BY date_envoi DESC LIMIT 1) AS date_dernier_message
                FROM conversations c
                JOIN candidats cand ON c.candidat_id = cand.id
                WHERE c.entreprise_id = ?
                ORDER BY c.date_creation DESC
            `;
            params = [req.user.id];
        }

        const [rows] = await db.query(query, params);
        res.json(rows);
    } catch (error) {
        console.error('GET CONVERSATIONS ERROR:', error);
        res.status(500).json({ message: error.message });
    }
});

// GET /api/messages/conversations/:id — Obtenir les messages d'une conversation
router.get('/conversations/:id', protect, async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT m.id, m.expediteur_id, m.texte, m.date_envoi,
                    u.email, u.type_utilisateur
             FROM messages m
             JOIN utilisateurs u ON m.expediteur_id = u.id
             WHERE m.conversation_id = ?
             ORDER BY m.date_envoi ASC`,
            [req.params.id]
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// POST /api/messages — Envoyer un message
router.post('/', protect, async (req, res) => {
    try {
        const { conversationId, texte } = req.body;

        if (!conversationId || !texte) {
            return res.status(400).json({ message: 'ID conversation et texte requis' });
        }

        // Vérifier que la conversation existe et que l'utilisateur y participe
        const [conv] = await db.query(
            `SELECT * FROM conversations 
             WHERE id = ? AND (candidat_id = ? OR entreprise_id = ?)`,
            [conversationId, req.user.id, req.user.id]
        );

        if (conv.length === 0) {
            return res.status(404).json({ message: 'Conversation non trouvée' });
        }

        const [result] = await db.query(
            `INSERT INTO messages (conversation_id, expediteur_id, texte)
             VALUES (?, ?, ?)`,
            [conversationId, req.user.id, texte]
        );

        res.status(201).json({
            success: true,
            id: result.insertId,
            message: 'Message envoyé avec succès'
        });
    } catch (error) {
        console.error('SEND MESSAGE ERROR:', error);
        res.status(500).json({ message: error.message });
    }
});

// POST /api/messages/start — Démarrer une conversation
router.post('/start', protect, async (req, res) => {
    try {
        const { otherUserId } = req.body;

        if (!otherUserId) {
            return res.status(400).json({ message: 'ID utilisateur requis' });
        }

        // Déterminer qui est candidat et qui est entreprise
        let candidatId, entrepriseId;

        if (req.user.type_utilisateur === 'candidat') {
            candidatId = req.user.id;
            entrepriseId = otherUserId;
        } else {
            candidatId = otherUserId;
            entrepriseId = req.user.id;
        }

        // Vérifier si une conversation existe déjà
        const [existing] = await db.query(
            `SELECT id FROM conversations 
             WHERE candidat_id = ? AND entreprise_id = ?`,
            [candidatId, entrepriseId]
        );

        if (existing.length > 0) {
            return res.json({ success: true, id: existing[0].id });
        }

        // Créer une nouvelle conversation
        const [result] = await db.query(
            `INSERT INTO conversations (candidat_id, entreprise_id)
             VALUES (?, ?)`,
            [candidatId, entrepriseId]
        );

        res.status(201).json({
            success: true,
            id: result.insertId,
            message: 'Conversation créée'
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
