import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/api_client.dart';
import '../../widgets/common_widgets.dart';

class AdminAllInfoScreen extends StatefulWidget {
  const AdminAllInfoScreen({super.key});

  @override
  State<AdminAllInfoScreen> createState() => _AdminAllInfoScreenState();
}

class _AdminAllInfoScreenState extends State<AdminAllInfoScreen> {
  bool loading = true;
  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    fetch();
  }

  num _toNum(dynamic value, [num fallback = 0]) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? fallback;
    return fallback;
  }

  Future<void> fetch() async {
    try {
      setState(() => loading = true);
      final res = await ApiClient.instance.dio.get('/dashboard-stats');
      data = (res.data as Map).cast<String, dynamic>();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> reset() async {
    await ApiClient.instance.dio.post('/dashboard-reset');
    await fetch();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật dữ liệu dashboard')));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final current = (data['current_month'] as Map?)?.cast<String, dynamic>() ?? {};
    final monthly = (data['monthly_stats'] as List?)?.cast<dynamic>() ?? [];
    final revenue = _toNum(current['revenue']);
    final totalMembers = _toNum(current['total_members']);
    final newMembers = _toNum(current['new_members']);
    final target = _toNum(current['target'], 1);
    final progress = _toNum(current['progress']);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Thông tin hệ thống'),
        actions: [
          IconButton(
            onPressed: fetch,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetch,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tháng hiện tại', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _line('Doanh thu', formatVnd(revenue)),
                      _line('Hội viên mới', newMembers.toInt().toString()),
                      _line('Tổng hội viên', totalMembers.toInt().toString()),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: (progress / 100).clamp(0, 1).toDouble()),
                      const SizedBox(height: 8),
                      Text('Mục tiêu: ${formatVnd(target)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('12 tháng gần nhất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Tháng')),
                            DataColumn(label: Text('Doanh thu')),
                            DataColumn(label: Text('Hội viên mới')),
                          ],
                          rows: monthly.map((row) {
                            final item = (row as Map).cast<String, dynamic>();
                            return DataRow(
                              cells: [
                                DataCell(Text('Tháng ${item['month']}')),
                                DataCell(Text(formatVnd(_toNum(item['revenue'])))),
                                DataCell(Text(_toNum(item['new_members']).toInt().toString())),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset / cập nhật dữ liệu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87)),
        ],
      ),
    );
  }
}
