import 'package:equatable/equatable.dart';

/// Data returned by a repository, tagged with where it came from.
///
/// [savedAt] is `null` for fresh network data and set when the repository
/// fell back to the copy cached on the device (e.g. while offline), so the UI
/// can say "Showing data from 10:42".
class CachedData<T> extends Equatable {
  const CachedData(this.data, {this.savedAt});

  final T data;
  final DateTime? savedAt;

  bool get isFromCache => savedAt != null;

  @override
  List<Object?> get props => [data, savedAt];
}
