/**
 * services/profilePhotoService.js
 * Service pour gérer les photos de profil des candidats
 */

const db = require('../config/database');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const UPLOAD_DIR = path.join(__dirname, '../uploads/profile-photos');

// Créer le répertoire s'il n'existe pas
if (!fs.existsSync(UPLOAD_DIR)) {
  fs.mkdirSync(UPLOAD_DIR, { recursive: true });
}

/**
 * Sauvegarder une photo de profil
 * @param {number} candidatId - ID du candidat
 * @param {Buffer} imageBuffer - Contenu de l'image en bytes
 * @param {string} originalName - Nom original du fichier
 * @returns {Promise<Object>} Infos de la photo sauvegardée
 */
const saveProfilePhoto = async (candidatId, imageBuffer, originalName) => {
  try {
    // Générer un nom unique avec timestamp et hash
    const ext = path.extname(originalName);
    const cacheBuster = crypto.randomBytes(8).toString('hex');
    const filename = `${candidatId}-${cacheBuster}${ext}`;
    const filePath = path.join(UPLOAD_DIR, filename);

    // Sauvegarder le fichier sur le disque
    fs.writeFileSync(filePath, imageBuffer);

    // Marquer les anciennes photos comme non-courantes
    await db.query(
      `UPDATE profile_photos SET is_current = FALSE WHERE candidat_id = ?`,
      [candidatId]
    );

    // Insérer la nouvelle photo dans la base
    const [result] = await db.query(
      `INSERT INTO profile_photos 
       (candidat_id, photo_filename, photo_url, photo_bytes, is_current)
       VALUES (?, ?, ?, ?, TRUE)`,
      [
        candidatId,
        filename,
        `/uploads/profile-photos/${filename}`,
        imageBuffer
      ]
    );

    // Mettre à jour le candidat avec la nouvelle photo et cache buster
    await db.query(
      `UPDATE candidats 
       SET photo_profil_url = ?, photo_cache_buster = ?, last_photo_update = NOW()
       WHERE id = ?`,
      [`/uploads/profile-photos/${filename}`, cacheBuster, candidatId]
    );

    return {
      success: true,
      photoId: result.insertId,
      photoUrl: `/uploads/profile-photos/${filename}?cb=${cacheBuster}`,
      cacheBuster,
      filename,
      uploadedAt: new Date()
    };
  } catch (error) {
    console.error('Erreur saveProfilePhoto:', error);
    throw error;
  }
};

/**
 * Récupérer la photo actuelle d'un candidat
 */
const getCurrentProfilePhoto = async (candidatId) => {
  try {
    const [photos] = await db.query(
      `SELECT * FROM profile_photos 
       WHERE candidat_id = ? AND is_current = TRUE
       ORDER BY uploaded_at DESC LIMIT 1`,
      [candidatId]
    );

    if (photos && photos.length > 0) {
      const photo = photos[0];
      return {
        success: true,
        photoId: photo.id,
        photoUrl: photo.photo_url,
        photoBytes: photo.photo_bytes,
        uploadedAt: photo.uploaded_at,
        cacheBuster: photo.photo_cache_buster || `${photo.id}`
      };
    }

    const [candidat] = await db.query(
      `SELECT profile_photo_url, photo_cache_buster, last_photo_update FROM candidats WHERE id = ?`,
      [candidatId]
    );

    if (candidat && candidat.length > 0 && candidat[0].profile_photo_url) {
      return {
        success: true,
        photoId: null,
        photoUrl: candidat[0].profile_photo_url,
        uploadedAt: candidat[0].last_photo_update,
        cacheBuster: candidat[0].photo_cache_buster || `${candidatId}`
      };
    }

    return {
      success: false,
      message: 'Aucune photo trouvée',
      photoUrl: null
    };
  } catch (error) {
    console.error('Erreur getCurrentProfilePhoto:', error);
    throw error;
  }
};

/**
 * Récupérer toutes les photos (historique) d'un candidat
 */
const getPhotoHistory = async (candidatId, limit = 10) => {
  try {
    const [photos] = await db.query(
      `SELECT id, photo_filename, photo_url, is_current, uploaded_at 
       FROM profile_photos 
       WHERE candidat_id = ?
       ORDER BY uploaded_at DESC
       LIMIT ?`,
      [candidatId, limit]
    );

    return {
      success: true,
      photos: photos || [],
      total: photos ? photos.length : 0
    };
  } catch (error) {
    console.error('Erreur getPhotoHistory:', error);
    throw error;
  }
};

/**
 * Supprimer une photo (garder au moins une)
 */
const deleteProfilePhoto = async (photoId, candidatId) => {
  try {
    // Vérifier combien de photos le candidat a
    const [photoCount] = await db.query(
      `SELECT COUNT(*) as count FROM profile_photos WHERE candidat_id = ?`,
      [candidatId]
    );

    if (photoCount[0].count <= 1) {
      return {
        success: false,
        message: 'Impossible de supprimer la seule photo du profil'
      };
    }

    // Récupérer le nom du fichier
    const [photoRecord] = await db.query(
      `SELECT photo_filename FROM profile_photos WHERE id = ? AND candidat_id = ?`,
      [photoId, candidatId]
    );

    if (!photoRecord || photoRecord.length === 0) {
      return {
        success: false,
        message: 'Photo non trouvée'
      };
    }

    // Supprimer le fichier du disque
    const filePath = path.join(UPLOAD_DIR, photoRecord[0].photo_filename);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    // Supprimer de la base
    await db.query(
      `DELETE FROM profile_photos WHERE id = ? AND candidat_id = ?`,
      [photoId, candidatId]
    );

    // Si c'était la photo courante, en activer une autre
    const [remainingPhotos] = await db.query(
      `SELECT id FROM profile_photos WHERE candidat_id = ? ORDER BY uploaded_at DESC LIMIT 1`,
      [candidatId]
    );

    if (remainingPhotos && remainingPhotos.length > 0) {
      await db.query(
        `UPDATE profile_photos SET is_current = TRUE WHERE id = ?`,
        [remainingPhotos[0].id]
      );
    }

    return {
      success: true,
      message: 'Photo supprimée avec succès'
    };
  } catch (error) {
    console.error('Erreur deleteProfilePhoto:', error);
    throw error;
  }
};

/**
 * Obtenir l'URL de photo avec cache buster pour forcer le rafraîchissement
 */
const getPhotoUrlWithCacheBuster = async (candidatId) => {
  try {
    const [candidat] = await db.query(
      `SELECT profile_photo_url, photo_cache_buster FROM candidats WHERE id = ?`,
      [candidatId]
    );

    if (candidat && candidat.length > 0 && candidat[0].profile_photo_url) {
      const url = candidat[0].profile_photo_url;
      const cacheBuster = candidat[0].photo_cache_buster || Math.random().toString(36);
      return `${url}?cb=${cacheBuster}&t=${Date.now()}`;
    }

    return null;
  } catch (error) {
    console.error('Erreur getPhotoUrlWithCacheBuster:', error);
    throw error;
  }
};

module.exports = {
  saveProfilePhoto,
  getCurrentProfilePhoto,
  getPhotoHistory,
  deleteProfilePhoto,
  getPhotoUrlWithCacheBuster,
  UPLOAD_DIR
};
