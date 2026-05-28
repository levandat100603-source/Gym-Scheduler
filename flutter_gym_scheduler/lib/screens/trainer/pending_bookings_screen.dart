import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../widgets/common_widgets.dart';

class PendingBookingsScreen extends StatefulWidget {
  const PendingBookingsScreen({super.key});

  @override
  State<PendingBookingsScreen> createState() => _PendingBookingsScreenState();
}

class _PendingBookingsScreenState extends State<PendingBookingsScreen> {
  bool loading = true;
  bool confirming = false;
  List<dynamic> pending = [];
  List<dynamic> rejected = [];
  List<dynamic> schedule = [];

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      setState(() => loading = true);
      final p = await ApiClient.instance.dio.get('/bookings/pending');
      final r = await ApiClient.instance.dio.get('/bookings/rejected');
      final s = await ApiClient.instance.dio.get('/bookings/trainer-schedule');
      pending = (p.data as List?) ?? [];
      rejected = (r.data as List?) ?? [];
      schedule = (s.data as List?) ?? [];
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _bookingCard(dynamic booking, {Color? accentColor}) {
    final status = (booking['status'] ?? '').toString();
    final statusLabel = status == 'rejected'
        ? 'Đã từ chối'
        : status == 'confirmed'
            ? 'Đã xác nhận'
            : 'Đang chờ';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    (booking['user_name'] ?? '').toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (accentColor != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: accentColor.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(color: accentColor, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
              ],
            ),
            Text((booking['user_email'] ?? '').toString()),
            const SizedBox(height: 6),
            Text((booking['schedule_info'] ?? '').toString()),
          ],
        ),
      ),
    );
  }

  Future<void> doAction(int id, String action) async {
    try {
      setState(() => confirming = true);
      await ApiClient.instance.dio.post('/bookings/confirm', data: {'booking_id': id, 'action': action});
      await fetchAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(action == 'confirm' ? 'Da xac nhan booking' : 'Da tu choi booking')));
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.response?.data?['message']?.toString() ?? 'Loi xu ly booking')));
    } finally {
      if (mounted) setState(() => confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: fetchAll,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const SectionHeader(title: 'Booking cho xu ly', subtitle: 'Trainer xac nhan / tu choi lich hen'),
          const SizedBox(height: 10),
          if (pending.isEmpty)
            const EmptyState(icon: Icons.check_circle_outline, title: 'Khong co lich cho xac nhan')
          else
            ...pending.map(
              (b) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((b['user_name'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text((b['user_email'] ?? '').toString()),
                      const SizedBox(height: 6),
                      Text((b['schedule_info'] ?? '').toString()),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: confirming ? null : () => doAction((b['id'] as num).toInt(), 'reject'),
                              icon: const Icon(Icons.close, color: Colors.red),
                              label: const Text('Tu choi', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: confirming ? null : () => doAction((b['id'] as num).toInt(), 'confirm'),
                              icon: const Icon(Icons.check),
                              label: const Text('Xac nhan'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),
          const SectionHeader(title: 'Lịch đã từ chối', subtitle: 'Các buổi booking trainer đã từ chối xử lý'),
          const SizedBox(height: 10),
          if (rejected.isEmpty)
            const EmptyState(icon: Icons.cancel_outlined, title: 'Chưa có lịch bị từ chối')
          else
            ...rejected.map((b) => _bookingCard(b, accentColor: Colors.red)),
          const SizedBox(height: 14),
          const Text('Lich da nhan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (schedule.isEmpty)
            const EmptyState(icon: Icons.calendar_today_outlined, title: 'Chua co lich day')
          else
            ...schedule.map(
              (s) => Card(
                child: ListTile(
                  leading: const Icon(Icons.event_available),
                  title: Text((s['schedule_info'] ?? '').toString()),
                  subtitle: Text('Hoc vien: ${(s['user_name'] ?? '').toString()}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
