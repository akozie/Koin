import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koins/core/network/network_info.dart';
import 'package:koins/core/network/reachability.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity connectivity;
  late StreamController<List<ConnectivityResult>> interfaceChanges;
  late bool probeResult;
  late int probeCalls;
  late NetworkInfoImpl networkInfo;

  void stubInterface(ConnectivityResult result) =>
      when(() => connectivity.checkConnectivity()).thenAnswer((_) async => [result]);

  setUp(() {
    connectivity = MockConnectivity();
    interfaceChanges = StreamController.broadcast();
    when(() => connectivity.onConnectivityChanged).thenAnswer((_) => interfaceChanges.stream);
    stubInterface(ConnectivityResult.wifi);
    probeResult = true;
    probeCalls = 0;
    networkInfo = NetworkInfoImpl(connectivity, () async {
      probeCalls++;
      return probeResult;
    }, recheckInterval: const Duration(milliseconds: 20));
  });

  tearDown(() async {
    await networkInfo.dispose();
    await interfaceChanges.close();
  });

  test('is online when the interface is up and the internet is reachable', () async {
    expect(await networkInfo.checkNow(), isTrue);
  });

  test('is offline when connected to Wi-Fi without internet (e.g. captive portal)', () async {
    probeResult = false;
    expect(await networkInfo.checkNow(), isFalse);
  });

  test('is offline without probing when there is no network interface', () async {
    stubInterface(ConnectivityResult.none);
    expect(await networkInfo.checkNow(), isFalse);
    expect(probeCalls, 0);
  });

  test('goes offline as soon as a request reports the server unreachable', () async {
    await networkInfo.checkNow();
    final emitted = expectLater(networkInfo.onConnectivityChanged, emits(false));

    networkInfo.reportUnreachable();

    await emitted;
    expect(await networkInfo.isConnected, isFalse);
  });

  test('re-checks while offline and recovers on its own', () async {
    probeResult = false;
    await networkInfo.checkNow();
    final recovered = expectLater(networkInfo.onConnectivityChanged, emits(true));

    probeResult = true;

    await recovered.timeout(const Duration(seconds: 2));
  });

  test('re-checks when the network interface changes', () async {
    await networkInfo.checkNow();
    final emitted = expectLater(networkInfo.onConnectivityChanged, emits(false));

    stubInterface(ConnectivityResult.none);
    interfaceChanges.add([ConnectivityResult.none]);

    await emitted;
  });

  test('a successful request marks the device online again', () async {
    probeResult = false;
    await networkInfo.checkNow();

    networkInfo.reportReachable();

    expect(await networkInfo.isConnected, isTrue);
  });

  group('isUnreachableError', () {
    DioException error(DioExceptionType type, {Object? cause, int? status}) => DioException(
      requestOptions: RequestOptions(),
      type: type,
      error: cause,
      response: status == null
          ? null
          : Response<void>(requestOptions: RequestOptions(), statusCode: status),
    );

    test('treats connection failures and timeouts as unreachable', () {
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
      ]) {
        expect(isUnreachableError(error(type)), isTrue, reason: '$type');
      }
      expect(
        isUnreachableError(
          error(DioExceptionType.unknown, cause: const SocketException('lookup failed')),
        ),
        isTrue,
      );
    });

    test('does not treat a server error response as offline', () {
      expect(isUnreachableError(error(DioExceptionType.badResponse, status: 500)), isFalse);
      expect(isUnreachableError(error(DioExceptionType.cancel)), isFalse);
    });
  });
}
