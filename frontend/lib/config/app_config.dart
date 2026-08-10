import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Configuration globale de l'application Job research
class AppConfig {
  static const String _defaultPublicBaseUrl = 'https://job-research-tl8g.onrender.com';
  static const String _defaultLocalBaseUrl = 'http://localhost:3001';
  static const String _defaultAndroidLocalBaseUrl = 'http://10.0.2.2:3001';
  static const String _defaultIosLocalBaseUrl = 'http://localhost:3001';
  // ==================== ENVIRONNEMENT ====================
  
  /// L'environnement actuel (development, production)
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: bool.fromEnvironment('dart.vm.product') ? 'production' : 'development',
  );

  /// URL API personnalisée via --dart-define=API_BASE_URL.
  /// Pour un téléphone réel sur le même réseau Wi‑Fi, passez l’IP du PC hôte.
  static const String _customBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// URL API de production par défaut si la variable d'environnement n'est pas définie.
  /// Utilise le backend public Render configuré pour ce projet.
  static const String _productionBaseUrl = _defaultPublicBaseUrl;

  static String normalizeBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final withoutTrailingSlash = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;

    if (withoutTrailingSlash.endsWith('/api')) {
      return withoutTrailingSlash;
    }

    return '$withoutTrailingSlash/api';
  }
  
  /// Version de l'application
  static const String appVersion = '1.0.0';
  
  // ==================== SERVEUR ====================
  
  /// Configuration du serveur selon l'environnement
  static String resolveBaseUrl({
    required String environment,
    required TargetPlatform platform,
    required bool isWeb,
    required String customBaseUrl,
  }) {
    if (customBaseUrl.isNotEmpty) {
      return normalizeBaseUrl(customBaseUrl);
    }

    if (environment == 'production') {
      return normalizeBaseUrl(_productionBaseUrl);
    }

    if (platform == TargetPlatform.android) {
      return normalizeBaseUrl(_defaultAndroidLocalBaseUrl);
    }

    if (platform == TargetPlatform.iOS) {
      return normalizeBaseUrl(_defaultIosLocalBaseUrl);
    }

    if (isWeb) {
      final origin = Uri.base.origin;
      if (origin.startsWith('http://') || origin.startsWith('https://')) {
        final uri = Uri.parse(origin);
        if (environment == 'development' && (uri.host == 'localhost' || uri.host == '127.0.0.1') && uri.port != 3001) {
          return '$_defaultLocalBaseUrl/api';
        }
        return '$origin/api';
      }
      return '$_defaultLocalBaseUrl/api';
    }

    switch (platform) {
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return '$_defaultLocalBaseUrl/api';
      default:
        return normalizeBaseUrl(_defaultPublicBaseUrl);
    }
  }

  static String get baseUrl {
    return resolveBaseUrl(
      environment: environment,
      platform: defaultTargetPlatform,
      isWeb: kIsWeb,
      customBaseUrl: _customBaseUrl,
    );
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
  
  /// Activer la validation SSL selon l'environnement
  static bool get validateSSL => isProduction;
  
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
  androidEmulator,
  androidDevice,
  ios,
  macos,
}

// La détection précise des plateformes natives peut être ajoutée
// ultérieurement avec des imports conditionnels. Pour l'instant
// on détecte automatiquement le web via `kIsWeb`.



