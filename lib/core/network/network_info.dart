import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Answers "can the app actually reach the internet right now?".
///
/// A Wi-Fi or mobile connection being up is not enough: captive portals,
/// routers without internet, DNS outages and expired data plans all look
/// "connected". So the status combines the network interface with a real
/// reachability probe and with the outcome of the app's own requests.
abstract interface class NetworkInfo {
  /// The last known status (probed on first use). Cheap: use it to fail fast.
  Future<bool> get isConnected;

  /// Re-checks right now. Use before actions that must not run offline.
  Future<bool> checkNow();

  /// Emits whenever the status changes.
  Stream<bool> get onConnectivityChanged;

  /// A request reached the server: the internet works.
  void reportReachable();

  /// A request could not reach the server (DNS failure, connection refused,
  /// timeout): treat the device as offline until a re-check succeeds.
  void reportUnreachable();
}

/// Returns `true` if a lightweight request reaches the backend.
typedef ReachabilityProbe = Future<bool> Function();

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(
    this._connectivity,
    this._probe, {
    this.recheckInterval = const Duration(seconds: 10),
  }) {
    _subscription = _connectivity.onConnectivityChanged.listen((_) => checkNow());
  }

  final Connectivity _connectivity;
  final ReachabilityProbe _probe;

  /// How often to re-check while offline, so the app recovers on its own
  /// even when the network interface never changes (e.g. DNS comes back).
  final Duration recheckInterval;

  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  final _controller = StreamController<bool>.broadcast();
  bool? _online;
  Future<bool>? _inFlight;
  Timer? _recheckTimer;

  @override
  Future<bool> get isConnected async => _online ?? await checkNow();

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> checkNow() => _inFlight ??= _check().whenComplete(() => _inFlight = null);

  @override
  void reportReachable() => _setOnline(true);

  @override
  void reportUnreachable() => _setOnline(false);

  Future<bool> _check() async {
    final interfaces = await _connectivity.checkConnectivity();
    final hasInterface = interfaces.any((r) => r != ConnectivityResult.none);
    final online = hasInterface && await _probe();
    _setOnline(online);
    return online;
  }

  void _setOnline(bool online) {
    if (online) {
      _recheckTimer?.cancel();
      _recheckTimer = null;
    } else {
      _recheckTimer ??= Timer.periodic(recheckInterval, (_) => checkNow());
    }
    if (_online == online) return;
    _online = online;
    _controller.add(online);
  }

  Future<void> dispose() async {
    _recheckTimer?.cancel();
    await _subscription.cancel();
    await _controller.close();
  }
}
