const express = require('express');
const router = express.Router();
const db = require('../config/database');

// GET /api/health — Health check endpoint
router.get('/', (req, res) => {
  res.json({ status: 'OK', message: 'Backend server is running', timestamp: new Date().toISOString() });
});

// GET /api/health/db — Retourne le nombre d'enregistrements clés par table
router.get('/db', async (req, res) => {
  try {
    const tables = [
      'utilisateurs', 'offres', 'candidatures', 'conversations',
      'messages', 'notifications', 'paiements', 'abonnements', 'candidature_paiements'
    ];

    const counts = {};
    for (const t of tables) {
      const [rows] = await db.query(`SELECT COUNT(*) AS count FROM \`${t}\``);
      counts[t] = rows && rows[0] ? rows[0].count : 0;
    }

    res.json({ success: true, counts });
  } catch (error) {
    console.error('HEALTH.DB ERROR:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
