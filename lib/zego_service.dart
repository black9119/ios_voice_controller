import 'dart:convert';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'globals.dart';

class ZegoService {
  static final ZegoService _instance = ZegoService._internal();
  factory ZegoService() => _instance;
  ZegoService._internal();

  bool _isInitialized = false;

  Function(Map<String, dynamic> data)? onSignalReceived;
  Function(String command)? onCommandReceived;

  Future<void> init() async {
    if (_isInitialized) return;
    ZegoEngineProfile profile = ZegoEngineProfile(
      Globals.zegoAppId,
      ZegoScenario.Default,
      appSign: Globals.zegoAppSign,
    );
    await ZegoExpressEngine.createEngineWithProfile(profile);

    ZegoExpressEngine.onRoomExtraInfoUpdate = (roomID, infoList) {
      for (var info in infoList) {
        if (info.key == "command" && onCommandReceived != null) {
          onCommandReceived!(info.value);
        }
      }
    };

    ZegoExpressEngine.onIMRecvBroadcastMessage = (roomID, messageList) {
      for (final msgInfo in messageList) {
        try {
          final Map<String, dynamic> data = jsonDecode(msgInfo.message);
          if (onSignalReceived != null) {
            onSignalReceived!(data);
          }
        } catch (_) {}
      }
    };

    _isInitialized = true;
  }

  Future<void> loginRoom(String userId) async {
    await init();
    // 修复：ZegoUser 需要 userID, userName 两个参数
    ZegoUser user = ZegoUser(userId, userId);
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    await ZegoExpressEngine.instance.loginRoom(Globals.zegoRoomId, user, config: config);
  }

  Future<void> sendCommand(String cmd) async {
    await ZegoExpressEngine.instance.setRoomExtraInfo(Globals.zegoRoomId, "command", cmd);
  }

  Future<void> logoutRoom() async {
    await ZegoExpressEngine.instance.logoutRoom(Globals.zegoRoomId);
  }
}
