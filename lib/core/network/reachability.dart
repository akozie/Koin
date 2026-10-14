import 'dart:io';

import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import 'network_info.dart';

/// Whether a failed request means the server could not be reached at all
/// (as opposed to the server answering with an error).
bool isUnreachableError(DioException e) => switch (e.type) {
  DioExceptionType.connectionError ||
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout => true,
  DioExceptionType.unknown => e.error is SocketException,
  _ => false,
};

/// Probes our own backend. Any HTTP response, even an error status, proves
/// the internet works; only a failure to reach the server counts as offline.
ReachabilityProbe httpReachabilityProbe({String url = '${AppConstants.apiBaseUrl}/test'}) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: AppConstants.reachabilityTimeout,
      receiveTimeout: AppConstants.reachabilityTimeout,
      validateStatus: (_) => true,
    ),
  );
  return () async {
    try {
      await dio.head<void>(url);
      return true;
    } on DioException catch (e) {
      return !isUnreachableError(e);
    }
  };
}

/// Feeds the outcome of every API request into [NetworkInfo], so a lost
/// internet connection is detected the moment a request fails, without
/// waiting for the operating system to notice.
class ReachabilityInterceptor extends Interceptor {
  ReachabilityInterceptor(this._networkInfo);

  final NetworkInfo _networkInfo;

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _networkInfo.reportReachable();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isUnreachableError(err)) {
      _networkInfo.reportUnreachable();
    } else if (err.response != null) {
      _networkInfo.reportReachable();
    }
    handler.next(err);
  }
}
