import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

enum RecorderState { idle, recording, stopped }

class AudioRecorderNotifier extends Notifier<RecorderState> {
  final _recorder = AudioRecorder();
  Timer? _timer;
  int _seconds = 0;
  int get elapsedSeconds => _seconds;

  @override
  RecorderState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _recorder.dispose();
    });
    return RecorderState.idle;
  }

  Future<bool> checkPermission() async {
    if (kIsWeb) return false;
    return _recorder.hasPermission();
  }

  Future<void> startRecording() async {
    if (kIsWeb) return;
    if (!await _recorder.hasPermission()) return;
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/sound_id_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    _seconds = 0;
    state = RecorderState.recording;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      if (_seconds >= 10) stopRecording();
    });
  }

  Future<void> stopRecording() async {
    _timer?.cancel();
    _timer = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    state = RecorderState.stopped;
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _seconds = 0;
    state = RecorderState.idle;
  }

}

final audioRecorderProvider = NotifierProvider<AudioRecorderNotifier, RecorderState>(
  AudioRecorderNotifier.new,
);

/// Ticker to force UI rebuilds while recording (elapsed seconds)
final recordingTickProvider = StreamProvider<int>((ref) async* {
  int i = 0;
  while (true) {
    await Future.delayed(const Duration(seconds: 1));
    yield ++i;
  }
});
