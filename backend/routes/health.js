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
    await db.testConnection();

    const tables = [
      'utilisateurs', 'offres', 'candidatures', 'conversations',
      'messages', 'notifications', 'paiements', 'abonnements', 'candidature_paiements'
    ];

    const counts = {};
    for (const t of tables) {
      const [rows] = await db.query(`SELECT COUNT(*) AS count FROM \`${t}\``);
      counts[t] = rows && rows[0] ? rows[0].count : 0;
    }

    res.json({ success: true, connected: true, counts });
  } catch (error) {
    console.error('HEALTH.DB ERROR:', error);
    res.status(503).json({ success: false, connected: false, message: error.message, counts: {} });
  }
});

module.exports = router;
