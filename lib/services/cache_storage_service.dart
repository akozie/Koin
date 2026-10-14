import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../core/errors/exceptions.dart';

/// A cached JSON payload and when it was saved.
class CacheEntry {
  const CacheEntry({required this.data, required this.savedAt});

  final Object? data;
  final DateTime savedAt;
}

/// Key-value cache for API responses (Hive). Lets the app show the last
/// successful response when the network is unavailable.
abstract interface class CacheStorageService {
  CacheEntry? read(String key);

  Future<void> write(String key, Object? data);
}

class CacheStorageServiceImpl implements CacheStorageService {
  CacheStorageServiceImpl(this._box, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final Box<String> _box;
  final DateTime Function() _clock;

  @override
  CacheEntry? read(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CacheEntry(data: json['data'], savedAt: DateTime.parse(json['savedAt'] as String));
    } on Object {
      // A corrupt entry is treated as a cache miss.
      return null;
    }
  }

  @override
  Future<void> write(String key, Object? data) async {
    try {
      await _box.put(key, jsonEncode({'savedAt': _clock().toIso8601String(), 'data': data}));
    } on Object {
      throw const CacheException('Response could not be cached');
    }
  }
}
