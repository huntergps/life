import 'package:flutter/material.dart';
import 'adaptive_layout.dart';

/// A grid that adapts its column count to screen width.
///
/// Column counts follow [AdaptiveLayout.gridColumns]:
///   - Phone  (< 600 px):  1 column
///   - Tablet (600-899 px): 2 columns
///   - Desktop (≥ 900 px):  3 columns
///
/// The [childAspectRatio] defaults to 1.3 which works well for species/badge
/// cards that include a 16:9 image thumbnail plus a compact text section.
/// Override it when items have a different natural height ratio.
///
/// Example usage:
/// ```dart
/// ResponsiveGrid<Species>(
///   items: speciesList,
///   childAspectRatio: 1.3,
///   itemBuilder: (context, species, index) => SpeciesCard(species: species),
/// )
/// ```
class ResponsiveGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.childAspectRatio = 1.3,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = AdaptiveLayout.gridColumns(context);
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          itemBuilder(context, items[index], index),
    );
  }
}
