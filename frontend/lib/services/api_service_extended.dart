/// lib/services/api_service_extended.dart
/// Extension du ApiService avec les nouvelles méthodes (photos, notifications, documents)

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiServiceExtended {
  static String get baseUrl => AppConfig.baseUrl;

  // ===================== PHOTOS DE PROFIL =====================

  /// Uploader une photo de profil
  static Future<Map<String, dynamic>> uploadProfilePhoto(Uint8List imageBytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse('$baseUrl/api/profile-photos/upload');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes(
        'photo',
        imageBytes,
        filename: 'profile_photo.jpg',
      ));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        return {
          'success': true,
          ...data,
        };
      }

      return {
        'success': false,
        'message': 'Erreur lors de l\'upload',
        'statusCode': response.statusCode,
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur: $error',
      };
    }
  }

  /// Récupérer la photo actuelle du candidat
  static Future<Map<String, dynamic>> getCurrentProfilePhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/profile-photos/current'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
        'message': 'Erreur lors de la récupération de la photo',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur: $error',
      };
    }
  }

  /// Récupérer l'historique des photos
  static Future<Map<String, dynamic>> getPhotoHistory(int limit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/profile-photos/history?limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
        'photos': [],
      };
    } catch (error) {
      return {
        'success': false,
        'photos': [],
        'message': 'Erreur: $error',
      };
    }
  }

  /// Supprimer une photo
  static Future<Map<String, dynamic>> deleteProfilePhoto(int photoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.delete(
        Uri.parse('$baseUrl/api/profile-photos/$photoId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
        'message': 'Erreur lors de la suppression',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur: $error',
      };
    }
  }

  // ===================== NOTIFICATIONS =====================

  /// Récupérer les notifications non lues
  static Future<Map<String, dynamic>> getUnreadNotifications(int limit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/unread?limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
        'notifications': [],
      };
    } catch (error) {
      return {
        'success': false,
        'notifications': [],
        'message': 'Erreur: $error',
      };
    }
  }

  /// Récupérer toutes les notifications
  static Future<Map<String, dynamic>> getAllNotifications(int limit, int offset) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/all?limit=$limit&offset=$offset'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
        'notifications': [],
      };
    } catch (error) {
      return {
        'success': false,
        'notifications': [],
        'message': 'Erreur: $error',
      };
    }
  }

  /// Récupérer le count de notifications non lues
  static Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
        'unreadCount': 0,
      };
    } catch (error) {
      return {
        'success': false,
        'unreadCount': 0,
        'message': 'Erreur: $error',
      };
    }
  }

  /// Marquer une notification comme lue
  static Future<Map<String, dynamic>> markNotificationAsRead(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
        'message': 'Erreur',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur: $error',
      };
    }
  }

  /// Marquer toutes les notifications comme lues
  static Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur: $error',
      };
    }
  }

  /// Supprimer une notification
  static Future<Map<String, dynamic>> deleteNotification(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.delete(
        Uri.parse('$baseUrl/api/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur: $error',
      };
    }
  }

  /// Supprimer les notifications lues
  static Future<Map<String, dynamic>> deleteReadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.delete(
        Uri.parse('$baseUrl/api/notifications/delete-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur: $error',
      };
    }
  }

  // ===================== DOCUMENTS =====================

  /// Générer une URL signée pour un document
  static Future<Map<String, dynamic>> generateSignedUrl({
    required int documentId,
    required String documentType,
    required int candidatId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/api/files/generate-signed-url'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'documentId': documentId,
          'documentType': documentType,
          'candidatId': candidatId,
        }),
      );

      if (response.statusCode == 200) {
        return {
          ...jsonDecode(response.body),
          'statusCode': response.statusCode,
        };
      } else if (response.statusCode == 402) {
        return {
          'success': false,
          'message': 'Abonnement requis',
          'code': 'SUBSCRIPTION_REQUIRED',
          'requiresSubscription': true,
          'statusCode': 402,
          ...jsonDecode(response.body),
        };
      }

      return {
        'success': false,
        'message': 'Erreur',
        'statusCode': response.statusCode,
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur: $error',
      };
    }
  }

  /// Obtenir les infos d'un document
  static Future<Map<String, dynamic>> getDocumentInfo(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/files/document-info/$token'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
        'message': 'Erreur',
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur: $error',
      };
    }
  }

  /// Récupérer les logs d'accès aux documents
  static Future<Map<String, dynamic>> getDocumentAccessLogs(int candidatId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/files/access-logs/$candidatId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
        'logs': [],
      };
    } catch (error) {
      return {
        'success': false,
        'logs': [],
        'message': 'Erreur: $error',
      };
    }
  }

  // ===================== HELPER METHODS =====================
}
