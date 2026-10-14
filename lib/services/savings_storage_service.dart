import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../core/errors/exceptions.dart';
import '../models/savings_plan.dart';

/// Persists savings plans created on this device (Hive).
abstract interface class SavingsStorageService {
  Future<List<SavingsPlan>> readPlans();

  Future<void> savePlan(SavingsPlan plan);
}

class SavingsStorageServiceImpl implements SavingsStorageService {
  SavingsStorageServiceImpl(this._box);

  /// Plans are stored as JSON strings keyed by id. This keeps the storage
  /// format explicit and avoids generated Hive adapters.
  final Box<String> _box;

  @override
  Future<List<SavingsPlan>> readPlans() async {
    try {
      return _box.values
          .map((raw) => SavingsPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>))
          .toList();
    } on Object {
      throw const CacheException('Saved plans could not be read');
    }
  }

  @override
  Future<void> savePlan(SavingsPlan plan) async {
    try {
      await _box.put(plan.id, jsonEncode(plan.toJson()));
    } on Object {
      throw const CacheException('Savings plan could not be saved');
    }
  }
}
