/**
 * middleware/fileSignature.js
 * Middleware pour générer et vérifier les URLs signées pour les documents
 */

const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

const FILE_SIGNATURE_SECRET = process.env.FILE_SIGNATURE_SECRET || 'your-secret-key-change-this';
const FILE_URL_EXPIRY = 3600; // 1 heure

/**
 * Générer une URL signée pour accéder à un document
 * Utilisé lors du clic "Télécharger" ou "Voir"
 */
const generateSignedFileUrl = async (documentId, documentType, userId, requesterId = null, requesterType = null) => {
  try {
    // Créer un token JWT avec expiration
    const token = jwt.sign(
      {
        documentId,
        documentType,
        userId,
        requesterId,
        requesterType,
        iat: Math.floor(Date.now() / 1000)
      },
      FILE_SIGNATURE_SECRET,
      { expiresIn: FILE_URL_EXPIRY }
    );

    // Sauvegarder le token en base de données
    const expiresAt = new Date(Date.now() + FILE_URL_EXPIRY * 1000);
    await db.query(
      `INSERT INTO signed_file_urls 
       (document_id, document_type, user_id, access_token, requester_id, requester_type, expires_at)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [documentId, documentType, userId, token, requesterId, requesterType, expiresAt]
    );

    // Retourner l'URL signée
    return `/api/files/access/${token}`;
  } catch (error) {
    console.error('Erreur generateSignedFileUrl:', error);
    throw error;
  }
};

/**
 * Middleware : Vérifier un token de fichier signé
 * Utilisé lors de l'accès au document
 */
const verifyFileSignature = async (req, res, next) => {
  try {
    const token = req.params.token || req.query.token;

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Token de signature manquant',
        code: 'NO_SIGNATURE'
      });
    }

    // Vérifier le token JWT
    let decoded;
    try {
      decoded = jwt.verify(token, FILE_SIGNATURE_SECRET);
    } catch (jwtError) {
      return res.status(401).json({
        success: false,
        message: 'Token invalide ou expiré',
        code: 'INVALID_SIGNATURE',
        details: jwtError.message
      });
    }

    // Vérifier que le token existe en base et n'a pas expiré
    const [urlRecords] = await db.query(
      `SELECT * FROM signed_file_urls 
       WHERE access_token = ? AND expires_at > NOW()`,
      [token]
    );

    if (!urlRecords || urlRecords.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'URL signée expirée ou révoquée',
        code: 'EXPIRED_SIGNATURE'
      });
    }

    // Vérifier l'abonnement du requester (si c'est une entreprise)
    if (decoded.requesterType === 'entreprise' && decoded.requesterId) {
      const [subscriptions] = await db.query(
        `SELECT * FROM subscriptions 
         WHERE entreprise_id = ? AND status = 'active' AND end_date > NOW()
         LIMIT 1`,
        [decoded.requesterId]
      );

      if (!subscriptions || subscriptions.length === 0) {
        return res.status(402).json({
          success: false,
          message: 'Abonnement requis pour accéder à ce document',
          code: 'SUBSCRIPTION_REQUIRED'
        });
      }
    }

    // Logger l'accès
    await db.query(
      `UPDATE signed_file_urls SET accessed_at = NOW() WHERE access_token = ?`,
      [token]
    );

    await db.query(
      `INSERT INTO document_access_logs 
       (document_id, document_type, candidat_id, entreprise_id, access_type, ip_address, user_agent)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        decoded.documentId,
        decoded.documentType,
        decoded.userId,
        decoded.requesterId || null,
        'view',
        req.ip,
        req.get('user-agent')
      ]
    );

    // Attacher les infos décodées à la requête
    req.fileRequest = decoded;
    req.fileToken = urlRecords[0];
    next();
  } catch (error) {
    console.error('Erreur verifyFileSignature:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur',
      error: error.message
    });
  }
};

/**
 * Middleware : Vérifier que l'utilisateur peut accéder à son propre profil
 */
const verifyProfileAccess = async (req, res, next) => {
  try {
    const candidatId = req.params.candidat_id ? parseInt(req.params.candidat_id, 10) : req.body?.candidat_id ? parseInt(req.body.candidat_id, 10) : null;
    const requesterType = req.user?.type || req.user?.type_utilisateur || req.user?.user_type; // 'candidat' ou 'entreprise'
    const requesterId = typeof req.user?.id === 'string' ? parseInt(req.user.id, 10) : req.user?.id;

    // Si c'est le candidat lui-même
    if (requesterType === 'candidat' && requesterId === candidatId) {
      return next();
    }

    // Si c'est une entreprise, vérifier l'abonnement
    if (requesterType === 'entreprise') {
      const [subscriptions] = await db.query(
        `SELECT * FROM subscriptions 
         WHERE entreprise_id = ? AND status = 'active' AND end_date > NOW()
         LIMIT 1`,
        [requesterId]
      );

      if (!subscriptions || subscriptions.length === 0) {
        return res.status(402).json({
          success: false,
          message: 'Abonnement requis pour accéder aux informations du candidat',
          code: 'SUBSCRIPTION_REQUIRED'
        });
      }

      return next();
    }

    return res.status(403).json({
      success: false,
      message: 'Accès refusé',
      code: 'UNAUTHORIZED'
    });
  } catch (error) {
    console.error('Erreur verifyProfileAccess:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur',
      error: error.message
    });
  }
};

module.exports = {
  generateSignedFileUrl,
  verifyFileSignature,
  verifyProfileAccess
};
