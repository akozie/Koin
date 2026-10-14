import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koins/core/errors/failures.dart';
import 'package:koins/core/errors/result.dart';
import 'package:koins/models/cached_data.dart';
import 'package:koins/models/quote.dart';
import 'package:koins/providers/quotes/quotes_cubit.dart';
import 'package:koins/providers/view_status.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';

void main() {
  late MockQuotesRepository repository;
  const quotes = [Quote(id: 1, text: 'Save first.', author: 'Anon')];
  final savedAt = DateTime(2026, 10, 13, 10, 42);

  setUp(() => repository = MockQuotesRepository());

  blocTest<QuotesCubit, QuotesState>(
    'exposes when cached data was saved',
    setUp: () => when(
      () => repository.getQuotes(),
    ).thenAnswer((_) async => Ok(CachedData(quotes, savedAt: savedAt))),
    build: () => QuotesCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      const QuotesState(status: ViewStatus.loading),
      QuotesState(status: ViewStatus.success, quotes: quotes, savedAt: savedAt),
    ],
  );

  blocTest<QuotesCubit, QuotesState>(
    'keeps showing existing quotes while reloading and after a failed reload',
    setUp: () =>
        when(() => repository.getQuotes()).thenAnswer((_) async => const Err(NetworkFailure())),
    build: () => QuotesCubit(repository),
    seed: () => const QuotesState(status: ViewStatus.success, quotes: quotes),
    act: (cubit) => cubit.load(),
    expect: () => [
      const QuotesState(status: ViewStatus.loading, quotes: quotes),
      QuotesState(
        status: ViewStatus.failure,
        quotes: quotes,
        errorMessage: const NetworkFailure().message,
      ),
    ],
  );
}
