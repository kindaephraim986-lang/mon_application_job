/**
 * routes/profilePhotos.js
 * Routes pour gérer les photos de profil des candidats
 */

const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const profilePhotoService = require('../services/profilePhotoService');
const { authenticateToken } = require('../middleware/auth');

// Configuration multer pour les uploads de photos
// Utiliser memoryStorage afin de fournir `req.file.buffer` attendu par le service
const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB max
  fileFilter: (req, file, cb) => {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Type de fichier non supporté. Utilisez JPG, PNG, GIF ou WebP.'));
    }
  }
});

/**
 * POST /api/profile-photos/upload
 * Uploader une nouvelle photo de profil
 */
router.post('/upload', authenticateToken, upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Aucun fichier fourni'
      });
    }

    const candidatId = req.user.id;
    const imageBuffer = req.file.buffer;
    const originalName = req.file.originalname;

    const result = await profilePhotoService.saveProfilePhoto(candidatId, imageBuffer, originalName);

    res.json({
      ...result,
      message: 'Photo de profil mise à jour avec succès'
    });
  } catch (error) {
    console.error('Erreur POST /upload:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'upload de la photo',
      error: error.message
    });
  }
});

/**
 * GET /api/profile-photos/current
 * Récupérer la photo de profil actuelle
 */
router.get('/current', authenticateToken, async (req, res) => {
  try {
    const candidatId = req.user.id;
    const result = await profilePhotoService.getCurrentProfilePhoto(candidatId);

    if (result.success) {
      // Ajouter cache buster à l'URL
      const cacheBuster = `${Date.now()}`;
      result.photoUrl = `${result.photoUrl}?cb=${cacheBuster}`;
    }

    res.json(result);
  } catch (error) {
    console.error('Erreur GET /current:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur',
      error: error.message
    });
  }
});

/**
 * GET /api/profile-photos/history
 * Récupérer l'historique des photos
 */
router.get('/history', authenticateToken, async (req, res) => {
  try {
    const candidatId = req.user.id;
    const limit = req.query.limit ? parseInt(req.query.limit) : 10;

    const result = await profilePhotoService.getPhotoHistory(candidatId, limit);
    res.json(result);
  } catch (error) {
    console.error('Erreur GET /history:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur',
      error: error.message
    });
  }
});

/**
 * DELETE /api/profile-photos/:photoId
 * Supprimer une photo spécifique
 */
router.delete('/:photoId', authenticateToken, async (req, res) => {
  try {
    const photoId = req.params.photoId;
    const candidatId = req.user.id;

    const result = await profilePhotoService.deleteProfilePhoto(photoId, candidatId);
    res.json(result);
  } catch (error) {
    console.error('Erreur DELETE /:photoId:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur',
      error: error.message
    });
  }
});

/**
 * GET /api/profile-photos/public/:candidatId
 * Récupérer la photo d'un autre candidat (pour afficher dans les offres)
 * N'a pas besoin d'authentification
 */
router.get('/public/:candidatId', async (req, res) => {
  try {
    const candidatId = req.params.candidatId;

    const result = await profilePhotoService.getCurrentProfilePhoto(candidatId);

    if (result.success) {
      const cacheBuster = `${Date.now()}`;
      result.photoUrl = `${result.photoUrl}?cb=${cacheBuster}`;
    }

    res.json(result);
  } catch (error) {
    console.error('Erreur GET /public/:candidatId:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur',
      error: error.message
    });
  }
});

module.exports = router;
