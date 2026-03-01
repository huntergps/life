import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:galapagos_wildlife/brick/models/species_sound.model.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

class SpeciesSoundPlayer extends StatefulWidget {
  final List<SpeciesSound> sounds;
  final String locale;

  const SpeciesSoundPlayer({
    super.key,
    required this.sounds,
    required this.locale,
  });

  @override
  State<SpeciesSoundPlayer> createState() => _SpeciesSoundPlayerState();
}

class _SpeciesSoundPlayerState extends State<SpeciesSoundPlayer> {
  AudioPlayer? _player;
  int? _playingIndex;
  bool _isLoading = false;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(int index, String url) async {
    if (_playingIndex == index) {
      await _player?.stop();
      setState(() {
        _playingIndex = null;
        _isLoading = false;
      });
      return;
    }

    await _player?.stop();
    _player?.dispose();
    _player = AudioPlayer();

    setState(() {
      _playingIndex = index;
      _isLoading = true;
    });

    try {
      await _player!.setUrl(url);
      setState(() => _isLoading = false);
      await _player!.play();
      _player!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) setState(() => _playingIndex = null);
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _playingIndex = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEs = widget.locale == 'es';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEs ? 'Sonidos' : 'Sounds',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...widget.sounds.asMap().entries.map((entry) {
          final index = entry.key;
          final sound = entry.value;
          final isPlaying = _playingIndex == index;
          final isThisLoading = _isLoading && _playingIndex == index;
          final label = isEs
              ? (sound.descriptionEs ?? sound.descriptionEn ?? sound.soundType ?? 'Sonido ${index + 1}')
              : (sound.descriptionEn ?? sound.descriptionEs ?? sound.soundType ?? 'Sound ${index + 1}');

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isPlaying
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isPlaying
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : (isDark ? Colors.white12 : Colors.black12),
              ),
            ),
            child: ListTile(
              dense: true,
              leading: isThisLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _togglePlay(index, sound.soundUrl),
                    ),
              title: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: sound.recordedBy != null
                  ? Text(
                      '${isEs ? 'Por' : 'By'}: ${sound.recordedBy}',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : null,
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}
