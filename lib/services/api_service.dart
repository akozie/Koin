import 'dart:io';

import 'package:dio/dio.dart';

import '../core/errors/exceptions.dart';
import '../core/network/network_info.dart';
import '../models/quote.dart';

/// Public REST API data source (https://dummyjson.com).
abstract interface class ApiService {
  Future<List<Quote>> fetchQuotes({int limit = 10, int skip = 0});
}

class ApiServiceImpl implements ApiService {
  ApiServiceImpl(this._dio, this._networkInfo);

  final Dio _dio;
  final NetworkInfo _networkInfo;

  @override
  Future<List<Quote>> fetchQuotes({int limit = 10, int skip = 0}) async {
    final json = await _get('/quotes', query: {'limit': limit, 'skip': skip});
    final quotes = json['quotes'];
    if (quotes is! List) {
      throw const ServerException('Malformed quotes response');
    }
    return quotes.cast<Map<String, dynamic>>().map(Quote.fromJson).toList(growable: false);
  }

  Future<Map<String, dynamic>> _get(String path, {Map<String, dynamic>? query}) async {
    if (!await _networkInfo.isConnected) throw const NetworkException();
    try {
      final response = await _dio.get<Map<String, dynamic>>(path, queryParameters: query);
      final data = response.data;
      if (data == null) throw const ServerException('Empty response body');
      return data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  AppException _mapDioException(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => const RequestTimeoutException(),
    DioExceptionType.connectionError => const NetworkException(),
    DioExceptionType.badResponse => ServerException(
      'Server responded with ${e.response?.statusCode}',
      statusCode: e.response?.statusCode,
    ),
    _ when e.error is SocketException => const NetworkException(),
    _ => ServerException(e.message ?? 'Request failed'),
  };
}
