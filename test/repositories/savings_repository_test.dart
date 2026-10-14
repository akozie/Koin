import 'package:flutter_test/flutter_test.dart';
import 'package:koins/core/errors/exceptions.dart';
import 'package:koins/core/errors/failures.dart';
import 'package:koins/core/errors/result.dart';
import 'package:koins/models/savings_plan.dart';
import 'package:koins/repositories/savings_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';

void main() {
  late MockSavingsService service;
  late MockSavingsStorageService storage;
  late FakeNetworkInfo networkInfo;
  late SavingsRepositoryImpl repository;
  final now = DateTime(2026, 10, 13, 9);

  const request = CreateSavingsRequest(
    name: '  New Car  ',
    productId: 'target-savings',
    targetAmount: 1000000,
    monthlyContribution: 50000,
    durationMonths: 12,
  );

  setUpAll(() => registerFallbackValue(tPlan()));

  setUp(() {
    service = MockSavingsService();
    storage = MockSavingsStorageService();
    networkInfo = FakeNetworkInfo();
    repository = SavingsRepositoryImpl(
      service: service,
      storage: storage,
      networkInfo: networkInfo,
      clock: () => now,
    );
    when(() => service.fetchProduct(any())).thenAnswer((_) async => tTargetProduct);
    when(() => service.fetchPortfolio()).thenAnswer((_) async => []);
    when(() => storage.readPlans()).thenAnswer((_) async => []);
    when(() => storage.savePlan(any())).thenAnswer((_) async {});
  });

  group('getPlans', () {
    test('merges remote and local plans, newest first', () async {
      final older = tPlan(id: 'remote', createdAt: DateTime(2026, 1, 1));
      final newer = tPlan(id: 'local', createdAt: DateTime(2026, 5, 1));
      when(() => service.fetchPortfolio()).thenAnswer((_) async => [older]);
      when(() => storage.readPlans()).thenAnswer((_) async => [newer]);

      final result = await repository.getPlans();

      expect(result, isA<Ok<List<SavingsPlan>>>());
      expect((result as Ok<List<SavingsPlan>>).value.map((p) => p.id), ['local', 'remote']);
    });

    test('maps storage errors to CacheFailure', () async {
      when(() => storage.readPlans()).thenThrow(const CacheException());

      final result = await repository.getPlans();

      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('createPlan', () {
    test('builds the plan from the product and persists it', () async {
      final result = await repository.createPlan(request);

      final plan = (result as Ok<SavingsPlan>).value;
      expect(plan.name, 'New Car');
      expect(plan.productName, 'Target Savings');
      expect(plan.interestRate, 12);
      expect(plan.currentBalance, 0);
      expect(plan.createdAt, now);
      verify(() => storage.savePlan(plan)).called(1);
    });

    test('is blocked while offline, without saving anything', () async {
      networkInfo.connected = false;

      final result = await repository.createPlan(request);

      final failure = (result as Err).failure;
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, SavingsRepositoryImpl.offlineCreateMessage);
      verifyNever(() => storage.savePlan(any()));
    });

    test('rejects contributions below the product minimum', () async {
      const low = CreateSavingsRequest(
        name: 'Car',
        productId: 'target-savings',
        targetAmount: 100000,
        monthlyContribution: 4000,
        durationMonths: 12,
      );

      final result = await repository.createPlan(low);

      expect((result as Err).failure, isA<ValidationFailure>());
      verifyNever(() => storage.savePlan(any()));
    });

    test('rejects contributions larger than the target', () async {
      const invalid = CreateSavingsRequest(
        name: 'Car',
        productId: 'target-savings',
        targetAmount: 10000,
        monthlyContribution: 20000,
        durationMonths: 12,
      );

      final result = await repository.createPlan(invalid);

      expect((result as Err).failure, isA<ValidationFailure>());
    });

    test('returns NotFoundFailure for an unknown product', () async {
      when(() => service.fetchProduct(any())).thenThrow(const NotFoundException());

      final result = await repository.createPlan(request);

      expect((result as Err).failure, isA<NotFoundFailure>());
    });

    test('prepends the new plan to the loaded list without refetching', () async {
      when(() => service.fetchPortfolio()).thenAnswer((_) async => [tPlan(id: 'existing')]);
      await repository.getPlans();
      clearInteractions(service);

      final emitted = expectLater(
        repository.planChanges,
        emits(
          predicate<List<SavingsPlan>>((plans) => plans.length == 2 && plans.last.id == 'existing'),
        ),
      );
      await repository.createPlan(request);
      await emitted;
      verifyNever(() => service.fetchPortfolio());
    });

    test('notifies listeners with the refreshed list', () async {
      when(() => storage.readPlans()).thenAnswer((_) async => [tPlan(id: 'saved')]);

      final emitted = expectLater(
        repository.planChanges,
        emits(predicate<List<SavingsPlan>>((plans) => plans.single.id == 'saved')),
      );
      await repository.createPlan(request);
      await emitted;
    });
  });
}
