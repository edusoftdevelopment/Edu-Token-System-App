// ignore_for_file: strict_raw_type

part of 'network.dart';

class NetworkHelper {
  //! Constructor with baseUrl
  NetworkHelper({required String baseUrl}) : _dio = _configureDio(baseUrl);

  late final Dio _dio;

  //  ! Configuring Dio
  static Dio _configureDio(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
      ),
    );

    if (!kReleaseMode) {
      // ! Using PrettyDioLogger to log requests and responses in debug mode
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
      );
    }

    // ! This is useful for debugging and development purposes
    final logInterceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) log('Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          log('Response: ${response.statusCode} ${response.data}');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        ErrorHandler.handle(error).failure!;
        return handler.next(error);
      },
    );
    dio.interceptors.add(logInterceptor);

    return dio;
  }

  // ! Using this method to make a (Get)
  Future<Response> get({
    required String endPoint,
    Map<String, dynamic>? params,
  }) async {
    return _dio.get<dynamic>(endPoint, queryParameters: params);
  }

  // ! Using this method to make a (Post)
  Future<Response> post({
    required String endPoint,
    Map<String, dynamic>? params,
    Map<String, dynamic>? queryParams,
  }) async {
    return _dio.post<dynamic>(
      endPoint,
      data: params,
      queryParameters: queryParams,
    );
  }

  // ! Using this method to make a (Put)
  Future<Response> put({
    required String endPoint,
    Map<String, dynamic>? params,
  }) async {
    return _dio.put<dynamic>(endPoint, data: params);
  }

  // ! Using this method to make a (Delete)
  Future<Response> delete({
    required String endPoint,
    Map<String, dynamic>? params,
    Map<String, dynamic>? queryParams,
  }) async {
    return _dio.delete<dynamic>(
      endPoint,
      data: params,
      queryParameters: queryParams,
    );
  }

  // ! Using this method to make a (Patch)
  Future<Response> patch({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
  }) async {
    return _dio.patch(
      endPoint,
      data: data,
      queryParameters: queryParams,
    );
  }
}
