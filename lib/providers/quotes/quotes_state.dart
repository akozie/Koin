part of 'quotes_cubit.dart';

class QuotesState extends Equatable {
  const QuotesState({
    this.status = ViewStatus.initial,
    this.quotes = const [],
    this.savedAt,
    this.errorMessage,
  });

  final ViewStatus status;
  final List<Quote> quotes;

  /// Set when [quotes] came from the on-device cache instead of the network.
  final DateTime? savedAt;
  final String? errorMessage;

  bool get isEmpty => status.isSuccess && quotes.isEmpty;

  bool get isShowingCachedData => savedAt != null;

  QuotesState copyWith({
    ViewStatus? status,
    List<Quote>? quotes,
    DateTime? savedAt,
    String? errorMessage,
  }) => QuotesState(
    status: status ?? this.status,
    quotes: quotes ?? this.quotes,
    savedAt: savedAt,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, quotes, savedAt, errorMessage];
}
