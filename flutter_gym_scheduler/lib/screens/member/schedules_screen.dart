import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../models/app_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common_widgets.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  bool loading = true;
  List<GymClass> classes = [];
  int _selectedWeekday = DateTime.now().weekday;
  Map<String, dynamic> _membership = {};
  Map<String, dynamic>? _upcoming;
  List<Map<String, dynamic>> _bookingTargets = [];
  String _classSearchQuery = '';

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      setState(() => loading = true);
      try {
        final res = await ApiClient.instance.dio.get('/gym-classes');
        final data = (res.data as List).cast<dynamic>();
        setState(() => classes = data.map((e) => GymClass.fromJson((e as Map).cast<String, dynamic>())).toList());
      } on DioException {
        final res = await ApiClient.instance.dio.get('/schedules');
        final data = (res.data as List).cast<dynamic>();
        setState(() => classes = data.map((e) => GymClass.fromJson((e as Map).cast<String, dynamic>())).toList());
      }

      try {
        final historyRes = await ApiClient.instance.dio.get('/user/history');
        final history = (historyRes.data as Map).cast<String, dynamic>();
        final bookings = (history['classes'] as List? ?? [])
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList();
        setState(() {
          _membership = (history['membership'] as Map?)?.cast<String, dynamic>() ?? {};
          _upcoming = bookings.isEmpty ? null : bookings.first;
        });
      } catch (_) {
        setState(() {
          _membership = {};
          _upcoming = null;
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<bool> _checkConflict(int itemId, int memberId) async {
    try {
      final res = await ApiClient.instance.dio.post('/member/check-conflict', data: {
        'member_id': memberId,
        'type': 'class',
        'item_id': itemId,
      });
      return res.data['conflict'] == true;
    } on DioException {
      return false;
    }
  }

  Future<void> _loadBookingTargetsForAdmin() async {
    if (_bookingTargets.isNotEmpty) return;
    final currentUserId = context.read<AuthProvider>().user?.id;

    try {
      final res = await ApiClient.instance.dio.get('/admin/data');
      final data = (res.data as Map).cast<String, dynamic>();
      final byId = <int, Map<String, dynamic>>{};

      void collect(dynamic list) {
        if (list is! List) return;
        for (final raw in list) {
          final item = (raw as Map).cast<String, dynamic>();
          final id = (item['id'] as num?)?.toInt() ?? int.tryParse((item['id'] ?? '').toString()) ?? 0;
          if (id <= 0) continue;
          if (currentUserId != null && id == currentUserId) continue;
          final name = (item['name'] ?? '').toString().trim();
          final email = (item['email'] ?? '').toString().trim();
          byId[id] = {
            'id': id,
            'name': name.isEmpty ? 'Khách #$id' : name,
            'email': email,
          };
        }
      }

      collect(data['members']);
      collect(data['available_users']);

      _bookingTargets = byId.values.toList()
        ..sort((a, b) => (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
    } on DioException {
      _bookingTargets = [];
    }
  }

  Future<Map<String, dynamic>?> _pickBookingTargetForAdmin() async {
    await _loadBookingTargetsForAdmin();
    if (!mounted) return null;
    if (_bookingTargets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Khong co khach de dat lich')));
      return null;
    }

    int selectedId = (_bookingTargets.first['id'] as int?) ?? 0;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Chon khach dat lich'),
              content: DropdownButtonFormField<int>(
                initialValue: selectedId,
                decoration: const InputDecoration(labelText: 'Khach hang'),
                isExpanded: true,
                items: _bookingTargets.map((target) {
                  final targetId = target['id'] as int;
                  final targetName = (target['name'] ?? '').toString();
                  final targetEmail = (target['email'] ?? '').toString();
                  final label = targetEmail.isEmpty ? targetName : '$targetName - $targetEmail';
                  return DropdownMenuItem<int>(
                    value: targetId,
                    child: Text(label, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() => selectedId = value);
                },
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Huy')),
                ElevatedButton(
                  onPressed: () {
                    final picked = _bookingTargets.firstWhere(
                      (target) => (target['id'] as int?) == selectedId,
                      orElse: () => _bookingTargets.first,
                    );
                    Navigator.pop(dialogContext, picked);
                  },
                  child: const Text('Xac nhan'),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  String _weekdayLabel(int weekday) {
    const labels = <int, String>{1: 'T2', 2: 'T3', 3: 'T4', 4: 'T5', 5: 'T6', 6: 'T7', 7: 'CN'};
    return labels[weekday] ?? 'T?';
  }

  DateTime _nextOccurrenceForWeekday(int weekday, {DateTime? from}) {
    final base = from ?? DateTime.now();
    final today = DateTime(base.year, base.month, base.day);
    final daysAhead = (weekday - today.weekday) % 7;
    return today.add(Duration(days: daysAhead));
  }

  String _formatShortDate(DateTime date) => '${date.day}/${date.month}';

  String _classDayDisplay(GymClass item) {
    final todayWeekday = _selectedWeekday;
    final date = _nextOccurrenceForWeekday(todayWeekday);
    return '${_weekdayLabel(todayWeekday)} ${_formatShortDate(date)}';
  }

  bool _isClassInDay(GymClass item, int weekday) {
    final normalized = item.days.toLowerCase();

    DateTime? parseClassDate(String raw) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return null;
      final iso = DateTime.tryParse(trimmed);
      if (iso != null) return iso;
      try {
        return DateFormat('dd-MM-yyyy').parseStrict(trimmed);
      } catch (_) {
        return null;
      }
    }

    final exactDate = parseClassDate(item.days);
    if (exactDate != null) {
      return exactDate.weekday == weekday;
    }

    bool matchesVietnameseDay(int dayToken) {
      if (normalized.contains('thứ $dayToken') || normalized.contains('thu $dayToken') || normalized.contains('th $dayToken')) {
        return true;
      }
      final compact = normalized.replaceAll(RegExp(r'\s+'), '');
      if (compact.contains('t$dayToken') || compact.contains('th$dayToken')) {
        return true;
      }
      final rangeMatch = RegExp(r'(\d)\s*-\s*(\d)').firstMatch(normalized);
      if (rangeMatch == null) return false;
      final start = int.tryParse(rangeMatch.group(1) ?? '');
      final end = int.tryParse(rangeMatch.group(2) ?? '');
      if (start == null || end == null) return false;
      final currentToken = weekday + 1;
      return currentToken >= start && currentToken <= end;
    }

    if (weekday == 7) {
      return normalized.contains('cn') || normalized.contains('chu nhat') || normalized.contains('chủ nhật');
    }
    return matchesVietnameseDay(weekday + 1);
  }

  List<GymClass> _filteredClasses() {
    final query = _classSearchQuery.trim().toLowerCase();
    final base = classes.where((c) => _isClassInDay(c, _selectedWeekday));
    if (query.isEmpty) return base.toList();

    return base.where((item) {
      final trainerName = item.trainerName.toLowerCase();
      final className = item.name.toLowerCase();
      final days = item.days.toLowerCase();
      return trainerName.contains(query) || className.contains(query) || days.contains(query);
    }).toList();
  }

  Widget _capacityChip(GymClass item) {
    final remaining = item.capacity - item.registered;
    if (remaining <= 0) {
      return Chip(
        label: const Text('Kín chỗ'),
        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        backgroundColor: Colors.grey.shade600,
      );
    }
    if (remaining <= 3) {
      return Chip(
        label: Text('Sắp đầy (Còn $remaining chỗ)'),
        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        backgroundColor: Colors.orange.shade700,
      );
    }
    return Chip(
      label: const Text('Còn trống'),
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      backgroundColor: Colors.green.shade700,
    );
  }

  int _daysRemaining() {
    final expiryRaw = _membership['expiry']?.toString();
    if (expiryRaw == null || expiryRaw.isEmpty) return 0;
    final expiry = DateTime.tryParse(expiryRaw);
    if (expiry == null) return 0;
    final now = DateTime.now();
    final left = expiry.difference(DateTime(now.year, now.month, now.day)).inDays;
    return left < 0 ? 0 : left;
  }

  void _showCheckinCode(int userId) {
    final code = 'FZ-$userId-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mã Check-in'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2_rounded, size: 84, color: Colors.teal),
            const SizedBox(height: 10),
            const Text('Đưa mã này cho lễ tân để check-in'),
            const SizedBox(height: 8),
            SelectableText(code, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final cart = context.watch<CartProvider>();
    final isAdmin = (user?.role ?? '').toLowerCase() == 'admin';
    final filteredClasses = _filteredClasses();

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final daysLeft = _daysRemaining();
    final membershipName = (_membership['package'] ?? 'Chưa đăng ký').toString();
    final progress = daysLeft <= 0 ? 0.0 : (daysLeft / 90).clamp(0, 1).toDouble();

    return RefreshIndicator(
      onRefresh: fetch,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lớp sắp tới của bạn', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(
                          _upcoming == null
                              ? 'Bạn chưa chọn lịch tập nào. Hãy khám phá các lớp ngay!'
                              : '${_upcoming!['name'] ?? 'Lớp tập'} • ${_upcoming!['schedule_info'] ?? '--'}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 132,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCheckinCode(user?.id ?? 0),
                      icon: const Icon(Icons.qr_code_2_rounded),
                      label: const Text('Check-in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$membershipName • Còn $daysLeft ngày', style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress, minHeight: 8, borderRadius: BorderRadius.circular(6)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const SectionHeader(
            title: 'Lịch lớp học',
            subtitle: 'Lên lịch theo từng ngày trong tuần',
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() => _classSearchQuery = value),
            decoration: InputDecoration(
              labelText: 'Tìm theo tên HLV hoặc ngày',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _classSearchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () => setState(() => _classSearchQuery = ''),
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final day = i + 1;
                final selected = _selectedWeekday == day;
                return ChoiceChip(
                  label: Text(_weekdayLabel(day)),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedWeekday = day),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (classes.isEmpty)
            const EmptyState(icon: Icons.event_busy_outlined, title: 'Chưa có lớp học nào')
          else if (filteredClasses.isEmpty)
            EmptyState(
              icon: Icons.calendar_today_outlined,
              title: 'Chưa có lớp cho ${_weekdayLabel(_selectedWeekday)}',
              subtitle: 'Hãy thử chuyển sang ngày khác hoặc quay lại sau.',
            )
          else
            ...filteredClasses.map(
              (item) {
                final inCart = cart.cart.any((e) => e.id == item.id && e.type == 'class');
                final canDisableByInCart = !isAdmin;
                final full = item.registered >= item.capacity;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                            _capacityChip(item),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('HLV: ${item.trainerName}', style: const TextStyle(color: Colors.black54)),
                        Text(
                          '${_classDayDisplay(item)} | ${item.time} (${item.duration} phút)',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        Text('Địa điểm: ${item.location}', style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              full ? 'Kín chỗ' : '${formatVnd(item.price)}/buổi',
                              style: TextStyle(
                                color: full ? Colors.grey : Colors.teal.shade700,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 130,
                              child: ElevatedButton.icon(
                                onPressed: (canDisableByInCart && inCart) || full
                                    ? null
                                    : () async {
                                        int memberId = user?.id ?? 0;
                                        bool bookedForMember = false;
                                        String? memberName;
                                        String? memberEmail;

                                        if (isAdmin) {
                                          final target = await _pickBookingTargetForAdmin();
                                          if (target == null) return;
                                          memberId = (target['id'] as int?) ?? 0;
                                          bookedForMember = true;
                                          memberName = target['name']?.toString();
                                          memberEmail = target['email']?.toString();
                                        }

                                        final conflict = await _checkConflict(item.id, memberId);
                                        if (conflict) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                isAdmin
                                                    ? 'Khach da co lich lop nay roi'
                                                    : 'Bạn đã có lịch lớp này rồi',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        await cart.addToCart(
                                          CartItem(
                                            id: item.id,
                                            name: item.name,
                                            price: item.price,
                                            type: 'class',
                                            schedule: '${item.days} | ${item.time}',
                                            schedules: ['${item.days} | ${item.time}'],
                                            quantity: 1,
                                            bookedForMember: bookedForMember,
                                            memberId: bookedForMember ? memberId : null,
                                            memberName: memberName,
                                            memberEmail: memberEmail,
                                          ),
                                        );
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isAdmin && memberName != null
                                                  ? 'Da them ${item.name} cho $memberName vao gio hang'
                                                  : 'Đã thêm ${item.name} vào giỏ hàng',
                                            ),
                                          ),
                                        );
                                      },
                                icon: Icon(inCart ? Icons.check : Icons.add_shopping_cart),
                                label: Text((canDisableByInCart && inCart) ? 'Đã thêm' : 'Thêm giỏ'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            )
        ],
      ),
    );
  }
}
