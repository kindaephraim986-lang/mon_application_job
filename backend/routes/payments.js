const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { protect, authorize } = require('../middleware/auth');
const { body, param, validationResult } = require('express-validator');

const validate = (checks) => [
    ...checks,
    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(422).json({ success: false, errors: errors.array() });
        }
        return next();
    }
];

// POST /api/payments/apply — Enregistrer un paiement pour candidature unitaire
const applyChecks = validate([
    body('offreId').exists().withMessage('offreId requis').bail().isInt({ gt: 0 }).withMessage('offreId doit être un entier positif'),
    body('montant').exists().withMessage('montant requis').bail().isNumeric().withMessage('montant doit être numérique'),
    body('methode_paiement').optional().isIn(['mobile_money', 'card', 'orange_money', 'momo']).withMessage('méthode de paiement invalide')
]);

router.post('/apply', protect, authorize('candidat'), applyChecks, async (req, res) => {
    try {
        const offreIdValue = Number(req.body.offreId);
        const montantValue = Number(req.body.montant);
        const methode_paiement = req.body.methode_paiement || 'mobile_money';

        if (montantValue !== 500) {
            return res.status(400).json({ success: false, message: 'Montant invalide. Montant attendu: 500 FCFA' });
        }

        // Vérifier que l'offre existe
        const [offre] = await db.query('SELECT id FROM offres WHERE id = ?', [offreIdValue]);
        if (!offre || offre.length === 0) {
            return res.status(404).json({ success: false, message: 'Offre non trouvée' });
        }

        const candidatId = Number(req.user.id);

        // Vérifier que le candidat n'a pas déjà payé pour cette offre
        const [existingPayment] = await db.query(
            `SELECT id FROM candidature_paiements 
             WHERE candidat_id = ? AND offre_id = ? AND statut = 'réussi'`,
            [candidatId, offreIdValue]
        );

        if (existingPayment && existingPayment.length > 0) {
            return res.status(400).json({ success: false, message: 'Vous avez déjà payé pour cette offre' });
        }

        // Enregistrer le paiement
        const [result] = await db.query(
            `INSERT INTO candidature_paiements 
             (candidat_id, offre_id, montant, methode_paiement, statut) 
             VALUES (?, ?, ?, ?, 'réussi')`,
            [candidatId, offreIdValue, montantValue, methode_paiement]
        );

        // Enregistrer aussi dans la table paiements pour historique
        await db.query(
            `INSERT INTO paiements 
             (utilisateur_id, montant, devise, raison, statut) 
             VALUES (?, ?, 'FCFA', ?, 'réussi')`,
            [candidatId, montantValue, `Candidature offre ${offreIdValue}`]
        );

        return res.status(201).json({ success: true, message: 'Paiement enregistré avec succès', paymentId: result.insertId });
    } catch (error) {
        console.error('Payment registration error:', error);
        return res.status(500).json({ success: false, message: 'Erreur serveur lors de l’enregistrement du paiement' });
    }
});

// GET /api/payments/apply/:offreId — Vérifier si le candidat a payé pour cette offre
const checkApplyChecks = validate([
    param('offreId').exists().withMessage('offreId requis').bail().isInt({ gt: 0 }).withMessage('offreId doit être un entier positif')
]);

router.get('/apply/:offreId', protect, authorize('candidat'), checkApplyChecks, async (req, res) => {
    try {
        const offreId = Number(req.params.offreId);
        const candidatId = Number(req.user.id);

        const [payment] = await db.query(
            `SELECT id, statut FROM candidature_paiements 
             WHERE candidat_id = ? AND offre_id = ? AND statut = 'réussi'`,
            [candidatId, offreId]
        );

        return res.json({ paid: payment && payment.length > 0, paymentId: payment && payment.length > 0 ? payment[0].id : null });
    } catch (error) {
        console.error('GET /apply/:offreId error:', error);
        return res.status(500).json({ success: false, message: 'Erreur serveur' });
    }
});

const getSubscriptionType = (userType) => {
    if (userType === 'entreprise') return 'entreprise_mensuel';
    if (userType === 'candidat') return 'candidat_mensuel';
    return null;
};

const getSubscriptionStatus = async (req, res) => {
    try {
        const subscriptionType = getSubscriptionType(req.user.type_utilisateur);
        if (!subscriptionType) {
            return res.status(400).json({ success: false, message: 'Type de compte non supporté' });
        }

        const [subscriptions] = await db.query(
            `SELECT id, date_debut, date_fin, statut, montant
             FROM abonnements
             WHERE utilisateur_id = ? AND type_abonnement = ? AND statut = 'actif' AND date_fin > NOW()
             ORDER BY date_fin DESC
             LIMIT 1`,
            [req.user.id, subscriptionType]
        );

        const hasActiveSubscription = subscriptions.length > 0;
        return res.json({
            success: true,
            hasActiveSubscription,
            has_subscription: hasActiveSubscription,
            subscription: hasActiveSubscription ? subscriptions[0] : null,
            date_fin: hasActiveSubscription ? subscriptions[0].date_fin : null,
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

const createOrRenewSubscription = async (req, res) => {
    try {
        const subscriptionType = getSubscriptionType(req.user.type_utilisateur);
        if (!subscriptionType) {
            return res.status(400).json({ success: false, message: 'Type de compte non supporté' });
        }

        const days = Number(req.body.days ?? 30);
        if (Number.isNaN(days) || days <= 0) {
            return res.status(400).json({ success: false, message: 'Durée d’abonnement invalide' });
        }

        const amount = Number(req.body.amount ?? (req.user.type_utilisateur === 'entreprise' ? 2000 : 1000));
        if (Number.isNaN(amount) || amount < 0) {
            return res.status(400).json({ success: false, message: 'Montant d’abonnement invalide' });
        }

        await db.query(
            `UPDATE abonnements
             SET statut = 'expiré'
             WHERE utilisateur_id = ? AND type_abonnement = ? AND statut = 'actif'`,
            [req.user.id, subscriptionType]
        );

        const [result] = await db.query(
            `INSERT INTO abonnements (utilisateur_id, type_abonnement, date_debut, date_fin, statut, montant)
             VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? DAY), 'actif', ?)`,
            [req.user.id, subscriptionType, days, amount]
        );

        const [newSubscriptionRows] = await db.query(
            `SELECT id, date_debut, date_fin, statut, montant
             FROM abonnements WHERE id = ?`,
            [result.insertId]
        );

        return res.status(201).json({
            success: true,
            message: 'Abonnement activé avec succès',
            subscription: newSubscriptionRows[0],
        });
    } catch (error) {
        console.error('Subscription creation error:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

const resetSubscription = async (req, res) => {
    try {
        const subscriptionType = getSubscriptionType(req.user.type_utilisateur);
        if (!subscriptionType) {
            return res.status(400).json({ success: false, message: 'Type de compte non supporté' });
        }

        const [subscriptions] = await db.query(
            `SELECT id
             FROM abonnements
             WHERE utilisateur_id = ? AND type_abonnement = ?
             ORDER BY date_fin DESC
             LIMIT 1`,
            [req.user.id, subscriptionType]
        );

        if (subscriptions.length === 0) {
            return res.status(404).json({ success: false, message: 'Aucun abonnement trouvé à réinitialiser' });
        }

        const [updateResult] = await db.query(
            `UPDATE abonnements
             SET statut = 'actif', date_debut = NOW(), date_fin = DATE_ADD(NOW(), INTERVAL 30 DAY), montant = 0
             WHERE id = ?`,
            [subscriptions[0].id]
        );

        const [updatedRows] = await db.query(
            `SELECT id, date_debut, date_fin, statut, montant
             FROM abonnements
             WHERE id = ?`,
            [subscriptions[0].id]
        );

        return res.json({
            success: true,
            message: 'Abonnement réinitialisé sans suppression',
            subscription: updatedRows[0],
        });
    } catch (error) {
        console.error('Subscription reset error:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

router.post('/subscription', protect, createOrRenewSubscription);
router.post('/subscribe', protect, createOrRenewSubscription);
router.post('/subscription/reset', protect, resetSubscription);
router.get('/subscription', protect, getSubscriptionStatus);
router.get('/subscription/status', protect, getSubscriptionStatus);

module.exports = router;
