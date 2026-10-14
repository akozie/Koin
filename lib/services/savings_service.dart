import '../core/constants/app_constants.dart';
import '../core/errors/exceptions.dart';
import '../models/savings_plan.dart';
import '../models/savings_product.dart';

/// Savings backend data source (products catalogue + the user's portfolio).
abstract interface class SavingsService {
  Future<List<SavingsProduct>> fetchProducts();

  Future<SavingsProduct> fetchProduct(String id);

  /// Plans that already exist on the "server" for the signed-in user.
  Future<List<SavingsPlan>> fetchPortfolio();
}

/// In-memory mock backend with simulated latency.
///
/// Swapping this for a real REST implementation requires no change outside
/// the service layer.
class MockSavingsService implements SavingsService {
  MockSavingsService({this.latency = AppConstants.mockLatency});

  final Duration latency;

  static const products = <SavingsProduct>[
    SavingsProduct(
      id: 'target-savings',
      name: 'Target Savings',
      category: ProductCategory.target,
      interestRate: 12,
      minimumDeposit: 5000,
      durationMonths: 12,
      description: 'Save towards a specific goal with automated monthly contributions.',
      features: [
        'Automated monthly debit',
        'Interest paid at maturity',
        'Track progress towards your goal',
      ],
    ),
    SavingsProduct(
      id: 'fixed-deposit',
      name: 'Fixed Deposit',
      category: ProductCategory.fixedDeposit,
      interestRate: 18,
      minimumDeposit: 50000,
      durationMonths: 6,
      description: 'Lock funds away for a fixed tenor and earn our highest returns.',
      features: [
        'Highest guaranteed returns',
        'Interest paid upfront or at maturity',
        'Funds locked until maturity',
      ],
    ),
    SavingsProduct(
      id: 'education-savings',
      name: 'Education Savings',
      category: ProductCategory.education,
      interestRate: 10,
      minimumDeposit: 2000,
      description: "Plan ahead for school fees and your children's education.",
      features: [
        'Flexible contributions',
        'Withdraw at the start of each term',
        'No hidden charges',
      ],
    ),
    SavingsProduct(
      id: 'vacation-savings',
      name: 'Vacation Savings',
      category: ProductCategory.vacation,
      interestRate: 8,
      minimumDeposit: 1000,
      description: 'Put money aside for your next trip, stress free.',
      features: [
        'Start with as little as ₦1,000',
        'Pause contributions anytime',
        'Withdraw when you are ready to travel',
      ],
    ),
  ];

  static final _seedPortfolio = <SavingsPlan>[
    SavingsPlan(
      id: 'plan_emergency',
      name: 'Emergency Fund',
      productId: 'target-savings',
      productName: 'Target Savings',
      interestRate: 12,
      targetAmount: 500000,
      contribution: 20000,
      currentBalance: 120000,
      durationMonths: 12,
      frequency: SavingsFrequency.monthly,
      createdAt: DateTime(2026, 3, 1),
    ),
    SavingsPlan(
      id: 'plan_rent',
      name: 'House Rent',
      productId: 'fixed-deposit',
      productName: 'Fixed Deposit',
      interestRate: 18,
      targetAmount: 1200000,
      contribution: 25000,
      currentBalance: 450000,
      durationMonths: 6,
      frequency: SavingsFrequency.weekly,
      createdAt: DateTime(2026, 2, 12),
    ),
    SavingsPlan(
      id: 'plan_vacation',
      name: 'Dubai Trip',
      productId: 'vacation-savings',
      productName: 'Vacation Savings',
      interestRate: 8,
      targetAmount: 600000,
      contribution: 40000,
      currentBalance: 280000,
      durationMonths: 12,
      frequency: SavingsFrequency.monthly,
      createdAt: DateTime(2026, 1, 20),
    ),
  ];

  @override
  Future<List<SavingsProduct>> fetchProducts() async {
    await Future<void>.delayed(latency);
    return products;
  }

  @override
  Future<SavingsProduct> fetchProduct(String id) async {
    await Future<void>.delayed(latency ~/ 2);
    for (final product in products) {
      if (product.id == id) return product;
    }
    throw const NotFoundException('Savings product not found');
  }

  @override
  Future<List<SavingsPlan>> fetchPortfolio() async {
    await Future<void>.delayed(latency);
    return _seedPortfolio;
  }
}
