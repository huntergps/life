import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/widgets/cached_species_image.dart';
import 'package:galapagos_wildlife/models/species.model.dart';
import 'package:galapagos_wildlife/models/sighting.model.dart';
import 'package:galapagos_wildlife/features/species/shared/species_checklist_provider.dart';
import 'package:galapagos_wildlife/features/sightings/providers/sightings_provider.dart';
import 'package:galapagos_wildlife/features/purchases/presentation/paywall_screen.dart';
import 'package:galapagos_wildlife/app/theme/app_colors.dart';

/// Shows the checklist detail bottom sheet.
/// Premium users see date, GPS, photo. Free users see an upgrade prompt.
Future<void> showChecklistDetailSheet({
  required BuildContext context,
  required Species species,
  required ChecklistEntry? entry,
  required bool isPremium,
}) {
  if (!isPremium) {
    // Free users: show upgrade prompt
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _FreeUserPrompt(species: species, seenAt: entry?.seenAt),
    );
  }
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => ChecklistDetailSheet(
      species: species,
      entry: entry,
    ),
  );
}

class ChecklistDetailSheet extends ConsumerWidget {
  final Species species;
  final ChecklistEntry? entry;

  const ChecklistDetailSheet({
    super.key,
    required this.species,
    this.entry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    final speciesName = isEs ? species.commonNameEs : species.commonNameEn;

    // Find the most recent sighting for this species
    final sightingsAsync = ref.watch(sightingsProvider);
    final Sighting? latestSighting = sightingsAsync.asData?.value
        .where((s) => s.speciesId == species.id)
        .firstOrNull;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Species image + name header
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: CachedSpeciesImage(
                          imageUrl: species.thumbnailUrl ?? species.heroImageUrl,
                          speciesId: species.id,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            speciesName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            species.scientificName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Seen at date/time
                if (entry?.seenAt != null) ...[
                  _InfoRow(
                    icon: Icons.check_circle,
                    iconColor: Colors.green,
                    label: isEs
                        ? 'Vista el: ${_formatDateEs(entry!.seenAt!)}'
                        : 'Seen on: ${_formatDateEn(entry!.seenAt!)}',
                  ),
                  const SizedBox(height: 12),
                ],

                // Checklist GPS (captured at mark time)
                if (entry?.latitude != null && entry?.longitude != null) ...[
                  _InfoRow(
                    icon: Icons.my_location,
                    iconColor: Colors.blue,
                    label: isEs
                        ? 'Marcado en: ${entry!.latitude!.toStringAsFixed(5)}, ${entry!.longitude!.toStringAsFixed(5)}'
                        : 'Marked at: ${entry!.latitude!.toStringAsFixed(5)}, ${entry!.longitude!.toStringAsFixed(5)}',
                  ),
                  const SizedBox(height: 12),
                ],

                // Sighting details (if available)
                if (latestSighting != null) ...[
                  if (latestSighting.latitude != null &&
                      latestSighting.longitude != null) ...[
                    _InfoRow(
                      icon: Icons.location_on,
                      iconColor: isDark ? AppColors.accentOrange : AppColors.primary,
                      label: '${latestSighting.latitude!.toStringAsFixed(5)}, '
                          '${latestSighting.longitude!.toStringAsFixed(5)}',
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (latestSighting.notes != null &&
                      latestSighting.notes!.isNotEmpty) ...[
                    _InfoRow(
                      icon: Icons.notes,
                      iconColor: isDark ? Colors.white54 : Colors.grey.shade600,
                      label: latestSighting.notes!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (latestSighting.photoUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          latestSighting.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                            child: const Center(child: Icon(Icons.broken_image, size: 40)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ] else ...[
                  // No sighting yet
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: isDark ? Colors.white38 : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isEs
                                ? 'Sin registro detallado aun -- toca para agregar un avistamiento'
                                : 'No detailed record yet -- tap to add a sighting',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const Divider(),
                const SizedBox(height: 12),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add_a_photo),
                    label: Text(
                      isEs ? 'Registrar avistamiento' : 'Record full sighting',
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.pushNamed('add-sighting');
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    label: Text(
                      isEs ? 'Desmarcar como vista' : 'Mark as not seen',
                      style: const TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: () async {
                      await ref
                          .read(userChecklistProvider.notifier)
                          .toggle(species.id);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateEn(DateTime dt) {
    // "March 15, 2026 at 2:30 PM"
    final datePart = DateFormat.yMMMMd('en').format(dt);
    final timePart = DateFormat.jm('en').format(dt);
    return '$datePart at $timePart';
  }

  String _formatDateEs(DateTime dt) {
    // "15 de marzo de 2026 a las 14:30"
    final datePart = DateFormat("d 'de' MMMM 'de' yyyy", 'es').format(dt);
    final timePart = DateFormat.Hm('es').format(dt);
    return '$datePart a las $timePart';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// Shown to free users when they tap a seen species — prompts upgrade.
class _FreeUserPrompt extends StatelessWidget {
  final Species species;
  final DateTime? seenAt;

  const _FreeUserPrompt({required this.species, this.seenAt});

  @override
  Widget build(BuildContext context) {
    final isEs = LocaleSettings.currentLocale == AppLocale.es;
    final name = isEs ? species.commonNameEs : species.commonNameEn;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 48, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (seenAt != null) ...[
            const SizedBox(height: 8),
            Text(
              isEs ? 'Marcada como vista' : 'Marked as seen',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            isEs
                ? 'La fecha, hora, ubicación GPS y fotos de tus avistamientos están disponibles con el Pack Galápagos'
                : 'Date, time, GPS location and photos of your sightings are available with the Galapagos Pack',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                showPaywall(context);
              },
              child: Text(isEs ? 'Ver planes' : 'See plans'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
