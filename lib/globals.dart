// lib/globals.dart
import 'package:shared_preferences/shared_preferences.dart';

class Globals {
  // 角色 A / B
  static String currentRole = 'A';
  // Zego 房间ID
  static String zegoRoomId = 'room1';

  // Zego 配置
  static int zegoAppId = 0;
  static String zegoAppSign = '';
  static String token = '';

  // 自定义服务IP
  static String serverIp = '127.0.0.1';

  // 保存角色（dialer_screen用到）
  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    currentRole = role;
    await prefs.setString('role', role);
  }

  // 通话记录相关，改成Future，支持await
  static Future<void> saveCallRecord(String number, int seconds, bool isOut) async {
    // 占位，兼容编译
  }

  // 变声音调保存读取
  static Future<double> loadEffect(int index) async {
    final prefs = await SharedPreferences.getInstance();
    double pitch = prefs.getDouble('pitch_$index') ?? 1.0;
    return pitch;
  }

  static Future<void> saveEffect(int index, double pitch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pitch_$index', pitch);
  }

  // 从本地缓存加载配置
  static Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    serverIp = prefs.getString('server_ip') ?? '127.0.0.1';
    currentRole = prefs.getString('role') ?? 'A';
  }

  // 保存配置到本地
  static Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', serverIp);
    await prefs.setString('role', currentRole);
  }
}
