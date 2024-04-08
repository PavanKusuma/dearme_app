import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class MyAudioHandler extends BaseAudioHandler
    with QueueHandler, // mix in default queue callback implementations
    SeekHandler { // mix in default seek callback implementations
  
  final player = AudioPlayer();
  

  MyAudioHandler(){
    player.setAsset('assets/dearme_bg.mp3');
    player.play();
  }
  // The most common callbacks:

  Future<void> play() async {
    player.play();
    player.setLoopMode(LoopMode.all);


    // All 'play' requests from all origins route to here. Implement this
    // callback to start playing audio appropriate to your app. e.g. music.
  }
  Future<void> pause() async {
    player.pause();
  }
  Future<void> stop() async {
    
    // checking the player state and playing/stopping the player
    player.playerState.playing ? player.stop() : play();
    // player.stop();
  }
  bool isPlaying() {
    
    // checking the player state and playing/stopping the player
    return player.playerState.playing;
    // player.stop();
  }
  Future<void> seek(Duration position) async {}
  Future<void> skipToQueueItem(int i) async {}
}

