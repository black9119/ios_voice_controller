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
    _isInitialized = true;
  }

  Future<void> loginRoom(String userId) async {
    await init();
    ZegoUser user = ZegoUser.id(userId);
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    await ZegoExpressEngine.instance.loginRoom(Globals.zegoRoomId, user, config: config);
    
    ZegoExpressEngine.instance.onRoomExtraInfoUpdate = (roomID, infoList) {
      for (var info in infoList) {
        if (info.key == "command" && onCommandReceived != null) {
          onCommandReceived!(info.value);
        }
      }
    };
  }

  Future<void> sendCommand(String command) async {
    await ZegoExpressEngine.instance.setRoomExtraInfo(Globals.zegoRoomId, "command", command);
  }

  Future<void> logoutRoom() async {
    await ZegoExpressEngine.instance.logoutRoom(Globals.zegoRoomId);
  }
}