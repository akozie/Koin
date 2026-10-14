import 'package:equatable/equatable.dart';

enum ProductCategory { target, fixedDeposit, education, vacation }

/// Used by the product filter chips.
enum ProductTenor {
  all('All'),
  fixed('Fixed tenor'),
  flexible('Flexible');

  const ProductTenor(this.label);

  final String label;
}

class SavingsProduct extends Equatable {
  const SavingsProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.interestRate,
    required this.description,
    required this.minimumDeposit,
    this.durationMonths,
    this.features = const [],
  });

  factory SavingsProduct.fromJson(Map<String, dynamic> json) => SavingsProduct(
    id: json['id'] as String,
    name: json['name'] as String,
    category: ProductCategory.values.byName(json['category'] as String),
    interestRate: (json['interestRate'] as num).toDouble(),
    description: json['description'] as String,
    minimumDeposit: json['minimumDeposit'] as int,
    durationMonths: json['durationMonths'] as int?,
    features: (json['features'] as List<dynamic>? ?? const []).cast<String>(),
  );

  final String id;
  final String name;
  final ProductCategory category;

  /// Annual interest rate in percent, e.g. `12` for 12% p.a.
  final double interestRate;
  final String description;

  /// Minimum deposit in whole Naira.
  final int minimumDeposit;

  /// Fixed tenor in months, or `null` for flexible products.
  final int? durationMonths;
  final List<String> features;

  bool get isFlexible => durationMonths == null;

  String get durationLabel => isFlexible ? 'Flexible' : '$durationMonths Months';

  String get interestLabel => '${interestRate % 1 == 0 ? interestRate.toInt() : interestRate}%';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
    'interestRate': interestRate,
    'description': description,
    'minimumDeposit': minimumDeposit,
    'durationMonths': durationMonths,
    'features': features,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    interestRate,
    description,
    minimumDeposit,
    durationMonths,
    features,
  ];
}
