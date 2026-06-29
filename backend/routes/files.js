/**
 * routes/files.js
 * Routes pour la gestion des documents (CV, CNIB) avec URLs signées
 */

const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { generateSignedFileUrl, verifyFileSignature } = require('../middleware/fileSignature');

const UPLOADS_DIR = path.join(__dirname, '../uploads');

/**
 * POST /api/files/generate-signed-url
 * Générer une URL signée pour accéder à un document
 * Authentification requise
 */
router.post('/generate-signed-url', authenticateToken, async (req, res) => {
  try {
    const { documentId, documentType, candidatId } = req.body;
    const requesterId = typeof req.user?.id === 'string' ? parseInt(req.user.id, 10) : req.user?.id;
    const requesterType = req.user?.type || req.user?.type_utilisateur || req.user?.user_type || null; // 'candidat' ou 'entreprise'

    if (!documentId || !documentType || !candidatId) {
      return res.status(400).json({
        success: false,
        message: 'Paramètres manquants',
        required: ['documentId', 'documentType', 'candidatId']
      });
    }

    // Vérifier que le requester peut accéder à ce document
    if (requesterType === 'entreprise') {
      // Vérifier l'abonnement de l'entreprise
      const [subscriptions] = await db.query(
        `SELECT * FROM subscriptions 
         WHERE entreprise_id = ? AND status = 'active' AND end_date > NOW()
         LIMIT 1`,
        [requesterId]
      );

      if (!subscriptions || subscriptions.length === 0) {
        // Logger l'accès bloqué
        await db.query(
          `INSERT INTO document_access_logs 
           (document_id, document_type, candidat_id, entreprise_id, access_type, blocked_reason, ip_address)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [documentId, documentType, candidatId, requesterId, 'blocked', 'NO_SUBSCRIPTION', req.ip]
        );

        return res.status(402).json({
          success: false,
          message: 'Abonnement requis pour accéder à ce document',
          code: 'SUBSCRIPTION_REQUIRED'
        });
      }
    }

    // Générer l'URL signée
    let signedUrl = await generateSignedFileUrl(
      documentId,
      documentType,
      candidatId,
      requesterId,
      requesterType
    );

    // Retourner une URL absolue pour éviter les problèmes de chemin relatif depuis le frontend
    const protocol = req.protocol;
    const host = req.get('host');
    if (signedUrl.startsWith('/') && host) {
      signedUrl = `${protocol}://${host}${signedUrl}`;
    }

    res.json({
      success: true,
      signedUrl,
      expiresIn: 3600, // 1 heure
      message: 'URL signée générée'
    });
  } catch (error) {
    console.error('Erreur POST /generate-signed-url:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur',
      error: error.message
    });
  }
});

/**
 * GET /api/files/access/:token
 * Accéder au fichier avec un token signé
 * Télécharger ou retourner le fichier
 */
router.get('/access/:token', verifyFileSignature, async (req, res) => {
  try {
    const { documentId, documentType, userId } = req.fileRequest;
    const download = req.query.download === 'true'; // Si true, force le download

    // Construire le chemin du fichier en fonction du type de document
    let filePath = null;

    if (documentType === 'cv') {
      filePath = path.join(UPLOADS_DIR, 'cvs', `${userId}-cv.pdf`);
    } else if (documentType === 'cnib_recto') {
      filePath = path.join(UPLOADS_DIR, 'cnib', `${userId}-recto.jpg`);
    } else if (documentType === 'cnib_verso') {
      filePath = path.join(UPLOADS_DIR, 'cnib', `${userId}-verso.jpg`);
    } else if (documentType === 'photo') {
      filePath = path.join(UPLOADS_DIR, 'profile-photos', `${userId}-photo.jpg`);
    }

    if (!filePath || !fs.existsSync(filePath)) {
      return res.status(404).json({
        success: false,
        message: 'Fichier non trouvé'
      });
    }

    // Déterminer le type MIME
    const ext = path.extname(filePath).toLowerCase();
    const mimeType = {
      '.pdf': 'application/pdf',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif'
    }[ext] || 'application/octet-stream';

    res.setHeader('Content-Type', mimeType);

    if (download) {
      res.setHeader('Content-Disposition', `attachment; filename="document${ext}"`);
      res.setHeader('Content-Transfer-Encoding', 'binary');
    } else {
      res.setHeader('Content-Disposition', `inline; filename="document${ext}"`);
    }

    // Ajouter des headers de sécurité
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');

    // Envoyer le fichier
    res.sendFile(filePath);
  } catch (error) {
    console.error('Erreur GET /access/:token:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur',
      error: error.message
    });
  }
});

/**
 * GET /api/files/document-info/:token
 * Obtenir les infos d'un document sans le télécharger
 */
router.get('/document-info/:token', verifyFileSignature, async (req, res) => {
  try {
    const { documentId, documentType, userId } = req.fileRequest;

    let filePath = null;

    if (documentType === 'cv') {
      filePath = path.join(UPLOADS_DIR, 'cvs', `${userId}-cv.pdf`);
    } else if (documentType === 'cnib_recto') {
      filePath = path.join(UPLOADS_DIR, 'cnib', `${userId}-recto.jpg`);
    } else if (documentType === 'cnib_verso') {
      filePath = path.join(UPLOADS_DIR, 'cnib', `${userId}-verso.jpg`);
    } else if (documentType === 'photo') {
      filePath = path.join(UPLOADS_DIR, 'profile-photos', `${userId}-photo.jpg`);
    }

    if (!filePath || !fs.existsSync(filePath)) {
      return res.status(404).json({
        success: false,
        message: 'Fichier non trouvé'
      });
    }

    const stats = fs.statSync(filePath);

    res.json({
      success: true,
      documentId,
      documentType,
      userId,
      fileSize: stats.size,
      createdAt: stats.birthtime,
      updatedAt: stats.mtime,
      filename: path.basename(filePath),
      accessUrl: `/api/files/access/${req.params.token}`
    });
  } catch (error) {
    console.error('Erreur GET /document-info/:token:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur',
      error: error.message
    });
  }
});

/**
 * GET /api/files/access-logs/:candidatId
 * Consulter les logs d'accès aux documents d'un candidat (pour le candidat lui-même)
 */
router.get('/access-logs/:candidatId', authenticateToken, async (req, res) => {
  try {
    const candidatId = parseInt(req.params.candidatId, 10);
    const userId = typeof req.user.id === 'string' ? parseInt(req.user.id, 10) : req.user.id;

    // Seul le candidat peut voir ses propres logs
    if (userId !== candidatId) {
      return res.status(403).json({
        success: false,
        message: 'Accès refusé'
      });
    }

    const [logs] = await db.query(
      `SELECT * FROM document_access_logs 
       WHERE candidat_id = ?
       ORDER BY accessed_at DESC
       LIMIT 100`,
      [candidatId]
    );

    res.json({
      success: true,
      logs: logs || [],
      total: logs ? logs.length : 0
    });
  } catch (error) {
    console.error('Erreur GET /access-logs/:candidatId:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur',
      error: error.message
    });
  }
});

module.exports = router;
