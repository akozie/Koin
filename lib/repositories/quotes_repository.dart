import 'dart:developer' as developer;
import 'dart:math';

import '../core/errors/result.dart';
import '../models/cached_data.dart';
import '../models/quote.dart';
import '../services/api_service.dart';
import '../services/cache_storage_service.dart';

abstract interface class QuotesRepository {
  /// Fetches fresh quotes, falling back to the last cached copy when the
  /// request fails (e.g. offline). Fails only when there is nothing cached.
  Future<Result<CachedData<List<Quote>>>> getQuotes();
}

class QuotesRepositoryImpl implements QuotesRepository {
  QuotesRepositoryImpl(this._api, this._cache, {Random? random}) : _random = random ?? Random();

  final ApiService _api;
  final CacheStorageService _cache;
  final Random _random;

  static const cacheKey = 'quotes';

  /// The public dataset is uncurated and includes quotes that are off-brand
  /// (or offensive) for a bank. We fetch one known page and only show quotes
  /// from this reviewed allowlist.
  static const curatedIds = {1, 3, 5, 11, 13, 19, 21, 22, 27};
  static const _pageSize = 30;

  @override
  Future<Result<CachedData<List<Quote>>>> getQuotes() async {
    final result = await guard(() async {
      final page = await _api.fetchQuotes(limit: _pageSize);
      // Shuffle so each refresh feels fresh.
      return page.where((q) => curatedIds.contains(q.id)).toList()..shuffle(_random);
    });

    switch (result) {
      case Ok(value: final quotes):
        await _saveToCache(quotes);
        return Ok(CachedData(quotes));
      case Err(:final failure):
        final cached = _readFromCache();
        return cached == null ? Err(failure) : Ok(cached);
    }
  }

  Future<void> _saveToCache(List<Quote> quotes) async {
    try {
      await _cache.write(cacheKey, quotes.map((q) => q.toJson()).toList());
    } on Object catch (e) {
      // Caching is best effort: fresh data is still returned to the user.
      developer.log('Could not cache quotes', error: e, name: 'QuotesRepository');
    }
  }

  CachedData<List<Quote>>? _readFromCache() {
    final entry = _cache.read(cacheKey);
    final data = entry?.data;
    if (entry == null || data is! List) return null;
    try {
      final quotes = data.cast<Map<String, dynamic>>().map(Quote.fromJson).toList();
      return CachedData(quotes, savedAt: entry.savedAt);
    } on Object {
      return null;
    }
  }
}
