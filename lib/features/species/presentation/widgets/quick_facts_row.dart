import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/brick/models/species.model.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

class QuickFactsRow extends StatelessWidget {
  final Species species;
  const QuickFactsRow({super.key, required this.species});

  @override
  Widget build(BuildContext context) {
    final t = context.t.species;
    final facts = <_Fact>[];
    if (species.populationEstimate != null) {
      facts.add(_Fact(icon: Icons.groups, label: t.population, value: '~${species.populationEstimate}'));
    }
    if (species.weightKg != null) {
      facts.add(_Fact(icon: Icons.fitness_center, label: t.weight, value: '${species.weightKg} ${t.kg}'));
    }
    if (species.sizeCm != null) {
      facts.add(_Fact(icon: Icons.straighten, label: t.size, value: '${species.sizeCm} ${t.cm}'));
    }
    if (species.lifespanYears != null) {
      facts.add(_Fact(icon: Icons.hourglass_bottom, label: t.lifespan, value: '${species.lifespanYears} ${t.years}'));
    }

    if (facts.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use a 2x2 grid for uniform sizing
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: facts
          .map((fact) => _FactCard(fact: fact, isDark: isDark))
          .toList(),
    );
  }
}

class _FactCard extends StatelessWidget {
  final _Fact fact;
  final bool isDark;

  const _FactCard({required this.fact, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.darkCard : Colors.grey.shade50;
    final iconBgColor = isDark
        ? AppColors.primaryLight.withValues(alpha: 0.15)
        : AppColors.primary.withValues(alpha: 0.1);
    final iconColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final borderColor = isDark
        ? AppColors.accentOrange.withValues(alpha: 0.2)
        : Colors.grey.shade200;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(fact.icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fact.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fact.value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact {
  final IconData icon;
  final String label;
  final String value;
  const _Fact({required this.icon, required this.label, required this.value});
}
