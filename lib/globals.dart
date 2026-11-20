import 'package:shared_preferences/shared_preferences.dart';

class Globals {
  // ⚠️ 请在这里填入你的 ZEGO AppID 和 AppSign
  static const int zegoAppId = 491443522; 
  static const String zegoAppSign = "f141828e865741eb46cccf86fb4667b5d808e4e02be0f214dcdcfbe622db4204";
  
  static const String zegoRoomId = "123456"; // 双方默认进入的房间号

  // 全局角色信息
  static String currentRole = ''; // 'A' 或 'B'

  static Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    currentRole = prefs.getString('device_role') ?? '';
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_role', role);
    currentRole = role;
  }
}