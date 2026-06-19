import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';
import 'api_service_extended.dart';

// Top-level helper functions to log requests/responses when AppConfig.logApiRequests is true
Future<http.Response> _httpGet(String url, {Map<String, String>? headers}) async {
  Logger.api('GET', url, headers: headers);
  final resp = await http.get(Uri.parse(url), headers: headers);
  Logger.apiResponse(resp.statusCode, resp.body);
  return resp;
}

Future<http.Response> _httpPost(String url, {Map<String, String>? headers, dynamic body}) async {
  final h = headers != null ? Map<String, String>.from(headers) : <String, String>{};
  if (body != null && (h['Content-Type'] == null)) h['Content-Type'] = 'application/json';
  final encodedBody = (body != null && h['Content-Type'] == 'application/json') ? jsonEncode(body) : body;
  Logger.api('POST', url, headers: h);
  final resp = await http.post(Uri.parse(url), headers: h, body: encodedBody);
  Logger.apiResponse(resp.statusCode, resp.body);
  return resp;
}

Future<http.Response> _httpPut(String url, {Map<String, String>? headers, dynamic body}) async {
  final h = headers != null ? Map<String, String>.from(headers) : <String, String>{};
  if (body != null && (h['Content-Type'] == null)) h['Content-Type'] = 'application/json';
  final encodedBody = (body != null && h['Content-Type'] == 'application/json') ? jsonEncode(body) : body;
  Logger.api('PUT', url, headers: h);
  final resp = await http.put(Uri.parse(url), headers: h, body: encodedBody);
  Logger.apiResponse(resp.statusCode, resp.body);
  return resp;
}

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;
  
  // ===================== AUTHENTIFICATION =====================
  
  /// Inscription d'un nouvel utilisateur
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String userType, // 'candidat' ou 'entreprise'
    required String nom,
    String? telephone,
    String? filiere,
    String? age,
    String? sexe,
    String? domicile,
    String? domaine,
    String? adresse,
    String? villeLieu,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      // Fusionner les données de base avec extraData
      final baseData = {
        'email': email,
        'password': password,
        'userType': userType,
        'nom': nom,
        'telephone': telephone,
      };

      final allData = {
        ...baseData,
        ...?extraData,
      };

      // Ajouter les champs spécifiques au type d'utilisateur
      if (userType == 'candidat') {
        allData['filiere'] = filiere ?? allData['filiere'];
        allData['age'] = age ?? allData['age'];
        allData['sexe'] = sexe ?? allData['sexe'];
        allData['domicile'] = domicile ?? allData['domicile'];
      } else {
        allData['nomSociete'] = nom;
        allData['domaine'] = domaine ?? allData['domaine'];
        allData['adresse'] = adresse ?? allData['adresse'];
        allData['villeLieu'] = villeLieu ?? allData['villeLieu'];
      }

      final response = await _httpPost('$baseUrl/auth/register', headers: {'Content-Type': 'application/json'}, body: allData);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return {'success': true, 'user': data['user'], 'token': data['token']};
      } else {
        String message = 'Erreur lors de l\'inscription';
        try {
          final bodyData = jsonDecode(response.body);
          if (bodyData is Map<String, dynamic>) {
            if (bodyData['message'] != null) {
              message = bodyData['message'].toString();
            } else if (bodyData['errors'] is List) {
              final errors = bodyData['errors'] as List;
              final joined = errors
                  .map((e) => e is Map<String, dynamic> ? e['msg']?.toString() ?? '' : e.toString())
                  .where((msg) => msg.isNotEmpty)
                  .join(' / ');
              if (joined.isNotEmpty) {
                message = joined;
              }
            }
          }
        } catch (_) {
          message = response.body.isNotEmpty ? response.body : message;
        }
        return {'success': false, 'message': message, 'status': response.statusCode};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Connexion
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpPost('$baseUrl/auth/login', headers: {'Content-Type': 'application/json'}, body: {'email': email, 'password': password});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return {'success': true, 'user': data['user'], 'token': data['token']};
      } else {
        return {'success': false, 'message': jsonDecode(response.body)['message'] ?? 'Erreur de connexion'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  /// Obtenir l'utilisateur actuel
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await _httpGet('$baseUrl/auth/me', headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      Logger.error('Erreur getCurrentUser: $e');
      return null;
    }
  }

  /// Mettre à jour le profil
  static Future<Map<String, dynamic>> updateProfile({
    required String nom,
    String? telephone,
    String? filiere,
    String? age,
    String? domicile,
    String? sexe,
    String? domaine,
    String? adresse,
    String? villeLieu,
    String? photoUrl,
    String? cvUrl,
    String? cnibRectoUrl,
    String? cnibVersoUrl,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Authentification requise'};

      final body = {
        'nom': nom,
        'telephone': telephone,
        'filiere': filiere,
        'age': age,
        'domicile': domicile,
        'sexe': sexe,
        'domaine': domaine,
        'adresse': adresse,
        'villeLieu': villeLieu,
        'photoUrl': photoUrl,
        'cvUrl': cvUrl,
        'cnibRectoUrl': cnibRectoUrl,
        'cnibVersoUrl': cnibVersoUrl,
      };

      final response = await _httpPut('$baseUrl/auth/profile', 
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: body
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'user': data['user'], 'message': data['message']};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Erreur lors de la mise à jour'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Vérifier les données OCR et les données utilisateur
  static Future<Map<String, dynamic>> verifyOcrData({
    required Map<String, dynamic> userData,
    required Map<String, dynamic> ocrData,
  }) async {
    try {
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json'
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _httpPost(
        '$baseUrl/ocr/verify',
        headers: headers,
        body: {
          'userData': userData,
          'ocrData': ocrData,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'comparison': data['comparison']};
      }

      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? 'Erreur de vérification OCR'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> extractOcrTextFromImageBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final token = await _getToken();
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ocr/extract'));
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(responseBody)};
      }

      String message = 'Erreur lors de l’extraction OCR';
      try {
        final data = jsonDecode(responseBody);
        if (data is Map<String, dynamic> && data['message'] != null) {
          message = data['message'].toString();
        }
      } catch (_) {}
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Déconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ===================== OFFRES D'EMPLOI =====================

  /// Obtenir toutes les offres (public)
  static Future<List<Map<String, dynamic>>> getOffers({
    String? search,
    String? type,
    String? lieu,
    String? field,
  }) async {
    try {
      String url = '$baseUrl/offers';
      List<String> params = [];
      
      if (search != null) params.add('search=${Uri.encodeComponent(search)}');
      if (type != null) params.add('type=${Uri.encodeComponent(type)}');
      if (lieu != null) params.add('lieu=${Uri.encodeComponent(lieu)}');
      if (field != null) params.add('field=${Uri.encodeComponent(field)}');
      
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await _httpGet(url);

      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      Logger.error('Erreur getOffers: $e');
      return [];
    }
  }

  /// Obtenir la liste des filières / domaines disponibles
  static Future<List<String>> getFields() async {
    try {
      final response = await _httpGet('$baseUrl/offers/fields');
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body);
        return List<String>.from(list.map((e) => e.toString()));
      }
      return [];
    } catch (e) {
      Logger.error('Erreur getFields: $e');
      return [];
    }
  }

  /// Obtenir le détail d'une offre
  static Future<Map<String, dynamic>?> getOfferDetail(int offerId) async {
    try {
      final response = await _httpGet('$baseUrl/offers/$offerId');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      Logger.error('Erreur getOfferDetail: $e');
      return null;
    }
  }

  /// Obtenir mes offres (entreprise)
  static Future<List<Map<String, dynamic>>> getMyOffers() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await _httpGet('$baseUrl/offers/my-offers', headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      Logger.error('Erreur getMyOffers: $e');
      return [];
    }
  }

  /// Créer une offre d'emploi
  static Future<Map<String, dynamic>> createOffer({
    required String titre,
    required String description,
    String? typeContrat,
    String? lieu,
    String? competences,
    String? domaine,
    String? niveau,
    String? experience,
    String? salaire,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final response = await _httpPost(
        '$baseUrl/offers',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'titre': titre,
          'description': description,
          'typeContrat': typeContrat,
          'lieu': lieu,
          'competences': competences,
          'domaine': domaine,
          'niveau': niveau,
          'experience': experience,
          'salaire': salaire,
        },
      );

      if (response.statusCode == 201) {
        return {'success': true, ...jsonDecode(response.body)};
      }
      return {'success': false, 'message': jsonDecode(response.body)['message']};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ===================== CANDIDATURES =====================

  /// Enregistrer un paiement pour candidature unitaire (500 FCFA)
  static Future<Map<String, dynamic>> registerCandidatePayment({
    required int offerId,
    required int amount,
    String paymentMethod = 'mobile_money',
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final response = await _httpPost(
        '$baseUrl/payments/apply',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'offreId': offerId,
          'montant': amount,
          'methode_paiement': paymentMethod,
        },
      );

      if (response.statusCode == 201) {
        return {'success': true, ...jsonDecode(response.body)};
      }
      return {'success': false, 'message': jsonDecode(response.body)['message']};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Vérifier si le candidat a un abonnement actif ou a payé pour cette offre
  static Future<Map<String, dynamic>> checkPaymentStatus(int offerId) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final response = await _httpGet('$baseUrl/payments/apply/$offerId', headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Erreur lors de la vérification'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Vérifier si l'utilisateur a un abonnement actif
  static Future<Map<String, dynamic>> checkSubscription() async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final response = await _httpGet('$baseUrl/payments/subscription', headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Erreur lors de la vérification'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Créer ou renouveler un abonnement
  static Future<Map<String, dynamic>> createSubscription({
    required int days,
    required int amount,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final response = await _httpPost(
        '$baseUrl/payments/subscription',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'days': days,
          'amount': amount,
        },
      );

      if (response.statusCode == 201) {
        return {'success': true, ...jsonDecode(response.body)};
      }

      final bodyData = jsonDecode(response.body);
      return {'success': false, 'message': bodyData['message'] ?? 'Erreur lors de la création de l\'abonnement'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Réinitialiser un abonnement sans le supprimer
  static Future<Map<String, dynamic>> resetSubscription() async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final response = await _httpPost(
        '$baseUrl/payments/subscription/reset',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      }

      final bodyData = jsonDecode(response.body);
      return {'success': false, 'message': bodyData['message'] ?? 'Erreur lors de la réinitialisation'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Postuler à une offre
  static Future<Map<String, dynamic>> applyToOffer(int offerId) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final response = await _httpPost(
        '$baseUrl/applications',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {'offreId': offerId},
      );

      if (response.statusCode == 201) {
        return {'success': true, ...jsonDecode(response.body)};
      } else if (response.statusCode == 402) {
        // 402 Payment Required
        return {'success': false, 'requiresPayment': true, 'message': jsonDecode(response.body)['message']};
      }
      return {'success': false, 'message': jsonDecode(response.body)['message']};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Mes candidatures (candidat)
  static Future<List<Map<String, dynamic>>> getMyApplications() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await _httpGet('$baseUrl/applications/my-applications', headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      Logger.error('Erreur getMyApplications: $e');
      return [];
    }
  }

  /// Candidatures reçues (entreprise)
  static Future<List<Map<String, dynamic>>> getCompanyApplications() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await _httpGet('$baseUrl/applications/company-applications', headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      Logger.error('Erreur getCompanyApplications: $e');
      return [];
    }
  }

  /// Mettre à jour le statut d'une candidature
  static Future<Map<String, dynamic>> updateApplicationStatus(
    int applicationId,
    String statut,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final response = await _httpPut(
        '$baseUrl/applications/$applicationId',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {'statut': statut},
      );

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      }
      return {'success': false, 'message': jsonDecode(response.body)['message']};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ===================== MESSAGES =====================

  /// Obtenir les conversations
  static Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await _httpGet('$baseUrl/messages/conversations', headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      Logger.error('Erreur getConversations: $e');
      return [];
    }
  }

  /// Obtenir les messages d'une conversation
  static Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await _httpGet('$baseUrl/messages/conversations/$conversationId', headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      Logger.error('Erreur getMessages: $e');
      return [];
    }
  }

  /// Envoyer un message
  static Future<Map<String, dynamic>> sendMessage({
    required int conversationId,
    required String message,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      final response = await _httpPost(
        '$baseUrl/messages',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'conversationId': conversationId,
          'texte': message,
        },
      );

      if (response.statusCode == 201) {
        return {'success': true, ...jsonDecode(response.body)};
      }
      return {'success': false, 'message': jsonDecode(response.body)['message']};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ===================== NOTIFICATIONS =====================

  /// Obtenir les notifications
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await _httpGet('$baseUrl/notifications', headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      Logger.error('Erreur getNotifications: $e');
      return [];
    }
  }

  // ===================== UPLOAD =====================

  /// Uploader un fichier
  static Future<Map<String, dynamic>> uploadFile(String filePath) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifié'};

      if (AppConfig.logApiRequests) print('[API] MULTIPART POST $baseUrl/upload file: $filePath');
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        return {'success': true, ...jsonDecode(responseBody)};
      }
      return {'success': false, 'message': 'Erreur lors du téléchargement'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Uploader un fichier depuis ses bytes (compatible Web et mobile/desktop)
  static Future<Map<String, dynamic>> uploadFileBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Non authentifiÃ©'};

      if (AppConfig.logApiRequests) print('[API] MULTIPART POST $baseUrl/upload file: $fileName');
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, ...jsonDecode(responseBody)};
      }

      String message = 'Erreur lors du tÃ©lÃ©chargement';
      try {
        final data = jsonDecode(responseBody);
        if (data is Map<String, dynamic> && data['message'] != null) {
          message = data['message'].toString();
        }
      } catch (_) {}
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // ===================== HELPER METHODS =====================

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Wrappers for extended API methods (defined in api_service_extended.dart)
  static Future<Map<String, dynamic>> uploadProfilePhoto(Uint8List imageBytes) => ApiServiceExtended.uploadProfilePhoto(imageBytes);

  static Future<Map<String, dynamic>> getCurrentProfilePhoto() => ApiServiceExtended.getCurrentProfilePhoto();

  static Future<Map<String, dynamic>> getPhotoHistory(int limit) => ApiServiceExtended.getPhotoHistory(limit);

  static Future<Map<String, dynamic>> deleteProfilePhoto(int photoId) => ApiServiceExtended.deleteProfilePhoto(photoId);

  static Future<Map<String, dynamic>> getUnreadNotifications(int limit) => ApiServiceExtended.getUnreadNotifications(limit);

  static Future<Map<String, dynamic>> getAllNotifications(int limit, int offset) => ApiServiceExtended.getAllNotifications(limit, offset);

  static Future<Map<String, dynamic>> getUnreadCount() => ApiServiceExtended.getUnreadCount();

  static Future<Map<String, dynamic>> markNotificationAsRead(int notificationId) => ApiServiceExtended.markNotificationAsRead(notificationId);

  static Future<Map<String, dynamic>> markAllNotificationsAsRead() => ApiServiceExtended.markAllNotificationsAsRead();

  static Future<Map<String, dynamic>> deleteNotification(int notificationId) => ApiServiceExtended.deleteNotification(notificationId);

  static Future<Map<String, dynamic>> deleteReadNotifications() => ApiServiceExtended.deleteReadNotifications();

  static Future<Map<String, dynamic>> generateSignedUrl({required int documentId, required String documentType, required int candidatId}) => ApiServiceExtended.generateSignedUrl(documentId: documentId, documentType: documentType, candidatId: candidatId);

  static Future<Map<String, dynamic>> getDocumentInfo(String token) => ApiServiceExtended.getDocumentInfo(token);

  static Future<Map<String, dynamic>> getDocumentAccessLogs(int candidatId) => ApiServiceExtended.getDocumentAccessLogs(candidatId);
}



