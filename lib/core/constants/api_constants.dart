class ApiConstants {
  static const String baseUrl = 
      'https://745f0d73-41cc-4a5d-beef-93fd274e6bd8-dev.e1-us-east-azure.choreoapis.dev/store/store-service/v1.0';
  
  static const String healthEndpoint = '/health';
  static const String itemsEndpoint = '/items';
  static const String itemsFilterEndpoint = '/items/filter';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 15);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
