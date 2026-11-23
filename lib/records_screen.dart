import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      appBar: AppBar(title: const Text('最近通话')),
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
          String timeStr = "${date.month}-${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
          String durationStr = duration == 0 ? "未接通" : "${duration ~/ 60}分${duration % 60}秒";

          return ListTile(
            leading: Icon(isMissed ? Icons.call_missed : Icons.call_made, color: isMissed ? Colors.red : Colors.blue),
            title: Text(number, style: TextStyle(color: isMissed ? Colors.red : null, fontWeight: FontWeight.bold)),
            subtitle: Text(timeStr),
            trailing: Text(durationStr, style: const TextStyle(color: Colors.grey)),
          );
        },
      ),
    );
  }
}
