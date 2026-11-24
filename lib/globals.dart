import 'package:shared_preferences/shared_preferences.dart';

class Globals {
  static const int zegoAppId = 000000000; 
  static const String zegoAppSign = "your_app_sign_here";
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