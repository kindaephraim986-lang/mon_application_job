class AppConstants {
  // Clés et URL YengaPay
  static const String yengapayApiKey = String.fromEnvironment(
    'YENGAPAY_API_KEY',
    defaultValue: 'VOTRE_API_KEY_PRODUCTION_YENGAPAY',
  );

  static const String yengapayApiSecret = String.fromEnvironment(
    'YENGAPAY_API_SECRET',
    defaultValue: 'VOTRE_API_SECRET_PRODUCTION_YENGAPAY',
  );

  static const String yengapayBaseUrl = String.fromEnvironment(
    'YENGAPAY_BASE_URL',
    defaultValue: 'https://api.yengapay.com/v1',
  );
  static const String yengapayReturnUrl = String.fromEnvironment(
    'YENGAPAY_RETURN_URL',
    defaultValue: 'https://votre-domaine.com/payment/return',
  );

  static const String yengapayWebhookUrl = String.fromEnvironment(
    'YENGAPAY_WEBHOOK_URL',
    defaultValue: 'https://votre-domaine.com/api/webhook/yengapay',
  );
  
  // Backend URLs
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://votre-backend.com/api',
  );
  
  // Dev vs Prod
  static const bool isProduction = bool.fromEnvironment('IS_PRODUCTION', defaultValue: false);
}