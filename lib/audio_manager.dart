import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 提示音播放：忙音 / 空号
/// 资源文件放 assets/audio/busy.mp3、assets/audio/empty_number.mp3
/// 若资源缺失，自动降级为系统提示音，保证不会静默无反馈
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _loop = false;

  Future<void> playSound(String soundName) async {
    if (soundName == 'stop') {
      await stop();
      return;
    }
    String asset;
    if (soundName == 'busy') {
      asset = 'audio/busy.mp3';
    } else if (soundName == 'empty') {
      asset = 'audio/empty_number.mp3';
    } else {
      return;
    }
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(asset));
      _loop = true;
    } catch (e) {
      debugPrint('播放音频失败($asset): $e');
      // 资源缺失兜底
      SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> stop() async {
    _loop = false;
    try {
      await _player.stop();
    } catch (_) {}
  }

  bool get isPlaying => _loop;

  void dispose() {
    _player.dispose();
  }
}
