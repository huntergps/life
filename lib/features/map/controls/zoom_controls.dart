import 'package:flutter/material.dart';

/// Circular zoom button with disabled state at zoom limits.
class ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const ZoomButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade200,
        shape: BoxShape.circle,
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 20),
        color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
        onPressed: onPressed,
      ),
    );
  }
}
