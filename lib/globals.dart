import 'package:shared_preferences/shared_preferences.dart';

class Globals {
  static String currentRole = "A";
  // appId 改为 int
  static int zegoAppId = 491443522;
  static String zegoAppSign = "f141828e865741eb46cccf86fb4667b5d808e4e02be0f214dcdcfbe622db4204";
  static String zegoRoomId = "call_room_001";

  // 加载角色 A/B
  static Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString("user_role");
    if (role != null) {
      currentRole = role;
    } else {
      currentRole = "A";
    }
  }

  // 保存角色 A/B
  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_role", role);
    currentRole = role;
  }

  // 保存变声音调
  static Future<void> saveEffect(int index, double pitch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("effect_pitch_$index", pitch);
  }

  // 读取变声音调
  static Future<double> loadEffect(int index) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble("effect_pitch_$index") ?? 1.0;
  }
}
