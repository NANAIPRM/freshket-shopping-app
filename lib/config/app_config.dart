class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 5);

  static const Map<String, String> headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static const String recommendedProductsPath = '/recommended-products';
  static const String productsPath = '/products';

  static const bool debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: true,
  );
}
