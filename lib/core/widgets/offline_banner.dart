import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';

/// Compact offline indicator shown at the top of the screen.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Container(
      width: double.infinity,
      color: Colors.black87,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        bottom: 4,
        left: 12,
        right: 12,
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 13, color: Colors.white70),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${t.common.offline} · ${t.common.offlineSubtitle}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                decoration: TextDecoration.none,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
