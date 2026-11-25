import 'package:flutter/material.dart';

import 'app_fonts.dart';
import 'globals.dart';
import 'pressable.dart';

/// 图4 最近通话（可作为独立页面，也可嵌在拨号页 Tab 里）
class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: const RecentCallsView()),
    );
  }
}

class RecentCallsView extends StatefulWidget {
  const RecentCallsView({super.key});

  @override
  State<RecentCallsView> createState() => _RecentCallsViewState();
}

class _RecentCallsViewState extends State<RecentCallsView> {
  static const Color _blue = Color(0xFF0A84FF);
  static const Color _grey = Color(0xFF8E8E93);
  static const Color _red = Color(0xFFFF453A);

  List<CallRecord> _records = <CallRecord>[];
  int _filter = 0; // 0 所有通话 / 1 未接来电
  String _keyword = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final List<CallRecord> list = await Globals.loadRecords();
    if (!mounted) return;
    setState(() => _records = list);
  }

  List<CallRecord> get _visible {
    return _records.where((CallRecord r) {
      if (_filter == 1 && r.answered) return false;
      if (_keyword.isNotEmpty && !r.number.contains(_keyword)) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {},
                child: const Text(
                  '编辑',
                  style: TextStyle(color: _blue, fontSize: 16),
                ),
              ),
              const Spacer(),
              _buildSegmented(),
              const Spacer(),
              const SizedBox(width: 32),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            '最近通话',
            style: TextStyle(
              color: Colors.white,
              fontFamily: AppFonts.displayFamily,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildSearchBar(),
        const SizedBox(height: 6),
        Expanded(
          child: _visible.isEmpty
              ? const Center(
                  child: Text(
                    '暂无通话记录',
                    style: TextStyle(color: _grey, fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: _visible.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildRow(_visible[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSegmented() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _segItem('所有通话', 0),
          _segItem('未接来电', 1),
        ],
      ),
    );
  }

  Widget _segItem(String text, int value) {
    final bool active = _filter == value;
    return Pressable(
      onTap: () => setState(() => _filter = value),
      pressedScale: 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE5E5EA) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? const Color(0xFF1C1C1E) : Colors.white,
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.search, color: _grey, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (String v) => setState(() => _keyword = v),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: _blue,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: '搜索',
                  hintStyle: TextStyle(color: _grey, fontSize: 15),
                ),
              ),
            ),
            const Icon(Icons.mic_none, color: _grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(CallRecord record) {
    final bool missed = !record.answered;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3C),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Color(0xFFB0B0B5), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  record.number,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: missed ? _red : Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Icon(
                      record.direction == 'in'
                          ? Icons.call_received
                          : Icons.call_made,
                      color: _grey,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      missed
                          ? '未接通'
                          : '电话 · ${Globals.formatDuration(record.duration)}',
                      style: const TextStyle(color: _grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            Globals.formatRecordTime(record.time),
            style: const TextStyle(color: _grey, fontSize: 13),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.info_outline, color: _blue, size: 20),
        ],
      ),
    );
  }
}
