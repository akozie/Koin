import 'dart:async';

import '../core/errors/failures.dart';
import '../core/errors/result.dart';
import '../core/network/network_info.dart';
import '../models/savings_plan.dart';
import '../services/savings_service.dart';
import '../services/savings_storage_service.dart';
import '../utils/formatters.dart';

abstract interface class SavingsRepository {
  /// Emits the full, updated list of plans whenever a plan is created.
  Stream<List<SavingsPlan>> get planChanges;

  /// All of the user's plans, newest first.
  Future<Result<List<SavingsPlan>>> getPlans();

  Future<Result<SavingsPlan>> createPlan(CreateSavingsRequest request);
}

class SavingsRepositoryImpl implements SavingsRepository {
  SavingsRepositoryImpl({
    required this._service,
    required this._storage,
    required this._networkInfo,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SavingsService _service;
  final SavingsStorageService _storage;
  final NetworkInfo _networkInfo;
  final DateTime Function() _clock;

  static const offlineCreateMessage =
      "You're offline. Connect to the internet to create a savings plan.";

  final _controller = StreamController<List<SavingsPlan>>.broadcast();

  @override
  Stream<List<SavingsPlan>> get planChanges => _controller.stream;

  @override
  Future<Result<List<SavingsPlan>>> getPlans() => guard(_loadPlans);

  @override
  Future<Result<SavingsPlan>> createPlan(CreateSavingsRequest request) async {
    // Financial actions are never queued for later: they require a live
    // connection so the user gets an immediate, definitive outcome.
    if (!await _networkInfo.checkNow()) {
      return const Err(NetworkFailure(offlineCreateMessage));
    }

    final productResult = await guard(() => _service.fetchProduct(request.productId));
    switch (productResult) {
      case Err(:final failure):
        return Err(failure);
      case Ok(value: final product):
        if (request.monthlyContribution < product.minimumDeposit) {
          return Err(
            ValidationFailure(
              'The minimum contribution for ${product.name} is '
              '${CurrencyFormatter.format(product.minimumDeposit)}.',
            ),
          );
        }
        if (request.monthlyContribution > request.targetAmount) {
          return const Err(
            ValidationFailure('Monthly contribution cannot exceed the target amount.'),
          );
        }

        final now = _clock();
        final plan = SavingsPlan(
          id: 'plan_${now.microsecondsSinceEpoch}',
          name: request.name.trim(),
          productId: product.id,
          productName: product.name,
          interestRate: product.interestRate,
          targetAmount: request.targetAmount,
          contribution: request.monthlyContribution,
          currentBalance: 0,
          durationMonths: request.durationMonths,
          frequency: SavingsFrequency.monthly,
          createdAt: now,
        );

        return guard(() async {
          await _storage.savePlan(plan);
          _notifyPlanAdded(plan);
          return plan;
        });
    }
  }

  /// Last list handed out, so a new plan can be shown without a round trip.
  List<SavingsPlan>? _plans;

  void _notifyPlanAdded(SavingsPlan plan) {
    final current = _plans;
    if (current != null) {
      _controller.add(_plans = [plan, ...current]);
      return;
    }
    // Nothing loaded yet: best-effort full reload (the plan is already saved).
    unawaited(_loadPlans().then(_controller.add, onError: (_) {}));
  }

  Future<List<SavingsPlan>> _loadPlans() async {
    final (remote, local) = await (_service.fetchPortfolio(), _storage.readPlans()).wait;
    return _plans = [...local, ...remote]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
