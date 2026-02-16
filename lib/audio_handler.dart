import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {

  final player = AudioPlayer();

  MyAudioHandler() {
    player.setAsset('assets/dearme_bg.mp3');
    player.setLoopMode(LoopMode.all);
  }

  @override
  Future<void> play() async {
    await player.play();
  }

  @override
  Future<void> pause() async {
    await player.pause();
  }

  @override
  Future<void> stop() async {
    await player.stop();
  }

  bool isPlaying() {
    return player.playing;
  }

  @override
  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  @override
  Future<void> skipToQueueItem(int i) async {}
}
