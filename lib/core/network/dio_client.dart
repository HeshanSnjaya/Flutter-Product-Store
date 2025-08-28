import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: ApiConstants.defaultHeaders,
    ));

    // Add interceptors
    dio.interceptors.add(_createLoggingInterceptor());
    dio.interceptors.add(_createRetryInterceptor());

    return dio;
  }

  static LogInterceptor _createLoggingInterceptor() {
    return LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: false,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) {
        assert(() {
          print('🌐 API: $obj');
          return true;
        }());
      },
    );
  }

  static InterceptorsWrapper _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error) && error.requestOptions.extra['retryCount'] == null) {
          error.requestOptions.extra['retryCount'] = 1;
          
          await Future.delayed(const Duration(seconds: 2));
          
          try {
            final response = await instance.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            // If retry fails, continue with original error
          }
        }
        
        handler.next(error);
      },
    );
  }

  static bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           (error.type == DioExceptionType.badResponse && 
            error.response?.statusCode == 503); 
  }
}
