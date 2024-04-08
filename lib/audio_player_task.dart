import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  final _audioPlayer = AudioPlayer(); // Create an instance of just_audio's AudioPlayer

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    // Load and play an audio file
    await _audioPlayer.setUrl("https://example.com/your_audio_file.mp3");
    _audioPlayer.play();
  }

  @override
  Future<void> onStop() async {
    await _audioPlayer.stop();
    await super.onStop();
  }

  // Implement other methods like onPlay, onPause, onSkipToNext, onSkipToPrevious, etc.
}
