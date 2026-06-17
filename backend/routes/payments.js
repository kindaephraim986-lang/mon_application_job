const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { protect, authorize } = require('../middleware/auth');

// POST /api/payments/apply — Enregistrer un paiement pour candidature unitaire
router.post('/apply', protect, authorize('candidat'), async (req, res) => {
    try {
        const { offreId, montant, methode_paiement } = req.body;

        if (!offreId || !montant) {
            return res.status(400).json({ 
                success: false, 
                message: 'ID offre et montant requis' 
            });
        }

        if (montant !== 500) {
            return res.status(400).json({ 
                success: false, 
                message: 'Montant invalide. Montant attendu: 500 FCFA' 
            });
        }

        // Vérifier que l'offre existe
        const [offre] = await db.query('SELECT id FROM offres WHERE id = ?', [offreId]);
        if (offre.length === 0) {
            return res.status(404).json({ success: false, message: 'Offre non trouvée' });
        }

        // Vérifier que le candidat n'a pas déjà payé pour cette offre
        const [existingPayment] = await db.query(
            `SELECT id FROM candidature_paiements 
             WHERE candidat_id = ? AND offre_id = ? AND statut = 'réussi'`,
            [req.user.id, offreId]
        );

        if (existingPayment.length > 0) {
            return res.status(400).json({ 
                success: false, 
                message: 'Vous avez déjà payé pour cette offre' 
            });
        }

        // Enregistrer le paiement
        const [result] = await db.query(
            `INSERT INTO candidature_paiements 
             (candidat_id, offre_id, montant, methode_paiement, statut) 
             VALUES (?, ?, ?, ?, 'réussi')`,
            [req.user.id, offreId, montant, methode_paiement || 'mobile_money']
        );

        // Enregistrer aussi dans la table paiements pour historique
        await db.query(
            `INSERT INTO paiements 
             (utilisateur_id, montant, devise, raison, statut) 
             VALUES (?, ?, 'FCFA', ?, 'réussi')`,
            [req.user.id, montant, `Candidature offre ${offreId}`]
        );

        res.status(201).json({ 
            success: true, 
            message: 'Paiement enregistré avec succès',
            paymentId: result.insertId
        });
    } catch (error) {
        console.error('Payment registration error:', error);
        res.status(500).json({ success: false, message: error.message });
    }
});

// GET /api/payments/apply/:offreId — Vérifier si le candidat a payé pour cette offre
router.get('/apply/:offreId', protect, authorize('candidat'), async (req, res) => {
    try {
        const { offreId } = req.params;

        const [payment] = await db.query(
            `SELECT id, statut FROM candidature_paiements 
             WHERE candidat_id = ? AND offre_id = ? AND statut = 'réussi'`,
            [req.user.id, offreId]
        );

        res.json({ 
            paid: payment.length > 0,
            paymentId: payment.length > 0 ? payment[0].id : null
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// GET /api/payments/subscription — Vérifier si le candidat a un abonnement actif
router.get('/subscription', protect, authorize('candidat'), async (req, res) => {
    try {
        const [subscription] = await db.query(
            `SELECT id, date_fin FROM abonnements 
             WHERE utilisateur_id = ? AND type_abonnement = 'candidat_mensuel' AND statut = 'actif' AND date_fin > NOW()`,
            [req.user.id]
        );

        res.json({ 
            hasActiveSubscription: subscription.length > 0,
            expiryDate: subscription.length > 0 ? subscription[0].date_fin : null
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;
