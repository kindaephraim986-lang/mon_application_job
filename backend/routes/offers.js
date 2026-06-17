const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { protect, authorize } = require('../middleware/auth');

// GET /api/offers/my-offers — Mes offres (entreprise connectée) - DOIT ÊTRE AVANT /:id
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

// GET /api/offers — Toutes les offres (public)
// support query params: search, type, lieu, field
router.get('/', async (req, res) => {
    try {
        const { search, type, lieu, field } = req.query;
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
        if (field) {
            query += ' AND (o.competences LIKE ? OR o.titre LIKE ? OR o.description LIKE ? OR e.domaine_activite LIKE ?)';
            const f = `%${field}%`;
            params.push(f, f, f, f);
        }

        query += ' ORDER BY o.date_publication DESC';

        const [rows] = await db.query(query, params);
        res.json(rows);
    } catch (error) {
        console.error('GET OFFERS ERROR:', error);
        res.status(500).json({ message: error.message });
    }
});

// GET /api/offers/fields — Retourne une liste de filieres / domaines distincts
router.get('/fields', async (req, res) => {
    try {
        const [rows1] = await db.query('SELECT DISTINCT competences FROM offres WHERE competences IS NOT NULL AND TRIM(competences) <> ""');
        const [rows2] = await db.query('SELECT DISTINCT domaine_activite FROM entreprises WHERE domaine_activite IS NOT NULL AND TRIM(domaine_activite) <> ""');

        const set = new Set();

        rows1.forEach(r => {
            if (r.competences) {
                r.competences.toString().split(/[;,]/).forEach(s => {
                    const v = s.toString().trim();
                    if (v) set.add(v);
                });
            }
        });
        rows2.forEach(r => {
            if (r.domaine_activite) {
                const v = r.domaine_activite.toString().trim();
                if (v) set.add(v);
            }
        });

        const list = Array.from(set).sort();
        res.json(list);
    } catch (error) {
        console.error('GET FIELDS ERROR:', error);
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
        const {
            titre,
            description,
            type_contrat,
            typeContrat,
            lieu,
            competences,
            niveau,
            experience,
            salaire,
        } = req.body;

        const contrat = type_contrat || typeContrat || null;

        if (!titre || !description) {
            return res.status(400).json({ message: 'Titre et description requis' });
        }

        const [result] = await db.query(
            `INSERT INTO offres (entreprise_id, titre, description, type_contrat, lieu, competences, niveau_etude, experience_requise, salaire)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [req.user.id, titre, description, contrat, lieu || null,
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
