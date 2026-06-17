const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { protect, authorize } = require('../middleware/auth');

// GET /api/applications/my-applications — Mes candidatures (candidat)
router.get('/my-applications', protect, authorize('candidat'), async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT c.id, c.statut, c.date_postulation,
                    o.titre, o.lieu, o.type_contrat, o.salaire,
                    e.nom_societe, e.logo_url
             FROM candidatures c
             JOIN offres o ON c.offre_id = o.id
             JOIN entreprises e ON o.entreprise_id = e.id
             WHERE c.candidat_id = ?
             ORDER BY c.date_postulation DESC`,
            [req.user.id]
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// GET /api/applications/company-applications — Candidatures reçues (entreprise)
router.get('/company-applications', protect, authorize('entreprise'), async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT c.id, c.statut, c.date_postulation,
                    o.titre, o.lieu,
                    cand.nom_complet, cand.telephone, cand.filiere_specialite, cand.cv_url, cand.photo_profil_url
             FROM candidatures c
             JOIN offres o ON c.offre_id = o.id
             JOIN candidats cand ON c.candidat_id = cand.id
             WHERE o.entreprise_id = ?
             ORDER BY c.date_postulation DESC`,
            [req.user.id]
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// POST /api/applications — Postuler à une offre
router.post('/', protect, authorize('candidat'), async (req, res) => {
    try {
        const { offreId } = req.body;

        if (!offreId) {
            return res.status(400).json({ message: 'ID de l\'offre requis' });
        }

        // Vérifier que l'offre existe
        const [offre] = await db.query('SELECT id FROM offres WHERE id = ?', [offreId]);
        if (offre.length === 0) {
            return res.status(404).json({ message: 'Offre non trouvée' });
        }

        const [result] = await db.query(
            `INSERT INTO candidatures (candidat_id, offre_id, statut) VALUES (?, ?, 'En cours')`,
            [req.user.id, offreId]
        );
        res.status(201).json({ success: true, id: result.insertId, message: 'Candidature envoyée avec succès' });
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ message: 'Vous avez déjà postulé à cette offre' });
        }
        res.status(500).json({ message: error.message });
    }
});

// PUT /api/applications/:id/status — Changer le statut (entreprise)
router.put('/:id/status', protect, authorize('entreprise'), async (req, res) => {
    try {
        const { status } = req.body;
        const validStatuts = ['En cours', 'Acceptée', 'Refusée'];

        if (!validStatuts.includes(status)) {
            return res.status(400).json({ message: 'Statut invalide' });
        }

        await db.query(
            'UPDATE candidatures SET statut = ? WHERE id = ?',
            [status, req.params.id]
        );
        res.json({ success: true, message: 'Statut mis à jour' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
