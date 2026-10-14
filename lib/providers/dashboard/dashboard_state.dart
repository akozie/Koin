part of 'dashboard_cubit.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.status = ViewStatus.initial,
    this.plans = const [],
    this.errorMessage,
    this.isBalanceVisible = true,
  });

  static const recentLimit = 3;

  final ViewStatus status;
  final List<SavingsPlan> plans;
  final String? errorMessage;
  final bool isBalanceVisible;

  int get totalSavings => plans.fold(0, (sum, plan) => sum + plan.currentBalance);

  List<SavingsPlan> get recentPlans => plans.take(recentLimit).toList();

  DashboardState copyWith({
    ViewStatus? status,
    List<SavingsPlan>? plans,
    String? errorMessage,
    bool? isBalanceVisible,
  }) => DashboardState(
    status: status ?? this.status,
    plans: plans ?? this.plans,
    errorMessage: errorMessage,
    isBalanceVisible: isBalanceVisible ?? this.isBalanceVisible,
  );

  @override
  List<Object?> get props => [status, plans, errorMessage, isBalanceVisible];
}
