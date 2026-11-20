import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoService {
  static final ZegoService _instance = ZegoService._internal();
  factory ZegoService() => _instance;
  ZegoService._internal();

  // ⚠️ 替换为你的 ZEGO AppID 和 AppSign
  static const int appID = 491443522; // 填你的 AppID
  static const String appSign = "f141828e865741eb46cccf86fb4667b5d808e4e02be0f214dcdcfbe622db4204"; // 填你的 AppSign

  bool isInitialized = false;
  bool isLoggedIn = false;

  Function(String)? onCommandReceived;

  Future<void> initZego() async {
    if (isInitialized) return;
    ZegoEngineProfile profile = ZegoEngineProfile(
      appID,
      ZegoScenario.Default,
      appSign: appSign,
    );
    await ZegoExpressEngine.createEngineWithProfile(profile);
    ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, streamList) {};
    isInitialized = true;
    debugPrint("ZEGO SDK 初始化完成");
  }

  Future<void> loginRoom(String roomID, String userID, String userName) async {
    await initZego();
    ZegoUser user = ZegoUser.id(userID);
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    ZegoExpressEngine.instance.loginRoom(roomID, user, config: config).then((result) {
      isLoggedIn = true;
      debugPrint("登录房间成功: $roomID");
    }).catchError((e) {
      debugPrint("登录房间失败: $e");
    });
  }

  void startPublish() {
    ZegoExpressEngine.instance.startPublishingStream("stream_${DateTime.now().millisecondsSinceEpoch}");
  }

  void startPlay(String streamID) {
    ZegoExpressEngine.instance.startPlayingStream(streamID);
  }

  // 语音变声设置 (0: 正常, 1: 机器人, 2: 萝莉, 3: 大叔)
  void setVoicePreset(int preset) {
    // 原生变声 API，直接调用
    ZegoExpressEngine.instance.setVoicePreset(preset);
  }

  // 发送自定义指令 (B端下发)
  void sendCustomCommand(String command) {
    ZegoExpressEngine.instance.sendCustomCommand("room_id", command, "user_id");
  }
}