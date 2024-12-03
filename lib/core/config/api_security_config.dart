class ApiSecurityConfig {
  static const String apiKey = 'ud9u9de93302';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration responseTimeout = Duration(seconds: 30);

  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'api_key': apiKey,
      };
}
