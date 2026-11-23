import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playSound(String soundName) async {
    try {
      if (soundName == 'busy') {
        await _audioPlayer.play(AssetSource('audio/busy.mp3'));
      } else if (soundName == 'empty') {
        await _audioPlayer.play(AssetSource('audio/empty_number.mp3'));
      } else if (soundName == 'stop') {
        await _audioPlayer.stop();
      }
    } catch (e) {
      debugPrint("播放音频失败: $e");
    }
  }

  void stop() {
    _audioPlayer.stop();
  }
}
