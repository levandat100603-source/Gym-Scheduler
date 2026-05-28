import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../models/app_models.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class TrainerClassesScreen extends StatefulWidget {
  const TrainerClassesScreen({super.key, required this.trainerId});

  final int trainerId;

  @override
  State<TrainerClassesScreen> createState() => _TrainerClassesScreenState();
}

class _TrainerClassesScreenState extends State<TrainerClassesScreen> {
  bool loading = true;
  List<GymClass> classes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      fetch();
    });
  }

  String _normalize(String value) => value.trim().toLowerCase();

  Future<void> fetch() async {
    try {
      setState(() => loading = true);
      final authUser = context.read<AuthProvider>().user;
      final trainerName = authUser?.name ?? '';
      final res = await ApiClient.instance.dio.get('/gym-classes');
      final data = (res.data as List).cast<dynamic>();
      final allClasses = data.map((e) => GymClass.fromJson((e as Map).cast<String, dynamic>())).toList();
      final normalizedTrainer = _normalize(trainerName);

      setState(() {
        // If logged-in user is an admin or not a trainer, show all classes.
        final role = (authUser?.role ?? '').toLowerCase();
        if (role != 'trainer') {
          classes = allClasses;
        } else {
          if (normalizedTrainer.isEmpty) {
            classes = [];
          } else {
            classes = allClasses.where((item) => _normalize(item.trainerName) == normalizedTrainer).toList();
          }
        }
      });
    } on DioException {
      if (!mounted) return;
      setState(() => classes = []);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _buildClassCard(GymClass item) {
    final remaining = item.capacity - item.registered;
    final full = remaining <= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                Chip(
                  label: Text(full ? 'Kín chỗ' : 'Còn $remaining chỗ'),
                  backgroundColor: full ? Colors.grey.shade600 : Colors.teal.shade700,
                  labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${item.days} • ${item.time} • ${item.duration} phút', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Địa điểm: ${item.location}', style: const TextStyle(color: Colors.black54)),
            Text('Đã đăng ký: ${item.registered}/${item.capacity}', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text('HLV phụ trách: ${item.trainerName}', style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    final trainerName = context.watch<AuthProvider>().user?.name ?? '';

    return RefreshIndicator(
      onRefresh: fetch,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const SectionHeader(
            title: 'Lớp của tôi',
            subtitle: 'Các lớp đang được gán cho HLV đăng nhập',
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('HLV hiện tại'),
              subtitle: Text(trainerName.isEmpty ? 'Chưa xác định' : trainerName),
            ),
          ),
          const SizedBox(height: 12),
          if (classes.isEmpty)
            const EmptyState(
              icon: Icons.class_outlined,
              title: 'Chưa có lớp được gán',
              subtitle: 'Khi admin gán lớp cho HLV này, lớp sẽ xuất hiện tại đây.',
            )
          else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Tổng số lớp: ${classes.length}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black54),
              ),
            ),
            ...classes.map(_buildClassCard),
          ],
        ],
      ),
    );
  }
}