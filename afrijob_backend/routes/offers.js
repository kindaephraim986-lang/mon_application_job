const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { protect, authorize } = require('../middleware/auth');

// GET /api/offers — Toutes les offres (public)
router.get('/', async (req, res) => {
    try {
        const { search, type, lieu } = req.query;
        let query = `
            SELECT o.*, e.nom_societe, e.logo_url, e.ville_lieu, e.domaine_activite
            FROM offres o
            JOIN entreprises e ON o.entreprise_id = e.id
            WHERE 1=1
        `;
        const params = [];

        if (search) {
            query += ' AND (o.titre LIKE ? OR o.description LIKE ? OR e.nom_societe LIKE ?)';
            params.push(`%${search}%`, `%${search}%`, `%${search}%`);
        }
        if (type) {
            query += ' AND o.type_contrat = ?';
            params.push(type);
        }
        if (lieu) {
            query += ' AND o.lieu LIKE ?';
            params.push(`%${lieu}%`);
        }

        query += ' ORDER BY o.date_publication DESC';

        const [rows] = await db.query(query, params);
        res.json(rows);
    } catch (error) {
        console.error('GET OFFERS ERROR:', error);
        res.status(500).json({ message: error.message });
    }
});

// GET /api/offers/my-offers — Mes offres (entreprise connectée)
router.get('/my-offers', protect, authorize('entreprise'), async (req, res) => {
    try {
        const [rows] = await db.query(
            'SELECT * FROM offres WHERE entreprise_id = ? ORDER BY date_publication DESC',
            [req.user.id]
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// GET /api/offers/:id — Détail d'une offre
router.get('/:id', async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT o.*, e.nom_societe, e.logo_url, e.ville_lieu, e.domaine_activite, e.telephone
             FROM offres o
             JOIN entreprises e ON o.entreprise_id = e.id
             WHERE o.id = ?`,
            [req.params.id]
        );
        if (rows.length === 0) {
            return res.status(404).json({ message: 'Offre non trouvée' });
        }
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// POST /api/offers — Créer une offre (entreprise seulement)
router.post('/', protect, authorize('entreprise'), async (req, res) => {
    try {
        const { titre, description, typeContrat, lieu, competences, niveau, experience, salaire } = req.body;

        if (!titre || !description) {
            return res.status(400).json({ message: 'Titre et description requis' });
        }

        const [result] = await db.query(
            `INSERT INTO offres (entreprise_id, titre, description, type_contrat, lieu, competences, niveau_etude, experience_requise, salaire)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [req.user.id, titre, description, typeContrat || null, lieu || null,
             competences || null, niveau || null, experience || null, salaire || null]
        );
        res.status(201).json({ success: true, id: result.insertId, message: 'Offre créée avec succès' });
    } catch (error) {
        console.error('CREATE OFFER ERROR:', error);
        res.status(500).json({ message: error.message });
    }
});

// DELETE /api/offers/:id — Supprimer une offre
router.delete('/:id', protect, authorize('entreprise'), async (req, res) => {
    try {
        const [result] = await db.query(
            'DELETE FROM offres WHERE id = ? AND entreprise_id = ?',
            [req.params.id, req.user.id]
        );
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Offre non trouvée ou non autorisé' });
        }
        res.json({ success: true, message: 'Offre supprimée' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
