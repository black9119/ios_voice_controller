import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoService {
  static final ZegoService _instance = ZegoService._internal();
  factory ZegoService() => _instance;
  ZegoService._internal();

  static const int appID = 491443522;
  static const String appSign = "f141828e865741eb46cccf86fb4667b5d808e4e02be0f214dcdcfbe622db4204";

  bool isInitialized = false;
  bool isLoggedIn = false;
  final String _fixedRoomId = "room_001";

  Function(String)? onCommandReceived;

  Future<void> initZego() async {
    if (isInitialized) return;
    ZegoEngineProfile profile = ZegoEngineProfile(
      appID,
      ZegoScenario.Default,
      appSign: appSign,
    );
    await ZegoExpressEngine.createEngineWithProfile(profile);

    ZegoExpressEngine.onIMRecvCustomCommand = (String roomID, ZegoUser fromUser, String command) {
      debugPrint("收到指令：$command");
      onCommandReceived?.call(command);
    };

    ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, streamList, ext) {};

    isInitialized = true;
    debugPrint("ZEGO SDK 初始化完成");
  }

  Future<void> loginRoom(String roomID, String userID, String userName) async {
    await initZego();
    ZegoUser user = ZegoUser.id(userID);
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    final result = await ZegoExpressEngine.instance.loginRoom(roomID, user, config: config);
    if (result.errorCode == 0) {
      isLoggedIn = true;
      debugPrint("登录房间成功: $roomID");
    } else {
      debugPrint("登录房间失败 code: ${result.errorCode}");
    }
  }

  void startPublish() {
    ZegoExpressEngine.instance.startPublishingStream("stream_${DateTime.now().millisecondsSinceEpoch}");
  }

  void startPlay(String streamID) {
    ZegoExpressEngine.instance.startPlayingStream(streamID);
  }

  void setVoicePreset(int preset) {
    ZegoVoiceChangerPreset targetPreset;
    switch (preset) {
      case 0:
        targetPreset = ZegoVoiceChangerPreset.None;
        break;
      case 1:
        targetPreset = ZegoVoiceChangerPreset.Android;
        break;
      case 2:
        targetPreset = ZegoVoiceChangerPreset.MenToChild;
        break;
      case 3:
        targetPreset = ZegoVoiceChangerPreset.WomenToMen;
        break;
      default:
        targetPreset = ZegoVoiceChangerPreset.None;
    }
    ZegoExpressEngine.instance.setVoiceChangerPreset(targetPreset);
  }

  Future<void> sendControlCommand(String command) async {
    final res = await ZegoExpressEngine.instance.sendCustomCommand(
      _fixedRoomId,
      command,
      [],
    );
    debugPrint("发送指令结果：${res.errorCode}");
  }
}
