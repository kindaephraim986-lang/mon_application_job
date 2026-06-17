class EnvConfig {
  // Changer entre TEST et PRODUCTION
  static const Environment current = Environment.test;
  
  static const Map<Environment, ApiConfig> _configs = {
    Environment.test: ApiConfig(
      baseUrl: 'https://sandbox-api.yengapay.com/v1',
      apiKey: 'sandbox_test_key_demo_123456789',
      apiSecret: 'sandbox_test_secret_demo_987654321',
      isSandbox: true,
    ),
    Environment.production: ApiConfig(
      baseUrl: 'https://api.yengapay.com/v1',
      apiKey: 'VOTRE_API_KEY_PRODUCTION',
      apiSecret: 'VOTRE_API_SECRET_PRODUCTION',
      isSandbox: false,
    ),
  };

  static ApiConfig get config => _configs[current]!;
}

enum Environment { test, production }

class ApiConfig {
  final String baseUrl;
  final String apiKey;
  final String apiSecret;
  final bool isSandbox;

  const ApiConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.apiSecret,
    required this.isSandbox,
  });
}


