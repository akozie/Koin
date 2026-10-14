import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../providers/connectivity/connectivity_cubit.dart';

/// Calls [onReconnect] when the device comes back online after being
/// offline, so screens refresh themselves without a manual retry.
class ReconnectListener extends StatelessWidget {
  const ReconnectListener({super.key, required this.onReconnect, required this.child});

  final VoidCallback onReconnect;
  final Widget child;

  @override
  Widget build(BuildContext context) => BlocListener<ConnectivityCubit, ConnectivityStatus>(
    listenWhen: (previous, current) => previous.isOffline && current == ConnectivityStatus.online,
    listener: (_, _) => onReconnect(),
    child: child,
  );
}
