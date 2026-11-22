import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoService {
  ZegoExpressEngine? _engine;
  String? _currentRoomId;

  void Function(String command)? onCommandReceived;

  Future<void> initEngine() async {
    if (_engine != null) return;

    // ========== 这里填你自己的信息 ==========
    const int appID = 491443522;
    const String appSign = "f141828e865741eb46cccf86fb4667b5d808e4e02be0f214dcdcfbe622db4204";
    // =====================================

    final profile = ZegoEngineProfile(
      appID,
      ZegoScenario.General,
      appSign: appSign,
    );
    await ZegoExpressEngine.createEngineWithProfile(profile);
    _engine = ZegoExpressEngine.instance;
    _registerEvent();
  }

  void _registerEvent() {
    ZegoExpressEngine.onIMRecvBroadcastMessage = (roomID, messageList) {
      for (final msg in messageList) {
        final cmd = msg.message;
        if (onCommandReceived != null) {
          onCommandReceived!(cmd);
        }
      }
    };
  }

  Future<void> loginRoom(String userId) async {
    await initEngine();
    _currentRoomId = "voice_call_room";
    await _engine?.loginRoom(_currentRoomId!, ZegoUser(userId, userId));
  }

  Future<void> logoutRoom() async {
    if (_currentRoomId != null) {
      await _engine?.logoutRoom(_currentRoomId!);
    }
  }

  Future<void> sendCommand(String cmd) async {
    if (_currentRoomId == null) return;
    await _engine?.sendBroadcastMessage(_currentRoomId!, cmd);
  }
}
