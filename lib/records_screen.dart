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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text('最近通话', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () {}, child: const Text('编辑')),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey),
                hintText: '搜索',
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
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
          ),
        ],
      ),
    );
  }
}