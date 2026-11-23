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

    // 修复：onRoomExtraInfoUpdate 是静态回调，使用类名 ZegoExpressEngine 直接赋值，不要用 instance
    ZegoExpressEngine.onRoomExtraInfoUpdate = (roomID, infoList) {
      for (var info in infoList) {
        if (info.key == "command" && onCommandReceived != null) {
          onCommandReceived!(info.value);
        }
      }
    };

    _isInitialized = true;
  }

  Future<void> loginRoom(String userId) async {
    await init();
    ZegoUser user = ZegoUser.id(userId);
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    await ZegoExpressEngine.instance.loginRoom(Globals.zegoRoomId, user, config: config);
  }

  Future<void> sendCommand(String command) async {
    await ZegoExpressEngine.instance.setRoomExtraInfo(Globals.zegoRoomId, "command", command);
  }

  Future<void> logoutRoom() async {
    await ZegoExpressEngine.instance.logoutRoom(Globals.zegoRoomId);
  }
}
