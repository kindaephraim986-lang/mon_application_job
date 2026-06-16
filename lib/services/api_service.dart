import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  static const String _envApiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// Base URL du backend.
  ///
  /// En production, définis-le avec :
  /// `--dart-define=API_BASE_URL=https://ton-domaine.com/api`
  static String get baseUrl {
    if (_envApiBaseUrl.isNotEmpty) {
      return _envApiBaseUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:3001/api';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3001/api';
      default:
        return 'http://localhost:3001/api';
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ========== AUTHENTIFICATION ==========
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String userType,
    Map<String, dynamic>? extraData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'userType': userType,
        ...?extraData,
      }),
    );

    final data = jsonDecode(response.body);
    
    if (response.statusCode == 201) {
      if (data['token'] != null) {
        await StorageService.saveToken(data['token']);
        await StorageService.saveUser(data['user']);
      }
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur lors de l\'inscription');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      if (data['token'] != null) {
        await StorageService.saveToken(data['token']);
        await StorageService.saveUser(data['user']);
      }
      return data;
    } else {
      throw Exception(data['message'] ?? 'Email ou mot de passe incorrect');
    }
  }

  static Future<void> logout() async {
    await StorageService.clear();
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    return await StorageService.getUser();
  }

  static Future<Map<String, dynamic>> getMyProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await StorageService.saveUser(data);
      return data;
    }

    throw Exception(data['message'] ?? 'Impossible de charger le profil');
  }

  static Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }

  static Future<String?> getToken() async {
    return await StorageService.getToken();
  }

  static Future<void> saveToken(String token) async {
    await StorageService.saveToken(token);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await StorageService.saveUser(user);
  }

  static Future<void> clearAuth() async {
    await StorageService.clear();
  }

  // ========== OFFRES ==========
  static Future<List<dynamic>> getOffres({
    String? search,
    String? type,
    String? lieu,
  }) async {
    String url = '$baseUrl/offers';
    final queryParams = <String, String>{};
    if (search != null) queryParams['search'] = search;
    if (type != null) queryParams['type'] = type;
    if (lieu != null) queryParams['lieu'] = lieu;
    
    if (queryParams.isNotEmpty) {
      url += '?${Uri(queryParameters: queryParams).query}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des offres');
    }
  }

  static Future<Map<String, dynamic>> createOffre({
    required String titre,
    required String description,
    required String typeContrat,
    required String lieu,
    String? competences,
    String? niveau,
    String? experience,
    String? salaire,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/offers'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'titre': titre,
        'description': description,
        'typeContrat': typeContrat,
        'lieu': lieu,
        'competences': competences,
        'niveau': niveau,
        'experience': experience,
        'salaire': salaire,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur lors de la création');
    }
  }

  static Future<List<dynamic>> getMyOffers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/offers/my-offers'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement');
    }
  }

  static Future<void> deleteOffer(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/offers/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Erreur lors de la suppression');
    }
  }

  // ========== CANDIDATURES ==========
  static Future<Map<String, dynamic>> createApplication({
    required String offreId,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/applications'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'offreId': offreId,
        'message': message,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur lors de la candidature');
    }
  }

  static Future<Map<String, dynamic>> applyForOffer({
    required String offreId,
    String? message,
    String? token,
  }) async {
    if (token != null) {
      final response = await http.post(
        Uri.parse('$baseUrl/applications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'offreId': offreId,
          'message': message,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de la candidature');
      }
    }

    return await createApplication(offreId: offreId, message: message);
  }

  static Future<List<dynamic>> getMyApplications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/applications/my-applications'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement');
    }
  }

  static Future<List<dynamic>> getCompanyApplications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/applications/company-applications'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement');
    }
  }

  static Future<Map<String, dynamic>> updateApplicationStatus(
    String id,
    String status,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/applications/$id/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erreur lors de la mise à jour');
    }
  }
}