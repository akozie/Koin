/// Simple-interest projections shown to the user before creating a plan.
abstract final class SavingsCalculator {
  /// Estimated interest earned by contributing [monthlyContribution] at the
  /// start of every month for [months] months at [annualRatePercent] p.a.
  ///
  /// Each deposit earns interest for the months it remains saved, so the
  /// total is `c · r/12 · (n + (n-1) + … + 1)` = `c · r/12 · n(n+1)/2`.
  static int projectedInterest({
    required int monthlyContribution,
    required double annualRatePercent,
    required int months,
  }) {
    if (monthlyContribution <= 0 || months <= 0 || annualRatePercent <= 0) return 0;
    final monthlyRate = annualRatePercent / 100 / 12;
    final depositMonths = months * (months + 1) / 2;
    return (monthlyContribution * monthlyRate * depositMonths).round();
  }

  static int totalContributions({required int monthlyContribution, required int months}) =>
      monthlyContribution * months;
}
