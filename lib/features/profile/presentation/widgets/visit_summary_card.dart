import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

class VisitSummaryCard extends ConsumerWidget {
  final int speciesSeen;
  final int totalSightings;
  final String? displayName;
  final String locale;

  const VisitSummaryCard({
    super.key,
    required this.speciesSeen,
    required this.totalSightings,
    this.displayName,
    required this.locale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEs = locale == 'es';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.eco, color: AppColors.primary, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEs ? 'Mi Visita a Galapagos' : 'My Galapagos Visit',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (displayName != null)
              Text(
                displayName!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            const Divider(height: 24),
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatColumn(
                  icon: Icons.visibility,
                  count: speciesSeen,
                  label: isEs ? 'Especies\nvistas' : 'Species\nseen',
                  color: Colors.green,
                ),
                _StatColumn(
                  icon: Icons.camera_alt_outlined,
                  count: totalSightings,
                  label: isEs ? 'Avista-\nmientos' : 'Sight-\nings',
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Branding
            Text(
              'Galapagos Wildlife',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white38 : Colors.black38,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
