class ApiConstants {
  static const String baseUrl =
      'https://745f0d73-41cc-4a5d-beef-93fd274e6bd8-dev.e1-us-east-azure.choreoapis.dev/store/store-service/v1.0';

  // Fixed: Use full URLs instead of paths
  static const String healthEndpoint = '$baseUrl/health';
  static const String itemsEndpoint = '$baseUrl/items';
  static const String itemsFilterEndpoint = '$baseUrl/items/filter';

  // Increase timeouts for slow service
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
