import 'package:dio/dio.dart';

class NetworkExceptions {
  static String getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. The service might be warming up, please try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Bad request. Please check your input.';
          case 401:
            return 'Unauthorized access.';
          case 403:
            return 'Access forbidden.';
          case 404:
            return 'Service not found.';
          case 500:
            return 'Internal server error.';
        }
        return 'Server error: ${statusCode ?? 'Unknown'}';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.badCertificate:
        return 'Certificate error.';
      case DioExceptionType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }
  
  static bool isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
           error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout;
  }
}
