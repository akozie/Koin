import 'package:flutter_test/flutter_test.dart';
import 'package:koins/providers/connectivity/connectivity_cubit.dart';

import '../helpers/mocks.dart';

void main() {
  test('reports the initial status', () async {
    final cubit = ConnectivityCubit(FakeNetworkInfo(connected: false));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, ConnectivityStatus.offline);
    await cubit.close();
  });

  test('follows connectivity changes', () async {
    final network = FakeNetworkInfo();
    final cubit = ConnectivityCubit(network);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, ConnectivityStatus.online);

    final states = expectLater(
      cubit.stream,
      emitsInOrder([ConnectivityStatus.offline, ConnectivityStatus.online]),
    );
    network.connected = false;
    network.connected = true;
    await states;
    await cubit.close();
  });
}
