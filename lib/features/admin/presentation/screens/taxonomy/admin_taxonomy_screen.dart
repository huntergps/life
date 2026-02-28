import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import '../../../providers/admin_taxonomy_provider.dart';
import '../../widgets/admin_taxonomy_editor.dart';

class AdminTaxonomyScreen extends ConsumerWidget {
  const AdminTaxonomyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.admin.manageTaxonomy),
        backgroundColor: isDark ? AppColors.darkBackground : null,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(taxonomyClassesProvider);
          ref.invalidate(taxonomyClassCountProvider);
          ref.invalidate(taxonomyOrderCountProvider);
          ref.invalidate(taxonomyFamilyCountProvider);
          ref.invalidate(taxonomyGenusCountProvider);
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TaxonomySummary(isDark: isDark),
                const SizedBox(height: 16),
                const AdminTaxonomyEditor(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Summary row showing total counts of each taxonomy level.
class _TaxonomySummary extends ConsumerWidget {
  final bool isDark;

  const _TaxonomySummary({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classCount = ref.watch(taxonomyClassCountProvider);
    final orderCount = ref.watch(taxonomyOrderCountProvider);
    final familyCount = ref.watch(taxonomyFamilyCountProvider);
    final genusCount = ref.watch(taxonomyGenusCountProvider);

    return Card(
      color: isDark ? AppColors.darkCard : null,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark
            ? const BorderSide(color: AppColors.darkBorder, width: 0.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _countChip(
              context: context,
              icon: Icons.category,
              color: const Color(0xFF2E7D32),
              label: context.t.admin.taxonomyClasses,
              asyncCount: classCount,
            ),
            _countChip(
              context: context,
              icon: Icons.format_list_numbered,
              color: const Color(0xFF1565C0),
              label: context.t.admin.taxonomyOrders,
              asyncCount: orderCount,
            ),
            _countChip(
              context: context,
              icon: Icons.family_restroom,
              color: const Color(0xFFE65100),
              label: context.t.admin.taxonomyFamilies,
              asyncCount: familyCount,
            ),
            _countChip(
              context: context,
              icon: Icons.eco,
              color: const Color(0xFF6A1B9A),
              label: context.t.admin.taxonomyGenera,
              asyncCount: genusCount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _countChip({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required AsyncValue<int> asyncCount,
  }) {
    final count = asyncCount.asData?.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        if (count != null)
          Text(
            '$count',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          )
        else
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
          ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
