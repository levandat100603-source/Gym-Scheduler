import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../widgets/common_widgets.dart';

class MemberBookingsScreen extends StatefulWidget {
  const MemberBookingsScreen({super.key});

  @override
  State<MemberBookingsScreen> createState() => _MemberBookingsScreenState();
}

class _MemberBookingsScreenState extends State<MemberBookingsScreen> {
  static const int _pageSize = 6;

  bool loading = true;
  List<Map<String, dynamic>> classBookings = [];
  List<Map<String, dynamic>> trainerBookings = [];
  int classPage = 0;
  int trainerPage = 0;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      setState(() => loading = true);
      final res = await ApiClient.instance.dio.get('/user/history');
      final data = (res.data as Map).cast<String, dynamic>();
      final classes = (data['classes'] as List? ?? [])
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();
      final trainers = (data['trainers'] as List? ?? [])
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();

      setState(() {
        classBookings = classes;
        trainerBookings = trainers;
        classPage = 0;
        trainerPage = 0;
      });
    } catch (_) {
      setState(() {
        classBookings = [];
        trainerBookings = [];
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.amber.shade800;
    }
  }

  List<Map<String, dynamic>> _slice(List<Map<String, dynamic>> data, int page) {
    final start = page * _pageSize;
    if (start >= data.length) return [];
    final end = (start + _pageSize) > data.length ? data.length : (start + _pageSize);
    return data.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    final classPageItems = _slice(classBookings, classPage);
    final trainerPageItems = _slice(trainerBookings, trainerPage);
    final classPageCount = (classBookings.length / _pageSize).ceil();
    final trainerPageCount = (trainerBookings.length / _pageSize).ceil();

    return RefreshIndicator(
      onRefresh: fetch,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const SectionHeader(
            title: 'Lich dat cua toi',
            subtitle: 'Lich su lop hoc va trainer bookings',
          ),
          const SizedBox(height: 12),
          _bookingSection(
            title: 'Lop hoc',
            items: classPageItems,
            emptyTitle: 'Chua co lich dat lop hoc',
          ),
          if (classPageCount > 1)
            _pager(
              current: classPage,
              total: classPageCount,
              onPrev: () => setState(() => classPage -= 1),
              onNext: () => setState(() => classPage += 1),
            ),
          const SizedBox(height: 12),
          _bookingSection(
            title: 'Trainer',
            items: trainerPageItems,
            emptyTitle: 'Chua co lich dat trainer',
          ),
          if (trainerPageCount > 1)
            _pager(
              current: trainerPage,
              total: trainerPageCount,
              onPrev: () => setState(() => trainerPage -= 1),
              onNext: () => setState(() => trainerPage += 1),
            ),
        ],
      ),
    );
  }

  Widget _bookingSection({
    required String title,
    required List<Map<String, dynamic>> items,
    required String emptyTitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (items.isEmpty)
              EmptyState(icon: Icons.event_note_outlined, title: emptyTitle)
            else
              ...items.map((booking) {
                final status = (booking['status'] ?? 'pending').toString();
                final name = (booking['name'] ?? booking['class_name'] ?? booking['trainer_name'] ?? 'Booking').toString();
                final schedule = (booking['schedule_info'] ?? booking['schedule'] ?? '--').toString();

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(name),
                    subtitle: Text(schedule),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _pager({
    required int current,
    required int total,
    required VoidCallback onPrev,
    required VoidCallback onNext,
  }) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: current > 0 ? onPrev : null,
          child: const Text('Trang truoc'),
        ),
        const Spacer(),
        Text('Trang ${current + 1}/$total'),
        const Spacer(),
        OutlinedButton(
          onPressed: current < total - 1 ? onNext : null,
          child: const Text('Trang sau'),
        ),
      ],
    );
  }
}
