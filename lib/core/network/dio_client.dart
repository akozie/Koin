import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';

/// Builds the single configured [Dio] instance used by the app.
abstract final class DioClient {
  static Dio create({
    String baseUrl = AppConstants.apiBaseUrl,
    List<Interceptor> interceptors = const [],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        responseType: ResponseType.json,
        headers: const {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.addAll(interceptors);

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          responseBody: false,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }
    return dio;
  }
}
