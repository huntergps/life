import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import '../../providers/home_provider.dart';

IconData _iconForSlug(String slug) {
  return switch (slug) {
    'reptiles' => FontAwesomeIcons.staffSnake,
    'birds' => FontAwesomeIcons.dove,
    'mammals' => FontAwesomeIcons.otter,
    'marine-life' => FontAwesomeIcons.fishFins,
    'invertebrates' => FontAwesomeIcons.shrimp,
    _ => FontAwesomeIcons.leaf,
  };
}

class CategoryGrid extends ConsumerWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final locale = ref.watch(localeProvider);
    return categoriesAsync.when(
      data: (categories) => SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _CategoryChip(
                name: locale == 'es' ? cat.nameEs : cat.nameEn,
                slug: cat.slug,
                onTap: () => context.goNamed('species', queryParameters: {'category': '${cat.id}'}),
              ),
            );
          },
        ),
      ),
      loading: () => const SizedBox(height: 110, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SizedBox(
        height: 110,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.t.common.error),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => ref.invalidate(categoriesProvider),
                child: Text(context.t.common.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final String name;
  final String slug;
  final VoidCallback onTap;

  const _CategoryChip({required this.name, required this.slug, required this.onTap});

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.primaryLight : Theme.of(context).colorScheme.primary;

    return Semantics(
      button: true,
      label: '${widget.name} category',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isHovered ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: SizedBox(
              width: 90,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? color.withValues(alpha: 0.2)
                          : isDark
                              ? AppColors.primaryLight.withValues(alpha: 0.12)
                              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: isDark
                          ? Border.all(color: AppColors.darkBorder, width: 0.5)
                          : null,
                    ),
                    child: Center(
                      child: FaIcon(
                        _iconForSlug(widget.slug),
                        color: color,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : null,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
