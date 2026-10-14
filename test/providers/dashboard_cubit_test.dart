import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koins/core/errors/failures.dart';
import 'package:koins/core/errors/result.dart';
import 'package:koins/models/savings_plan.dart';
import 'package:koins/providers/dashboard/dashboard_cubit.dart';
import 'package:koins/providers/view_status.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';

void main() {
  late MockSavingsRepository repository;
  late StreamController<List<SavingsPlan>> changes;

  final plans = [
    tPlan(id: 'a', balance: 120000),
    tPlan(id: 'b', balance: 450000),
    tPlan(id: 'c', balance: 280000),
    tPlan(id: 'd', balance: 0),
  ];

  setUp(() {
    repository = MockSavingsRepository();
    changes = StreamController<List<SavingsPlan>>.broadcast();
    when(() => repository.planChanges).thenAnswer((_) => changes.stream);
  });

  tearDown(() => changes.close());

  test('totals balances and limits recent plans to three', () {
    final state = DashboardState(plans: plans);
    expect(state.totalSavings, 850000);
    expect(state.recentPlans.map((p) => p.id), ['a', 'b', 'c']);
  });

  blocTest<DashboardCubit, DashboardState>(
    'loads plans',
    setUp: () => when(() => repository.getPlans()).thenAnswer((_) async => Ok(plans)),
    build: () => DashboardCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      const DashboardState(status: ViewStatus.loading),
      DashboardState(status: ViewStatus.success, plans: plans),
    ],
  );

  blocTest<DashboardCubit, DashboardState>(
    'emits failure when plans cannot be loaded',
    setUp: () =>
        when(() => repository.getPlans()).thenAnswer((_) async => const Err(CacheFailure())),
    build: () => DashboardCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      const DashboardState(status: ViewStatus.loading),
      DashboardState(status: ViewStatus.failure, errorMessage: const CacheFailure().message),
    ],
  );

  blocTest<DashboardCubit, DashboardState>(
    'refreshes when a plan is created elsewhere',
    build: () => DashboardCubit(repository),
    act: (_) => changes.add(plans),
    expect: () => [DashboardState(status: ViewStatus.success, plans: plans)],
  );

  blocTest<DashboardCubit, DashboardState>(
    'toggles balance visibility',
    build: () => DashboardCubit(repository),
    act: (cubit) => cubit.toggleBalanceVisibility(),
    expect: () => const [DashboardState(isBalanceVisible: false)],
  );
}
