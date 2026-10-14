import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/result.dart';
import '../../models/quote.dart';
import '../../repositories/quotes_repository.dart';
import '../view_status.dart';

part 'quotes_state.dart';

/// Daily motivation feed, backed by the public DummyJSON API with an
/// on-device cache for offline use.
class QuotesCubit extends Cubit<QuotesState> {
  QuotesCubit(this._repository) : super(const QuotesState());

  final QuotesRepository _repository;

  /// Quotes already on screen stay visible while reloading, so refreshing
  /// never flashes back to a skeleton.
  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading, savedAt: state.savedAt));
    final result = await _repository.getQuotes();
    if (isClosed) return;
    emit(switch (result) {
      Ok(value: final cached) => QuotesState(
        status: ViewStatus.success,
        quotes: cached.data,
        savedAt: cached.savedAt,
      ),
      Err(:final failure) => state.copyWith(
        status: ViewStatus.failure,
        errorMessage: failure.message,
      ),
    });
  }
}
