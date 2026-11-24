import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});
  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<String> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _records = prefs.getStringList('call_records') ?? []; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('最近通话', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [TextButton(onPressed: () {}, child: const Text('编辑'))],
      ),
      body: ListView.builder(
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final parts = _records[index].split('|');
          if (parts.length < 4) return const SizedBox();
          String number = parts[0];
          int timestamp = int.parse(parts[1]);
          int duration = int.parse(parts[2]);
          bool isMissed = parts[3] == '1';
          
          DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          String timeStr = DateFormat('MM-dd HH:mm').format(date);
          String durationStr = duration == 0 ? "未接通" : "${duration ~/ 60}分${duration % 60}秒";

          return ListTile(
            leading: Icon(isMissed ? Icons.call_missed : Icons.call_made, color: isMissed ? Colors.red : Colors.grey),
            title: Text(number, style: TextStyle(color: isMissed ? Colors.red : null, fontWeight: FontWeight.w500)),
            subtitle: Text(isMissed ? '未接通' : '已接通', style: const TextStyle(fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(timeStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (!isMissed) Text(durationStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}