import 'package:shared_preferences/shared_preferences.dart';

class Globals {
  static const int zegoAppId = 491443522; 
  static const String zegoAppSign = "f141828e865741eb46cccf86fb4667b5d808e4e02be0f214dcdcfbe622db4204";
  static const String zegoRoomId = "123456";

  static String currentRole = '';

  static Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    currentRole = prefs.getString('device_role') ?? '';
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_role', role);
    currentRole = role;
  }

  static Future<void> saveCallRecord(String number, int duration, bool isMissed) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList('call_records') ?? [];
    // 格式: 号码|时间戳|时长(秒)|是否未接(1/0)
    String record = "$number|${DateTime.now().millisecondsSinceEpoch}|$duration|${isMissed ? 1 : 0}";
    records.insert(0, record);
    await prefs.setStringList('call_records', records);
  }
}