/// lib/services/profile_photo_service.dart
/// Service pour gérer les photos de profil

import 'dart:typed_data';
import 'api_service_extended.dart';

class ProfilePhotoService {
  static final ProfilePhotoService _instance = ProfilePhotoService._internal();

  factory ProfilePhotoService() {
    return _instance;
  }

  ProfilePhotoService._internal();

  /// Uploader une nouvelle photo de profil
  /// @param imageBytes - Les bytes de l'image sélectionnée
  /// @return Map avec success, photoUrl, cacheBuster, etc.
  static Future<Map<String, dynamic>> uploadProfilePhoto(Uint8List imageBytes) async {
    try {
      final response = await ApiServiceExtended.uploadProfilePhoto(imageBytes);

      if (response['success'] == true) {
        return {
          'success': true,
          'photoUrl': response['photoUrl'],
          'cacheBuster': response['cacheBuster'],
          'photoId': response['photoId'],
          'message': 'Photo mise à jour avec succès'
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Erreur lors de l\'upload'
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur: $error'
      };
    }
  }

  /// Récupérer la photo actuelle du candidat
  /// @return La photo avec URL et cache buster
  static Future<Map<String, dynamic>> getCurrentPhoto() async {
    try {
      final response = await ApiServiceExtended.getCurrentProfilePhoto();

      if (response['success'] == true) {
        return {
          'success': true,
          'photoUrl': response['photoUrl'],
          'photoId': response['photoId'],
          'uploadedAt': response['uploadedAt']
        };
      }

      return {
        'success': false,
        'photoUrl': null
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur: $error'
      };
    }
  }

  /// Récupérer l'historique des photos
  static Future<List<Map<String, dynamic>>> getPhotoHistory({int limit = 10}) async {
    try {
      final response = await ApiServiceExtended.getPhotoHistory(limit);

      if (response['success'] == true && response['photos'] != null) {
        List<Map<String, dynamic>> photos = List<Map<String, dynamic>>.from(
          (response['photos'] as List).map((p) => {
            'id': p['id'],
            'photoUrl': p['photo_url'],
            'uploadedAt': p['uploaded_at'],
            'isCurrent': p['is_current'] == 1 || p['is_current'] == true
          })
        );
        return photos;
      }

      return [];
    } catch (error) {
      print('Erreur getPhotoHistory: $error');
      return [];
    }
  }

  /// Supprimer une photo du profil
  static Future<bool> deletePhoto(int photoId) async {
    try {
      final response = await ApiServiceExtended.deleteProfilePhoto(photoId);
      return response['success'] == true;
    } catch (error) {
      print('Erreur deletePhoto: $error');
      return false;
    }
  }

  /// Générer une URL avec cache buster pour forcer le rafraîchissement
  /// @param baseUrl - L'URL de base de la photo
  /// @return L'URL avec paramètres de cache buster
  static String generateCachedUrl(String baseUrl) {
    if (baseUrl.isEmpty) return '';

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final separator = baseUrl.contains('?') ? '&' : '?';

    return '$baseUrl${separator}t=$timestamp&cb=${DateTime.now().hashCode}';
  }
}




 