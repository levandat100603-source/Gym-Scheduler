import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool loading = true;
  bool resetting = false;
  bool updatingTarget = false;
  Map<String, dynamic> stats = {};

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  num _asNum(dynamic value, [num fallback = 0]) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? fallback;
    return fallback;
  }

  Future<void> fetchStats() async {
    try {
      setState(() => loading = true);
      final res = await ApiClient.instance.dio.get('/dashboard-stats');
      stats = (res.data as Map).cast<String, dynamic>();
    } on DioException {
      stats = {};
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> resetDashboard() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => resetting = true);
    try {
      await ApiClient.instance.dio.post('/dashboard-reset');
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Da reset thong ke dashboard')));
      await fetchStats();
    } on DioException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(e.response?.data?['message']?.toString() ?? 'Khong the reset dashboard')),
      );
    } finally {
      if (mounted) setState(() => resetting = false);
    }
  }

  Future<void> _promptUpdateTarget(num currentTarget) async {
    final controller = TextEditingController(text: currentTarget.toInt().toString());
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đặt lại KPI tháng'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Mục tiêu doanh thu (VND)',
            hintText: 'Ví dụ: 80000000',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Lưu')),
        ],
      ),
    );

    if (confirmed != true) return;

    final target = num.tryParse(controller.text.trim());
    if (target == null || target <= 0) {
      messenger.showSnackBar(const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ lớn hơn 0')));
      return;
    }

    setState(() => updatingTarget = true);
    try {
      await ApiClient.instance.dio.post('/dashboard-target', data: {
        'monthly_revenue_target': target,
      });
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Đã cập nhật KPI tháng')));
      await fetchStats();
    } on DioException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(e.response?.data?['message']?.toString() ?? 'Không thể cập nhật KPI tháng')),
      );
    } finally {
      if (mounted) setState(() => updatingTarget = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final current = (stats['current_month'] as Map?)?.cast<String, dynamic>() ?? {};
    final revenue = _asNum(current['revenue']);
    final users = _asNum(current['total_members']);
    final bookings = _asNum(stats['total_bookings'] ?? 0);
    final classes = _asNum(stats['total_classes'] ?? 0);
    final progress = _asNum(current['progress']);
    final targetRevenue = _asNum(current['target'], 50000000);
    final monthlyStats = (stats['monthly_stats'] as List?)?.cast<dynamic>() ?? [];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Tổng quan hệ thống'),
        actions: [
          IconButton(
            onPressed: fetchStats,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchStats,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _statCardCompact('Doanh thu', formatVnd(revenue), Icons.attach_money_outlined, Colors.teal),
                  _statCardCompact('Hội viên', users.toInt().toString(), Icons.groups_outlined, Colors.blue),
                  _statCardCompact('Booking', bookings.toInt().toString(), Icons.event_note_outlined, Colors.orange),
                  _statCardCompact('Lớp học', classes.toInt().toString(), Icons.fitness_center_outlined, Colors.indigo),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Mục tiêu tháng', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                          TextButton.icon(
                            onPressed: updatingTarget ? null : () => _promptUpdateTarget(targetRevenue),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: Text(updatingTarget ? 'Đang lưu...' : 'Đặt lại'),
                          ),
                        ],
                      ),
                      Text(
                        'KPI: ${formatVnd(targetRevenue)} / tháng',
                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (progress / 100).clamp(0, 1).toDouble(),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Text('${progress.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w600)),
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
                      const Text('12 tháng gần nhất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Tháng')),
                            DataColumn(label: Text('Doanh thu')),
                            DataColumn(label: Text('Hội viên mới')),
                          ],
                          rows: monthlyStats.map((row) {
                            final item = (row as Map).cast<String, dynamic>();
                            return DataRow(
                              cells: [
                                DataCell(Text('Tháng ${item['month']}')),
                                DataCell(Text(formatVnd(_asNum(item['revenue'])))),
                                DataCell(Text(_asNum(item['new_members']).toInt().toString())),
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
                onPressed: resetting ? null : resetDashboard,
                icon: const Icon(Icons.refresh),
                label: Text(resetting ? 'Đang cập nhật...' : 'Reset / cập nhật dữ liệu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCardCompact(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
