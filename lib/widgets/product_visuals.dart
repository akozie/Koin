import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/savings_product.dart';

/// Icon + accent colour for each product category.
extension ProductCategoryVisuals on ProductCategory {
  IconData get icon => switch (this) {
    ProductCategory.target => Icons.flag_rounded,
    ProductCategory.fixedDeposit => Icons.lock_rounded,
    ProductCategory.education => Icons.school_rounded,
    ProductCategory.vacation => Icons.flight_takeoff_rounded,
  };

  Color get color => switch (this) {
    ProductCategory.target => AppColors.limeDark,
    ProductCategory.fixedDeposit => AppColors.tealLight,
    ProductCategory.education => const Color(0xFF3D7BD9),
    ProductCategory.vacation => const Color(0xFFE8913D),
  };
}

/// Rounded, tinted icon tile used on cards and the details header.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, this.size = 48});

  final ProductCategory category;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: category.color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(size * 0.3),
    ),
    child: Icon(category.icon, color: category.color, size: size * 0.5),
  );
}

/// Resolves the category of a plan from its product id, for icon display.
ProductCategory categoryForProductId(String productId) => switch (productId) {
  'fixed-deposit' => ProductCategory.fixedDeposit,
  'education-savings' => ProductCategory.education,
  'vacation-savings' => ProductCategory.vacation,
  _ => ProductCategory.target,
};
