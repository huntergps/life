import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/providers/connectivity_provider.dart';
import 'package:galapagos_wildlife/core/widgets/offline_banner.dart';

/// Wraps its [child] in a [Column] that conditionally shows an
/// [OfflineBanner] at the top when the device is offline.
///
/// The banner animates in/out using [AnimatedSwitcher] + [SizeTransition].
class OfflineBannerWrapper extends ConsumerWidget {
  final Widget child;

  const OfflineBannerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider).asData?.value ?? true;

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
          child: isOnline
              ? const SizedBox.shrink(key: ValueKey('online'))
              : const OfflineBanner(key: ValueKey('offline')),
        ),
        Expanded(child: child),
      ],
    );
  }
}
