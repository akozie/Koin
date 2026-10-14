import 'package:koins/models/savings_plan.dart';
import 'package:koins/models/savings_product.dart';
import 'package:koins/models/user.dart';

const tUser = User(
  id: 'usr_001',
  fullName: 'John Doe',
  email: 'test@bank.com',
  phone: '+234 803 123 4567',
);

const tTargetProduct = SavingsProduct(
  id: 'target-savings',
  name: 'Target Savings',
  category: ProductCategory.target,
  interestRate: 12,
  minimumDeposit: 5000,
  durationMonths: 12,
  description: 'Save towards a specific goal.',
);

const tFlexibleProduct = SavingsProduct(
  id: 'vacation-savings',
  name: 'Vacation Savings',
  category: ProductCategory.vacation,
  interestRate: 8,
  minimumDeposit: 1000,
  description: 'Put money aside for your next trip.',
);

SavingsPlan tPlan({String id = 'plan_1', int balance = 120000, DateTime? createdAt}) => SavingsPlan(
  id: id,
  name: 'Emergency Fund',
  productId: 'target-savings',
  productName: 'Target Savings',
  interestRate: 12,
  targetAmount: 500000,
  contribution: 20000,
  currentBalance: balance,
  durationMonths: 12,
  frequency: SavingsFrequency.monthly,
  createdAt: createdAt ?? DateTime(2026, 1, 1),
);
