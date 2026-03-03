import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:galapagos_wildlife/core/widgets/cached_species_image.dart';
import 'package:galapagos_wildlife/core/constants/species_assets.dart';
import 'package:galapagos_wildlife/core/services/location/location_permission_service.dart';
import 'package:galapagos_wildlife/features/settings/providers/settings_provider.dart';
import '../../providers/audio_recorder_provider.dart';
import '../../providers/sound_id_provider.dart';

class SoundIdScreen extends ConsumerStatefulWidget {
  const SoundIdScreen({super.key});

  @override
  ConsumerState<SoundIdScreen> createState() => _SoundIdScreenState();
}

class _SoundIdScreenState extends ConsumerState<SoundIdScreen>
    with SingleTickerProviderStateMixin {
  double? _lat;
  double? _lng;
  bool _locationLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _tryGetLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _tryGetLocation() async {
    if (kIsWeb) return;
    setState(() => _locationLoading = true);
    try {
      if (!await LocationPermissionService.isServiceEnabled()) return;
      if (!await LocationPermissionService.ensurePermission()) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (mounted) setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
    } catch (_) {
      // Location not available, continue without it
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  Future<void> _startRecording() async {
    if (kIsWeb) return;
    final notifier = ref.read(audioRecorderProvider.notifier);
    final hasPermission = await notifier.checkPermission();
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission required')),
      );
      return;
    }
    await notifier.startRecording();
  }

  Future<void> _stopAndAnalyze() async {
    await ref.read(audioRecorderProvider.notifier).stopRecording();
    // Trigger suggestions refresh
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final recorderState = ref.watch(audioRecorderProvider);
    final isEs = ref.watch(localeProvider.select((l) => l == 'es'));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Row(
          children: [
            const Icon(Icons.mic, size: 20),
            const SizedBox(width: 8),
            Text(isEs ? 'ID de Sonido' : 'Sound ID'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Location status chip
              _buildLocationChip(isEs, isDark),
              const SizedBox(height: 32),

              if (recorderState == RecorderState.idle) ...[
                _buildIdleState(isEs, isDark),
              ] else if (recorderState == RecorderState.recording) ...[
                _buildRecordingState(isEs, isDark),
              ] else ...[
                _buildResultsState(isEs, isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationChip(bool isEs, bool isDark) {
    String label;
    Color color;
    IconData icon;

    if (_locationLoading) {
      label = isEs ? 'Obteniendo ubicación...' : 'Getting location...';
      color = Colors.orange;
      icon = Icons.location_searching;
    } else if (_lat != null) {
      label = isEs ? 'Ubicación obtenida' : 'Location available';
      color = Colors.green;
      icon = Icons.location_on;
    } else {
      label = isEs ? 'Sin ubicación' : 'No location';
      color = Colors.grey;
      icon = Icons.location_off;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
    );
  }

  Widget _buildIdleState(bool isEs, bool isDark) {
    return Column(
      children: [
        // Pulsing mic button
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) => Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          ),
          child: GestureDetector(
            onTap: kIsWeb ? null : _startRecording,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: Icon(
                Icons.mic,
                size: 64,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isEs ? 'Toca para identificar fauna cercana' : 'Tap to identify nearby wildlife',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isEs
              ? 'Usaremos tu ubicación y la hora para\nsugerir la fauna más probable'
              : 'We\'ll use your location and time to\nsuggest the most likely wildlife',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        if (kIsWeb) ...[
          const SizedBox(height: 16),
          const Chip(label: Text('Requires mobile device')),
        ],
      ],
    );
  }

  Widget _buildRecordingState(bool isEs, bool isDark) {
    ref.watch(recordingTickProvider); // force rebuild every second
    final elapsed = ref.read(audioRecorderProvider.notifier).elapsedSeconds;
    return Column(
      children: [
        // Animated waveform bars
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(12, (i) {
              return AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) {
                  final phase = (i / 12 * 2 * math.pi + _pulseController.value * 2 * math.pi);
                  final h = 20.0 + 40.0 * math.sin(phase).abs();
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: h,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${isEs ? "Grabando" : "Recording"}... 0:${elapsed.toString().padLeft(2, "0")} / 0:10',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _stopAndAnalyze,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.shade600,
              border: Border.all(color: Colors.red.shade800, width: 3),
            ),
            child: const Icon(Icons.stop, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isEs ? 'Toca para detener' : 'Tap to stop',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildResultsState(bool isEs, bool isDark) {
    final suggestionsAsync = ref.watch(soundIdSuggestionsProvider((lat: _lat, lng: _lng)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isEs ? 'Fauna cerca de ti ahora' : 'Wildlife near you right now',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(isEs ? 'Nuevo' : 'New'),
              onPressed: () {
                ref.read(audioRecorderProvider.notifier).reset();
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isEs
              ? 'Basado en tu ubicación y hora del día'
              : 'Based on your location & time of day',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        suggestionsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (suggestions) {
            if (suggestions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    isEs
                        ? 'Sin datos de especies para esta área'
                        : 'No species data for this area',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return Column(
              children: suggestions
                  .map((s) => _SuggestionCard(
                        suggestion: s,
                        isEs: isEs,
                        isDark: isDark,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final SoundIdSuggestion suggestion;
  final bool isEs;
  final bool isDark;

  const _SuggestionCard({
    required this.suggestion,
    required this.isEs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final sp = suggestion.species;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedSpeciesImage(
                imageUrl: sp.thumbnailUrl ?? SpeciesAssets.thumbnail(sp.id),
                speciesId: sp.id,
                width: 60,
                height: 60,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEs ? sp.commonNameEs : sp.commonNameEn,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  Text(
                    sp.scientificName,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suggestion.reason,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                TextButton(
                  onPressed: () => context.push('/species/${sp.id}'),
                  style: TextButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                  child: Text(isEs ? 'Ver' : 'View', style: const TextStyle(fontSize: 12)),
                ),
                TextButton(
                  onPressed: () => context.push('/sightings/add'),
                  style: TextButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                  child: Text(isEs ? 'Registrar' : 'Log', style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
