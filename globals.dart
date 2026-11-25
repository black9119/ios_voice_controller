import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 一条通话记录
class CallRecord {
  final String id;
  final String number;
  final int time; // 毫秒时间戳
  final int duration; // 通话秒数
  final bool answered; // 是否接通
  final String direction; // out: 我拨出 / in: 我接入

  const CallRecord({
    required this.id,
    required this.number,
    required this.time,
    required this.duration,
    required this.answered,
    required this.direction,
  });

  factory CallRecord.fromMap(Map<String, dynamic> m) {
    return CallRecord(
      id: (m['id'] ?? '').toString(),
      number: (m['number'] ?? '').toString(),
      time: int.tryParse((m['time'] ?? 0).toString()) ?? 0,
      duration: int.tryParse((m['duration'] ?? 0).toString()) ?? 0,
      answered: m['answered'] == true,
      direction: (m['direction'] ?? 'out').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'number': number,
      'time': time,
      'duration': duration,
      'answered': answered,
      'direction': direction,
    };
  }
}

class Globals {
  // ======== Zego 配置 ========
  static const int zegoAppId = 491443522;
  static const String zegoAppSign =
      'f141828e865741eb46cccf86fb4667b5d808e4e02be0f214dcdcfbe622db4204';
  static const String zegoRoomId = '123456';

  // ======== 隐藏入口口令 ========
  static const String secretCode = '999999999';

  // ======== 运行状态 ========
  static String currentRole = ''; // 'A' / 'B' / ''
  static String currentPort = '副号';

  static const List<String> ports = <String>['副号', '主号', '号码 3', '号码 4'];

  // ======== 存储键 ========
  static const String _kRole = 'device_role';
  static const String _kPort = 'device_port';
  static const String _kRecords = 'call_records';
  static const String _kEffectPrefix = 'voice_effect_';
  static const String _kSelectedEffect = 'voice_selected_effect';

  static Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    currentRole = prefs.getString(_kRole) ?? '';
    currentPort = prefs.getString(_kPort) ?? '副号';
    if (!ports.contains(currentPort)) currentPort = '副号';
  }

  static Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    currentRole = prefs.getString(_kRole) ?? '';
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRole, role);
    currentRole = role;
  }

  static Future<void> savePort(String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPort, port);
    currentPort = port;
  }

  // ======== 通话记录 ========
  static Future<String> addCallRecord(
    String number, {
    bool answered = false,
    String direction = 'out',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_kRecords) ?? <String>[];
    final int now = DateTime.now().millisecondsSinceEpoch;
    final String id = now.toString();
    final CallRecord record = CallRecord(
      id: id,
      number: number,
      time: now,
      duration: 0,
      answered: answered,
      direction: direction,
    );
    list.insert(0, jsonEncode(record.toMap()));
    await prefs.setStringList(_kRecords, list);
    return id;
  }

  static Future<void> updateCallRecord(
    String id, {
    int? duration,
    bool? answered,
  }) async {
    if (id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_kRecords) ?? <String>[];
    bool changed = false;
    for (int i = 0; i < list.length; i++) {
      final Map<String, dynamic>? map = _tryParse(list[i]);
      if (map == null) continue;
      if ((map['id'] ?? '').toString() != id) continue;
      if (duration != null) map['duration'] = duration;
      if (answered != null) map['answered'] = answered;
      list[i] = jsonEncode(map);
      changed = true;
      break;
    }
    if (changed) await prefs.setStringList(_kRecords, list);
  }

  static Future<List<CallRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_kRecords) ?? <String>[];
    final List<CallRecord> result = <CallRecord>[];
    for (final String raw in list) {
      Map<String, dynamic>? map = _tryParse(raw);
      if (map == null) {
        // 兼容最老的 "号码|时间戳|时长|未接" 格式
        final List<String> parts = raw.split('|');
        if (parts.length >= 4) {
          map = <String, dynamic>{
            'id': parts[1],
            'number': parts[0],
            'time': int.tryParse(parts[1]) ?? 0,
            'duration': int.tryParse(parts[2]) ?? 0,
            'answered': parts[3] != '1',
            'direction': 'out',
          };
        }
      }
      if (map == null) continue;
      result.add(CallRecord.fromMap(map));
    }
    return result;
  }

  static Future<void> clearRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kRecords, <String>[]);
  }

  static Map<String, dynamic>? _tryParse(String raw) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 兼容旧代码调用
  static Future<void> saveCallRecord(
    String number,
    int seconds,
    bool isMissed,
  ) async {
    final String id =
        await addCallRecord(number, direction: 'out', answered: !isMissed);
    await updateCallRecord(id, duration: seconds, answered: !isMissed);
  }

  // ======== 变声音调（微调） ========
  static Future<double> loadEffect(int index) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_kEffectPrefix$index') ?? 1.0;
  }

  static Future<void> saveEffect(int index, double pitch) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_kEffectPrefix$index', pitch);
  }

  static Future<List<double>> loadEffects() async {
    final List<double> values = <double>[];
    for (int i = 0; i < 4; i++) {
      values.add(await loadEffect(i));
    }
    return values;
  }

  static Future<void> saveEffects(List<double> values) async {
    for (int i = 0; i < values.length; i++) {
      await saveEffect(i, values[i]);
    }
  }

  static Future<int> loadSelectedEffect() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kSelectedEffect) ?? 0;
  }

  static Future<void> saveSelectedEffect(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSelectedEffect, index);
  }

  // ======== 格式化工具 ========
  static String formatDuration(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String formatRecordTime(int millis) {
    final DateTime dt = DateTime.fromMillisecondsSinceEpoch(millis);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(dt.year, dt.month, dt.day);
    final int diff = today.difference(day).inDays;
    String two(int v) => v.toString().padLeft(2, '0');
    if (diff <= 0) return '${two(dt.hour)}:${two(dt.minute)}';
    if (diff == 1) return '昨天';
    if (diff < 7) {
      const List<String> week = <String>[
        '星期一',
        '星期二',
        '星期三',
        '星期四',
        '星期五',
        '星期六',
        '星期日',
      ];
      return week[dt.weekday - 1];
    }
    return '${two(dt.month)}/${two(dt.day)}';
  }
}
