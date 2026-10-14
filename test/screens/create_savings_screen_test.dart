import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koins/core/di/injection.dart';
import 'package:koins/core/errors/result.dart';
import 'package:koins/models/savings_plan.dart';
import 'package:koins/repositories/product_repository.dart';
import 'package:koins/repositories/savings_repository.dart';
import 'package:koins/screens/create_savings/create_savings_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockProductRepository products;
  late MockSavingsRepository savings;

  setUpAll(() {
    registerFallbackValue(
      const CreateSavingsRequest(
        name: '',
        productId: '',
        targetAmount: 0,
        monthlyContribution: 0,
        durationMonths: 0,
      ),
    );
  });

  setUp(() {
    products = MockProductRepository();
    savings = MockSavingsRepository();
    when(
      () => products.getProducts(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => const Ok([tTargetProduct, tFlexibleProduct]));
    getIt
      ..registerSingleton<ProductRepository>(products)
      ..registerSingleton<SavingsRepository>(savings);
  });

  tearDown(getIt.reset);

  Finder field(String key) =>
      find.descendant(of: find.byKey(Key(key)), matching: find.byType(TextFormField));

  Future<void> tapCreate(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('create_button')));
    await tester.tap(find.byKey(const Key('create_button')));
    await tester.pump();
  }

  testWidgets('requires every field', (tester) async {
    await tester.pumpScreen(const CreateSavingsScreen());
    await tester.pumpAndSettle();

    await tapCreate(tester);

    expect(find.text('Savings name is required'), findsOneWidget);
    expect(find.text('Product type is required'), findsOneWidget);
    expect(find.text('Target amount is required'), findsOneWidget);
    expect(find.text('Monthly contribution is required'), findsOneWidget);
    expect(find.text('Duration is required'), findsOneWidget);
    verifyNever(() => savings.createPlan(any()));
  });

  testWidgets('pre-selects the product and locks a fixed duration', (tester) async {
    await tester.pumpScreen(const CreateSavingsScreen(initialProductId: 'target-savings'));
    await tester.pumpAndSettle();

    expect(find.text('Target Savings · 12%'), findsOneWidget);
    expect(find.text('12 Months'), findsOneWidget);
    expect(find.textContaining('Fixed at 12 months'), findsOneWidget);
  });

  testWidgets('creates the plan, shows success and returns to the dashboard', (tester) async {
    when(() => savings.createPlan(any())).thenAnswer((_) async => Ok(tPlan()));
    await tester.pumpScreen(const CreateSavingsScreen(initialProductId: 'target-savings'));
    await tester.pumpAndSettle();

    await tester.enterText(field('savings_name'), 'New Car');
    await tester.enterText(field('target_amount'), '1000000');
    await tester.enterText(field('monthly_contribution'), '50000');
    await tester.pump();

    expect(find.text('1,000,000'), findsOneWidget, reason: 'amounts are grouped while typing');
    expect(find.text('Estimated returns'), findsOneWidget);

    await tapCreate(tester);
    await tester.pumpAndSettle();

    verify(
      () => savings.createPlan(
        const CreateSavingsRequest(
          name: 'New Car',
          productId: 'target-savings',
          targetAmount: 1000000,
          monthlyContribution: 50000,
          durationMonths: 12,
        ),
      ),
    ).called(1);
    expect(find.text('Savings Created Successfully'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('disables Create and explains why while offline', (tester) async {
    await tester.pumpScreen(
      const CreateSavingsScreen(initialProductId: 'target-savings'),
      networkInfo: FakeNetworkInfo(connected: false),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('create_offline_notice')), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const Key('create_button')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('rejects a contribution above the target', (tester) async {
    await tester.pumpScreen(const CreateSavingsScreen(initialProductId: 'target-savings'));
    await tester.pumpAndSettle();

    await tester.enterText(field('savings_name'), 'Car');
    await tester.enterText(field('target_amount'), '10000');
    await tester.enterText(field('monthly_contribution'), '20000');
    await tapCreate(tester);

    expect(find.text('Cannot exceed ₦10,000'), findsOneWidget);
    verifyNever(() => savings.createPlan(any()));
  });
}
