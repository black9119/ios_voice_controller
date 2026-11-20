import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'globals.dart';

class ZegoService {
  static final ZegoService _instance = ZegoService._internal();
  factory ZegoService() => _instance;
  ZegoService._internal();

  bool _isInitialized = false;
  Function(String command)? onCommandReceived;

  Future<void> init() async {
    if (_isInitialized) return;
    ZegoEngineProfile profile = ZegoEngineProfile(
      Globals.zegoAppId,
      ZegoScenario.Default,
      appSign: Globals.zegoAppSign,
    );
    await ZegoExpressEngine.createEngineWithProfile(profile);

    ZegoExpressEngine.onRoomExtraInfoUpdate = (String roomID, List<ZegoRoomExtraInfo> infoList) {
      for (var info in infoList) {
        if (info.key == "command" && onCommandReceived != null) {
          onCommandReceived!(info.value);
        }
      }
    };
    _isInitialized = true;
  }

  Future<void> initZego() async {
    await init();
  }

  Future<void> loginRoom(String userId) async {
    await init();
    ZegoUser user = ZegoUser(userId, userId);
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    config.isUserStatusNotify = true;
    await ZegoExpressEngine.instance.loginRoom(Globals.zegoRoomId, user, config: config);
  }

  Future<void> sendCommand(String command) async {
    await ZegoExpressEngine.instance.setRoomExtraInfo(Globals.zegoRoomId, "command", command);
  }

  Future<void> sendControlCommand(String command) async {
    await sendCommand(command);
  }

  void setVoicePreset(ZegoVoiceChangerPreset preset) {
    ZegoExpressEngine.instance.setVoiceChangerPreset(preset);
  }

  Future<void> logoutRoom() async {
    await ZegoExpressEngine.instance.logoutRoom(Globals.zegoRoomId);
  }

  Future<void> destroy() async {
    await ZegoExpressEngine.destroyEngine();
    _isInitialized = false;
  }
}
