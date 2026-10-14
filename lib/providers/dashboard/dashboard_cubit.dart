import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/result.dart';
import '../../models/savings_plan.dart';
import '../../repositories/savings_repository.dart';
import '../view_status.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardState()) {
    _subscription = _repository.planChanges.listen(
      (plans) => emit(state.copyWith(status: ViewStatus.success, plans: plans)),
    );
  }

  final SavingsRepository _repository;
  late final StreamSubscription<List<SavingsPlan>> _subscription;

  /// Loads plans. When data is already shown, it stays visible while
  /// refreshing (pull-to-refresh) instead of flashing a spinner.
  Future<void> load() async {
    if (state.plans.isEmpty) emit(state.copyWith(status: ViewStatus.loading));
    final result = await _repository.getPlans();
    if (isClosed) return;
    emit(switch (result) {
      Ok(value: final plans) => state.copyWith(status: ViewStatus.success, plans: plans),
      Err(:final failure) => state.copyWith(
        status: ViewStatus.failure,
        errorMessage: failure.message,
      ),
    });
  }

  void toggleBalanceVisibility() => emit(state.copyWith(isBalanceVisible: !state.isBalanceVisible));

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
