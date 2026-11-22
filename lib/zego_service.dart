import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'globals.dart';

class ZegoService {
  static final ZegoService _instance = ZegoService._internal();
  factory ZegoService() => _instance;
  ZegoService._internal();

  bool _isInitialized = false;

  // 信令回调，传给 UI 层处理
  Function(Map<String, dynamic>)? onSignalReceived;

  Future<void> init() async {
    if (_isInitialized) return;
    ZegoEngineProfile profile = ZegoEngineProfile(
      Globals.zegoAppId,
      ZegoScenario.Default,
      appSign: Globals.zegoAppSign,
    );
    await ZegoExpressEngine.createEngineWithProfile(profile);

    // 修复：onIMRecvBroadcastMessage 是静态回调，直接用类名 ZegoExpressEngine 赋值
    ZegoExpressEngine.onIMRecvBroadcastMessage = (roomID, messageList) {
      try {
        for (final msg in messageList) {
          final data = jsonDecode(msg.message) as Map<String, dynamic>;
          if (onSignalReceived != null) onSignalReceived!(data);
        }
      } catch (e) {
        debugPrint('信令解析失败: $e');
      }
    };

    _isInitialized = true;
  }

  Future<void> loginRoom(String userId) async {
    await init();
    ZegoUser user = ZegoUser.id(userId);
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    config.isUserStatusNotify = true;
    await ZegoExpressEngine.instance.loginRoom(Globals.zegoRoomId, user, config: config);
  }

  Future<void> sendSignal(Map<String, dynamic> data) async {
    final message = jsonEncode(data);
    await ZegoExpressEngine.instance.sendBroadcastMessage(Globals.zegoRoomId, message);
  }

  Future<void> setVoiceChanger(double pitch) async {
    ZegoVoiceChangerParam param = ZegoVoiceChangerParam(pitch);
    await ZegoExpressEngine.instance.setVoiceChangerParam(param);
  }

  Future<void> setVoicePreset(ZegoVoiceChangerPreset preset) async {
    await ZegoExpressEngine.instance.setVoiceChangerPreset(preset);
  }

  Future<void> muteMicrophone(bool mute) async {
    await ZegoExpressEngine.instance.muteMicrophone(mute);
  }

  Future<void> setSpeakerVolume(bool enable) async {
    await ZegoExpressEngine.instance.setAudioRouteToSpeaker(enable);
  }

  Future<void> logoutRoom() async {
    await ZegoExpressEngine.instance.logoutRoom(Globals.zegoRoomId);
  }
}
