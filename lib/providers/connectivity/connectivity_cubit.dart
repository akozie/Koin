import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/network_info.dart';

enum ConnectivityStatus {
  unknown,
  online,
  offline;

  bool get isOffline => this == ConnectivityStatus.offline;
}

/// App-wide connectivity, driving the offline banner, auto-refresh on
/// reconnect and disabling actions that need a connection.
class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  ConnectivityCubit(this._networkInfo) : super(ConnectivityStatus.unknown) {
    _subscription = _networkInfo.onConnectivityChanged.listen(_update);
    unawaited(_networkInfo.isConnected.then(_update));
  }

  final NetworkInfo _networkInfo;
  late final StreamSubscription<bool> _subscription;

  void _update(bool connected) {
    if (isClosed) return;
    emit(connected ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
