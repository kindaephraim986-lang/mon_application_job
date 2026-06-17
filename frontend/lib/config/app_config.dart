import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Configuration globale de l'application Job research
class AppConfig {
  // ==================== ENVIRONNEMENT ====================
  
  /// L'environnement actuel (development, production)
  static const String environment = 'development';

  /// URL API personnalisée via --dart-define=API_BASE_URL
  static const String _customBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  
  /// Version de l'application
  static const String appVersion = '1.0.0';
  
  // ==================== SERVEUR ====================
  
  /// Configuration du serveur selon l'environnement
  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3001/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3001/api'; // Android Emulator
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://localhost:3001/api';
      default:
        return 'http://localhost:3001/api';
    }
  }
  
  /// Timeout des requêtes (en secondes)
  static const int requestTimeout = 30;
  
  /// Nombre de tentatives en cas d'erreur
  static const int maxRetries = 3;
  
  // ==================== BASE DE DONNÉES ====================
  
  /// Nom de la base de données
  static const String databaseName = 'job_research_local.db';
  
  /// Clé pour SharedPreferences
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
  
  // ==================== SÉCURITÉ ====================
  
  /// Durée de vie du token (en minutes)
  static const int tokenExpirationMinutes = 30 * 24 * 60; // 30 jours
  
  /// Activer la validation SSL en production
  static const bool validateSSL = false; // À passer à true en production
  
  // ==================== LOGGING ====================
  
  /// Activer les logs détaillés
  static const bool debugLogging = true;
  
  /// Activer les logs d'API
  static const bool logApiRequests = true;
  
  // ==================== MESSAGES ====================
  
  /// Messages d'erreur par défaut
  static const Map<int, String> errorMessages = {
    400: 'Requête invalide',
    401: 'Non authentifié',
    403: 'Accès refusé',
    404: 'Non trouvé',
    500: 'Erreur serveur',
    503: 'Service indisponible',
  };
  
  // ==================== PAGINATION ====================
  
  /// Nombre d'éléments par page
  static const int itemsPerPage = 20;
  
  /// Nombre d'éléments à charger au démarrage
  static const int initialLoadCount = 10;
  
  // ==================== FICHIERS ====================
  
  /// Taille maximale des fichiers en MB
  static const int maxFileSize = 5;
  
  /// Types de fichiers autorisés
  static const List<String> allowedFileTypes = ['jpg', 'jpeg', 'png', 'pdf'];
  
  // ==================== CACHE ====================
  
  /// Durée du cache en minutes
  static const int cacheDurationMinutes = 60;
  
  /// Activer le cache
  static const bool enableCache = true;
  
  // ==================== THÈME ====================
  
  /// Couleur primaire
  static const int primaryColor = 0xFF1E3A8A; // Blue 900
  
  /// Couleur d'arrière-plan
  static const int backgroundColor = 0xFFF5F7FA;
  
  /// Couleur d'erreur
  static const int errorColor = 0xFFDC2626; // Red 600
  
  /// Couleur de succès
  static const int successColor = 0xFF16A34A; // Green 600
  
  /// Obtenir le message d'erreur pour un code HTTP
  static String getErrorMessage(int statusCode) {
    return errorMessages[statusCode] ?? 'Une erreur est survenue';
  }
  
  /// Vérifier si c'est en mode debug
  static bool get isDebug => environment == 'development';
  
  /// Vérifier si c'est en mode production
  static bool get isProduction => environment == 'production';
  
  /// Obtenir l'URL complète pour une route
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}

// ==================== PLATEFORME ====================

enum PlatformType {
  windows,
  web,
  android_emulator,
  androidDevice,
  ios,
  macos,
}

// La détection précise des plateformes natives peut être ajoutée
// ultérieurement avec des imports conditionnels. Pour l'instant
// on détecte automatiquement le web via `kIsWeb`.


