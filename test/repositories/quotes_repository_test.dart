import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:koins/core/errors/exceptions.dart';
import 'package:koins/core/errors/failures.dart';
import 'package:koins/core/errors/result.dart';
import 'package:koins/models/cached_data.dart';
import 'package:koins/models/quote.dart';
import 'package:koins/repositories/quotes_repository.dart';
import 'package:koins/services/cache_storage_service.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';

void main() {
  late MockApiService api;
  late MockCacheStorageService cache;
  late QuotesRepositoryImpl repository;

  const quotes = [Quote(id: 1, text: 'Save first, spend later.', author: 'Anon')];
  final savedAt = DateTime(2026, 10, 13, 10, 42);

  setUp(() {
    api = MockApiService();
    cache = MockCacheStorageService();
    repository = QuotesRepositoryImpl(api, cache, random: Random(1));
    when(() => cache.write(any(), any())).thenAnswer((_) async {});
  });

  void stubApi(Future<List<Quote>> Function() answer) => when(
    () => api.fetchQuotes(
      limit: any(named: 'limit'),
      skip: any(named: 'skip'),
    ),
  ).thenAnswer((_) => answer());

  test('returns fresh data and caches it', () async {
    stubApi(() async => quotes);

    final result = await repository.getQuotes();

    expect((result as Ok<CachedData<List<Quote>>>).value, const CachedData(quotes));
    verify(() => cache.write(QuotesRepositoryImpl.cacheKey, [quotes.first.toJson()])).called(1);
  });

  test('only shows quotes from the curated allowlist', () async {
    stubApi(
      () async => const [
        Quote(id: 1, text: 'Curated', author: 'Rumi'),
        Quote(id: 999, text: 'Not reviewed', author: 'Unknown'),
      ],
    );

    final result = await repository.getQuotes();

    final shown = (result as Ok<CachedData<List<Quote>>>).value.data;
    expect(shown.map((q) => q.id), [1]);
  });

  test('falls back to cached data when offline, tagged with when it was saved', () async {
    stubApi(() async => throw const NetworkException());
    when(
      () => cache.read(QuotesRepositoryImpl.cacheKey),
    ).thenReturn(CacheEntry(data: [quotes.first.toJson()], savedAt: savedAt));

    final result = await repository.getQuotes();

    final cached = (result as Ok<CachedData<List<Quote>>>).value;
    expect(cached.data, quotes);
    expect(cached.savedAt, savedAt);
    expect(cached.isFromCache, isTrue);
  });

  test('returns the original failure when there is nothing cached', () async {
    stubApi(() async => throw const NetworkException());
    when(() => cache.read(any())).thenReturn(null);

    final result = await repository.getQuotes();

    expect((result as Err).failure, isA<NetworkFailure>());
  });

  test('still returns fresh data if caching fails', () async {
    stubApi(() async => quotes);
    when(() => cache.write(any(), any())).thenThrow(const CacheException());

    final result = await repository.getQuotes();

    expect((result as Ok<CachedData<List<Quote>>>).value.data, quotes);
  });
}
