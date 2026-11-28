import 'dart:convert';

import 'package:zego_express_engine/zego_express_engine.dart';

import 'globals.dart';

/// Zego 语音房 + A/B 端信令
/// 信令统一走房间附加信息（key = call_signal），避免依赖广播消息接口
class ZegoService {
  static final ZegoService _instance = ZegoService._internal();
  factory ZegoService() => _instance;
  ZegoService._internal();

  static const String _signalKey = 'call_signal';

  bool _initialized = false;
  String _userId = '';

  /// 收到 B 端发来的指令（忙音 / 空号）
  void Function(String action)? onCommandReceived;

  /// 收到任意信令：invite / accept / start_timer / hangup / command
  void Function(Map<String, dynamic> data)? onSignalReceived;

  Future<void> init() async {
    if (_initialized) return;
    final ZegoEngineProfile profile = ZegoEngineProfile(
      Globals.zegoAppId,
      ZegoScenario.Default,
      appSign: Globals.zegoAppSign,
    );
    await ZegoExpressEngine.createEngineWithProfile(profile);
    _initialized = true;

    // 静态回调：必须通过类名赋值，且要在引擎创建之后注册
    ZegoExpressEngine.onRoomExtraInfoUpdate = _onRoomExtraInfoUpdate;
  }

  /// 房间附加信息变更（静态回调，只会注册一次）
  static void _onRoomExtraInfoUpdate(
    String roomID,
    List<ZegoRoomExtraInfo> infoList,
  ) {
    for (final ZegoRoomExtraInfo info in infoList) {
      if (info.key != _signalKey) continue;
      final Map<String, dynamic>? data = _instance._decode(info.value);
      if (data == null) continue;
      // 忽略自己发的信令
      if ((data['from'] ?? '').toString() == _instance._userId) continue;
      if (data['type'] == 'command') {
        _instance.onCommandReceived?.call((data['action'] ?? '').toString());
      }
      _instance.onSignalReceived?.call(data);
    }
  }

  Future<void> loginRoom(String userId) async {
    await init();
    _userId = userId;
    final ZegoUser user = ZegoUser.id(userId);
    final ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    await ZegoExpressEngine.instance.loginRoom(
      Globals.zegoRoomId,
      user,
      config: config,
    );
  }

  Future<void> send(Map<String, dynamic> data) async {
    final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
    payload['id'] = DateTime.now().microsecondsSinceEpoch.toString();
    payload['from'] = _userId;
    await ZegoExpressEngine.instance.setRoomExtraInfo(
      Globals.zegoRoomId,
      _signalKey,
      jsonEncode(payload),
    );
  }

  /// 兼容旧代码：只发 command
  Future<void> sendCommand(String action) async {
    await send(<String, dynamic>{'type': 'command', 'action': action});
  }

  Future<void> logoutRoom() async {
    if (_userId.isEmpty) return;
    _userId = '';
    await ZegoExpressEngine.instance.logoutRoom(Globals.zegoRoomId);
  }

  Map<String, dynamic>? _decode(String value) {
    try {
      final dynamic decoded = jsonDecode(value);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }
}
