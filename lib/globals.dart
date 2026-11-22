import 'package:shared_preferences/shared_preferences.dart';

class Globals {
  // ⚠️ 必改：请去 ZEGO 官网获取你的真实 AppID 和 AppSign
  static const int zegoAppId = 491443522; 
  static const String zegoAppSign = "f141828e865741eb46cccf86fb4667b5d808e4e02be0f214dcdcfbe622db4204";
  
  static const String zegoRoomId = "123456"; // 双方默认进入的房间号
  static String currentRole = ''; // 'A' 或 'B'
  
  // 保存和读取角色
  static Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    currentRole = prefs.getString('device_role') ?? '';
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_role', role);
    currentRole = role;
  }

  // 保存微调参数
  static Future<void> saveEffect(int index, double pitch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('effect_$index', pitch);
  }

  static Future<double> loadEffect(int index) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('effect_$index') ?? 1.0; // 默认音调为 1.0
  }
}