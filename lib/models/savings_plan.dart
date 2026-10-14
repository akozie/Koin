import 'package:equatable/equatable.dart';

enum SavingsFrequency {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  const SavingsFrequency(this.label);

  final String label;
}

/// A savings plan owned by the user.
///
/// All amounts are whole Naira stored as [int]: money is never a `double`.
class SavingsPlan extends Equatable {
  const SavingsPlan({
    required this.id,
    required this.name,
    required this.productId,
    required this.productName,
    required this.interestRate,
    required this.targetAmount,
    required this.contribution,
    required this.currentBalance,
    required this.durationMonths,
    required this.frequency,
    required this.createdAt,
  });

  factory SavingsPlan.fromJson(Map<String, dynamic> json) => SavingsPlan(
    id: json['id'] as String,
    name: json['name'] as String,
    productId: json['productId'] as String,
    productName: json['productName'] as String,
    interestRate: (json['interestRate'] as num).toDouble(),
    targetAmount: json['targetAmount'] as int,
    contribution: json['contribution'] as int,
    currentBalance: json['currentBalance'] as int,
    durationMonths: json['durationMonths'] as int,
    frequency: SavingsFrequency.values.byName(json['frequency'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  final String id;
  final String name;
  final String productId;
  final String productName;
  final double interestRate;
  final int targetAmount;
  final int contribution;
  final int currentBalance;
  final int durationMonths;
  final SavingsFrequency frequency;
  final DateTime createdAt;

  /// Progress towards [targetAmount], clamped to 0..1.
  double get progress =>
      targetAmount <= 0 ? 0 : (currentBalance / targetAmount).clamp(0, 1).toDouble();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'productId': productId,
    'productName': productName,
    'interestRate': interestRate,
    'targetAmount': targetAmount,
    'contribution': contribution,
    'currentBalance': currentBalance,
    'durationMonths': durationMonths,
    'frequency': frequency.name,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    productId,
    productName,
    interestRate,
    targetAmount,
    contribution,
    currentBalance,
    durationMonths,
    frequency,
    createdAt,
  ];
}

/// Input for creating a new plan, as collected by the Create Savings form.
class CreateSavingsRequest extends Equatable {
  const CreateSavingsRequest({
    required this.name,
    required this.productId,
    required this.targetAmount,
    required this.monthlyContribution,
    required this.durationMonths,
  });

  final String name;
  final String productId;
  final int targetAmount;
  final int monthlyContribution;
  final int durationMonths;

  @override
  List<Object?> get props => [name, productId, targetAmount, monthlyContribution, durationMonths];
}
