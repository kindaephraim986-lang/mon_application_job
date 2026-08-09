const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { protect, authorize } = require('../middleware/auth');

// Middleware : Admin uniquement
router.use(protect, (req, res, next) => {
  const userType = req.user?.type_utilisateur || req.user?.user_type || req.user?.type || '';
  if (userType !== 'admin') {
    return res.status(403).json({ message: 'Accès administrateur requis' });
  }
  next();
});


// ===================== STATISTIQUES =====================

// GET /api/admin/stats — Aperçu du système
router.get('/stats', async (req, res) => {
  try {
    const [users] = await db.query('SELECT COUNT(*) as total FROM utilisateurs');
    const [offers] = await db.query('SELECT COUNT(*) as total FROM offres');
    const [applications] = await db.query('SELECT COUNT(*) as total FROM candidatures');
    const [payments] = await db.query('SELECT COUNT(*) as total FROM paiements');
    const [subscriptions] = await db.query('SELECT COUNT(*) as total FROM abonnements');

    res.json({
      success: true,
      stats: {
        totalUsers: users[0]?.total || 0,
        totalOffers: offers[0]?.total || 0,
        totalApplications: applications[0]?.total || 0,
        totalPayments: payments[0]?.total || 0,
        totalSubscriptions: subscriptions[0]?.total || 0,
      },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ===================== UTILISATEURS =====================

// GET /api/admin/users — Lister tous les utilisateurs
router.get('/users', async (req, res) => {
  try {
    const [users] = await db.query(`
      SELECT u.id,
             u.email,
             u.type_utilisateur as userType,
             u.type_utilisateur as role,
             u.date_creation,
             COALESCE(c.nom_complet, e.nom_societe, 'Utilisateur') as nom,
             COALESCE(c.telephone, e.telephone) as telephone,
             c.filiere_specialite,
             c.age,
             c.domicile,
             c.sexe,
             e.domaine_activite,
             e.adresse_complete,
             e.ville_lieu
      FROM utilisateurs u
      LEFT JOIN candidats c ON u.id = c.id
      LEFT JOIN entreprises e ON u.id = e.id
      ORDER BY u.date_creation DESC
    `);
    
    res.json({
      success: true,
      users: users || [],
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET /api/admin/users/:id — Détails d'un utilisateur
router.get('/users/:id', async (req, res) => {
  try {
    const [users] = await db.query(`
      SELECT u.id,
             u.email,
             u.type_utilisateur as userType,
             COALESCE(c.nom_complet, e.nom_societe, 'Utilisateur') as nom,
             COALESCE(c.telephone, e.telephone) as telephone,
             c.filiere_specialite,
             c.age,
             c.domicile,
             c.sexe,
             e.domaine_activite,
             e.adresse_complete,
             e.ville_lieu,
             u.date_creation
      FROM utilisateurs u
      LEFT JOIN candidats c ON u.id = c.id
      LEFT JOIN entreprises e ON u.id = e.id
      WHERE u.id = ?
    `, [req.params.id]);
    
    if (!users || users.length === 0) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
    
    res.json({
      success: true,
      user: users[0],
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// PUT /api/admin/users/:id — Modifier un utilisateur
router.put('/users/:id', async (req, res) => {
  try {
    const { nom, email, role, telephone } = req.body;
    const id = req.params.id;
    
    // Vérifier que l'utilisateur existe
    const [existing] = await db.query('SELECT id FROM utilisateurs WHERE id = ?', [id]);
    if (!existing || existing.length === 0) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
    
    // Construire la requête de mise à jour
    const updates = [];
    const values = [];
    
    if (nom !== undefined) {
      updates.push('nom = ?');
      values.push(nom);
    }
    if (email !== undefined) {
      updates.push('email = ?');
      values.push(email);
    }
    if (role !== undefined && ['admin', 'user'].includes(role)) {
      updates.push('role = ?');
      values.push(role);
    }
    if (telephone !== undefined) {
      updates.push('telephone = ?');
      values.push(telephone);
    }
    
    if (updates.length === 0) {
      return res.status(400).json({ message: 'Aucune modification fournie' });
    }
    
    updates.push('date_modification = NOW()');
    values.push(id);
    
    const [result] = await db.query(
      `UPDATE utilisateurs SET ${updates.join(', ')} WHERE id = ?`,
      values
    );
    
    if (result.affectedRows === 0) {
      return res.status(500).json({ message: 'Erreur lors de la mise à jour' });
    }
    
    res.json({ success: true, message: 'Utilisateur modifié' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// DELETE /api/admin/users/:id — Supprimer un utilisateur
router.delete('/users/:id', async (req, res) => {
  try {
    const id = req.params.id;
    
    // Empêcher la suppression de soi-même
    if (parseInt(id) === req.user.id) {
      return res.status(403).json({ message: 'Vous ne pouvez pas supprimer votre propre compte' });
    }
    
    const [result] = await db.query('DELETE FROM utilisateurs WHERE id = ?', [id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
    
    res.json({ success: true, message: 'Utilisateur supprimé' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ===================== OFFRES =====================

// GET /api/admin/offers — Lister toutes les offres
router.get('/offers', async (req, res) => {
  try {
    const [offers] = await db.query(`
      SELECT o.*, e.nom_societe, e.logo_url
      FROM offres o
      LEFT JOIN entreprises e ON o.entreprise_id = e.id
      ORDER BY o.date_publication DESC
    `);
    
    res.json({
      success: true,
      offers: offers || [],
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// PUT /api/admin/offers/:id — Modifier une offre
router.put('/offers/:id', async (req, res) => {
  try {
    const { titre, description, type_contrat, lieu, salaire, competences } = req.body;
    const id = req.params.id;
    
    const [existing] = await db.query('SELECT id FROM offres WHERE id = ?', [id]);
    if (!existing || existing.length === 0) {
      return res.status(404).json({ message: 'Offre non trouvée' });
    }
    
    const updates = [];
    const values = [];
    
    if (titre !== undefined) { updates.push('titre = ?'); values.push(titre); }
    if (description !== undefined) { updates.push('description = ?'); values.push(description); }
    if (type_contrat !== undefined) { updates.push('type_contrat = ?'); values.push(type_contrat); }
    if (lieu !== undefined) { updates.push('lieu = ?'); values.push(lieu); }
    if (salaire !== undefined) { updates.push('salaire = ?'); values.push(salaire); }
    if (competences !== undefined) { updates.push('competences = ?'); values.push(competences); }
    
    if (updates.length === 0) {
      return res.status(400).json({ message: 'Aucune modification fournie' });
    }
    
    updates.push('date_modification = NOW()');
    values.push(id);
    
    await db.query(
      `UPDATE offres SET ${updates.join(', ')} WHERE id = ?`,
      values
    );
    
    res.json({ success: true, message: 'Offre modifiée' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ===================== CANDIDATURES =====================

// GET /api/admin/applications — Lister toutes les candidatures
router.get('/applications', async (req, res) => {
  try {
    const [apps] = await db.query(`
      SELECT c.*, u.email, u.nom, o.titre
      FROM candidatures c
      JOIN utilisateurs u ON c.candidat_id = u.id
      JOIN offres o ON c.offre_id = o.id
      ORDER BY c.date_candidature DESC
    `);
    
    res.json({
      success: true,
      applications: apps || [],
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// PUT /api/admin/applications/:id — Modifier le statut d'une candidature
router.put('/applications/:id', async (req, res) => {
  try {
    const { statut } = req.body;
    
    if (!['acceptée', 'rejetée', 'en attente', 'vue'].includes(statut)) {
      return res.status(400).json({ message: 'Statut invalide' });
    }
    
    const [result] = await db.query(
      'UPDATE candidatures SET statut = ?, date_modification = NOW() WHERE id = ?',
      [statut, req.params.id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Candidature non trouvée' });
    }
    
    res.json({ success: true, message: 'Candidature modifiée' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ===================== PAIEMENTS =====================

// GET /api/admin/payments — Lister tous les paiements
router.get('/payments', async (req, res) => {
  try {
    const [payments] = await db.query(`
      SELECT p.*, u.email, u.nom
      FROM paiements p
      LEFT JOIN utilisateurs u ON p.utilisateur_id = u.id
      ORDER BY p.date_paiement DESC
    `);
    
    res.json({
      success: true,
      payments: payments || [],
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// DELETE /api/admin/payments/:id — Supprimer un paiement
router.delete('/payments/:id', async (req, res) => {
  try {
    const [result] = await db.query('DELETE FROM paiements WHERE id = ?', [req.params.id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Paiement non trouvé' });
    }

    res.json({ success: true, message: 'Paiement supprimé' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ===================== ABONNEMENTS =====================

// GET /api/admin/subscriptions — Lister tous les abonnements
router.get('/subscriptions', async (req, res) => {
  try {
    const [subscriptions] = await db.query(`
      SELECT a.*, u.email, u.type_utilisateur as userType,
             COALESCE(c.nom_complet, e.nom_societe, u.email) as user_name,
             c.nom_complet as candidat_nom,
             e.nom_societe as entreprise_nom
      FROM abonnements a
      LEFT JOIN utilisateurs u ON a.utilisateur_id = u.id
      LEFT JOIN candidats c ON a.utilisateur_id = c.id
      LEFT JOIN entreprises e ON a.utilisateur_id = e.id
      ORDER BY a.date_debut DESC
    `);

    res.json({
      success: true,
      subscriptions: subscriptions || [],
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// DELETE /api/admin/subscriptions/:id — Supprimer un abonnement
router.delete('/subscriptions/:id', async (req, res) => {
  try {
    const [result] = await db.query('DELETE FROM abonnements WHERE id = ?', [req.params.id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Abonnement non trouvé' });
    }

    res.json({ success: true, message: 'Abonnement supprimé' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
