import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../core/api_client.dart';
import '../../models/app_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common_widgets.dart';

class TrainersScreen extends StatefulWidget {
  const TrainersScreen({super.key});

  @override
  State<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends State<TrainersScreen> {
  bool loading = true;
  List<Trainer> trainers = [];
  List<Map<String, dynamic>> _bookingTargets = [];
  String _trainerSearchQuery = '';

  List<String> _scheduleFromAvailability(String availability) {
    final source = availability.trim();
    if (source.isEmpty) {
      return const ['T2 - 06:00', 'T3 - 18:00', 'T5 - 19:30'];
    }
    final chunks = source
        .split(RegExp(r'[,;\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (chunks.isEmpty) {
      return const ['T2 - 06:00', 'T3 - 18:00', 'T5 - 19:30'];
    }
    return chunks.take(6).toList();
  }

  Future<void> _showTrainerProfile(Trainer t) async {
    final schedule = _scheduleFromAvailability(t.availability);
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _avatar(t.imageUrl, t.id),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                            Text(t.spec, style: const TextStyle(color: Colors.black54)),
                            const SizedBox(height: 2),
                            Text('⭐ ${t.rating}  •  ${t.exp}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Giới thiệu HLV', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    '${t.name} có chuyên môn ${t.spec.toLowerCase()}, kinh nghiệm ${t.exp.toLowerCase()} và thường nhận lớp theo khung giờ linh hoạt.',
                    style: const TextStyle(color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  const Text('Lịch khả dụng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: schedule
                        .map(
                          (slot) => Chip(
                            backgroundColor: Colors.teal.withValues(alpha: 0.1),
                            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                            label: Text(slot),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${formatVnd(t.price)}/buổi',
                    style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _bookTrainer(t);
              },
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Đặt lịch'),
            ),
          ],
        );
      },
    );
  }

  Widget _avatar(String? url, dynamic id) {
    final value = _avatarUrl(url);
    // prefer per-trainer local cache (handled by FutureBuilder below)
    if (value.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.person));
    }

    // Use FutureBuilder to load cached base64 if present, else network image
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snap) {
        if (snap.hasData) {
          final prefs = snap.data!;
          final key = 'trainer_avatar_${id.toString()}';
          final base64Local = prefs.getString(key)?.trim() ?? '';
          if (base64Local.isNotEmpty) {
            try {
              final bytes = base64Decode(base64Local);
              return CircleAvatar(
                child: ClipOval(
                  child: Image.memory(
                    bytes,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person),
                  ),
                ),
              );
            } catch (_) {
              // fall back to network
            }
          }
        }
        return CircleAvatar(
          child: ClipOval(
            child: Image.network(
              value,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.person),
            ),
          ),
        );
      },
    );
  }

  String _avatarUrl(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return '';

    final baseUrl = ApiClient.instance.dio.options.baseUrl.replaceAll('/api', '');
    final baseUri = Uri.tryParse(baseUrl);
    final revision = context.read<AuthProvider>().avatarRevision;

    String appendRevision(String url) {
      if (revision <= 0) return url;
      final separator = url.contains('?') ? '&' : '?';
      return '$url${separator}v=$revision';
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      final rawUri = Uri.tryParse(raw);
      final isLocalHost = rawUri != null && (rawUri.host == '127.0.0.1' || rawUri.host == 'localhost' || rawUri.host == '10.0.2.2');
      if (isLocalHost && baseUri != null) {
        return appendRevision(rawUri.replace(
          scheme: baseUri.scheme,
          host: baseUri.host,
          port: baseUri.hasPort ? baseUri.port : null,
        ).toString());
      }
      return appendRevision(raw);
    }

    if (raw.startsWith('/')) {
      return appendRevision('$baseUrl$raw');
    }

    return appendRevision('$baseUrl/$raw');
  }

  List<Trainer> _filteredTrainers() {
    final query = _trainerSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return trainers;

    return trainers.where((trainer) {
      final name = trainer.name.toLowerCase();
      final price = formatVnd(trainer.price).toLowerCase();
      return name.contains(query) || price.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      setState(() => loading = true);
      final res = await ApiClient.instance.dio.get('/trainers');
      final list = (res.data as List).cast<dynamic>();
      setState(() => trainers = list.map((e) => Trainer.fromJson((e as Map).cast<String, dynamic>())).toList());
      // kick off background caching for trainer avatars
      for (final t in trainers) {
        _ensureTrainerCached(t);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _ensureTrainerCached(Trainer t) async {
    try {
      final id = t.id;
      if (id == null) return;
      final key = 'trainer_avatar_${id.toString()}';
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(key)?.trim() ?? '';
      if (existing.isNotEmpty) return;
      final raw = (t.imageUrl ?? '').trim();
      if (raw.isEmpty) return;

      final baseUrl = ApiClient.instance.dio.options.baseUrl.replaceAll('/api', '');
      String url;
      if (raw.startsWith('http://') || raw.startsWith('https://')) {
        url = raw;
      } else if (raw.startsWith('/')) {
        url = '$baseUrl$raw';
      } else {
        url = '$baseUrl/$raw';
      }

      // Add longer timeout for trainer image downloads
      final resp = await ApiClient.instance.dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      final bytes = resp.data;
      if (bytes == null || bytes.isEmpty) return;
      final encoded = base64Encode(bytes);
      await prefs.setString(key, encoded);
      if (mounted) setState(() {});
    } catch (e) {
      // silently ignore but log for debugging
      debugPrint('Failed to cache trainer avatar for ${t.id}: $e');
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
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Dong')),
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

  Future<void> _bookTrainer(Trainer t) async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final isAdmin = (auth.user?.role ?? '').toLowerCase() == 'admin';
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    final now = DateTime.now();
    final selectedDay = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);

    final shiftSlots = <String, List<String>>{
      'Sang': ['06:00', '07:30', '09:00', '10:30'],
      'Chieu': ['13:30', '15:00', '16:30'],
      'Toi': ['18:00', '19:30', '21:00'],
    };

    bool isPastSlot(String hhmm) {
      if (selectedDay != today) return false;
      final parts = hhmm.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final slot = DateTime(date.year, date.month, date.day, hour, minute);
      return slot.isBefore(now);
    }

    String selectedShift = 'Sang';
    String? selected;

    List<String> availableSlots(String shift) => shiftSlots[shift]!
        .where((slot) => !isPastSlot(slot))
        .toList();

    final initialSlots = availableSlots(selectedShift);
    if (initialSlots.isNotEmpty) {
      selected = initialSlots.first;
    }

    final picked = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chon ca va gio tap'),
        content: StatefulBuilder(
          builder: (context, setState) {
            final slots = availableSlots(selectedShift);
            if (selected != null && !slots.contains(selected)) {
              selected = slots.isNotEmpty ? slots.first : null;
            }

            return SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedShift,
                    decoration: const InputDecoration(labelText: 'Ca tap'),
                    items: shiftSlots.keys
                        .map((shift) => DropdownMenuItem(value: shift, child: Text(shift)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        selectedShift = v;
                        final next = availableSlots(selectedShift);
                        selected = next.isNotEmpty ? next.first : null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selected,
                    decoration: const InputDecoration(labelText: 'Gio tap'),
                    items: slots
                        .map((slot) => DropdownMenuItem(value: slot, child: Text(slot)))
                        .toList(),
                    onChanged: slots.isEmpty ? null : (v) => setState(() => selected = v),
                  ),
                  if (slots.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Khong con khung gio hop le trong ngay da chon'),
                    ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Dong')),
          ElevatedButton(
            onPressed: selected == null ? null : () => Navigator.pop(context, selected),
            child: const Text('Xac nhan'),
          ),
        ],
      ),
    );

    if (picked == null || !mounted) return;

    int userId = auth.user?.id ?? 0;
    bool bookedForMember = false;
    String? memberName;
    String? memberEmail;

    if (isAdmin) {
      final target = await _pickBookingTargetForAdmin();
      if (target == null) return;
      userId = (target['id'] as int?) ?? 0;
      bookedForMember = true;
      memberName = target['name']?.toString();
      memberEmail = target['email']?.toString();
    }

    final schedule = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} | $picked';

    try {
      final conflictRes = await ApiClient.instance.dio.post('/member/check-conflict', data: {
        'member_id': userId,
        'type': 'trainer',
        'item_id': t.id,
        'schedule': schedule,
      });
      if (conflictRes.data['conflict'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trung lich trainer')));
        return;
      }
    } on DioException {
      // Keep flow aligned with React Native app where conflict check failures do not block add-to-cart.
    }

    if (!mounted) return;
    await cart.addToCart(
          CartItem(
            id: t.id,
            name: 'HLV ${t.name}',
            price: t.price,
            type: 'trainer',
            schedule: schedule,
            bookedForMember: bookedForMember,
            memberId: bookedForMember ? userId : null,
            memberName: memberName,
            memberEmail: memberEmail,
          ),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAdmin && memberName != null
              ? 'Da them lich HLV ${t.name} cho $memberName vao gio hang'
              : 'Da them lich HLV ${t.name} vao gio hang',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isAdmin = (context.watch<AuthProvider>().user?.role ?? '').toLowerCase() == 'admin';
    final filteredTrainers = _filteredTrainers();
    if (loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: fetch,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const SectionHeader(title: 'Huấn luyện viên', subtitle: 'Chọn HLV và đặt lịch theo ca giờ'),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() => _trainerSearchQuery = value),
            decoration: InputDecoration(
              labelText: 'Tìm theo tên HLV hoặc giá',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _trainerSearchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () => setState(() => _trainerSearchQuery = ''),
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          if (trainers.isEmpty)
            const EmptyState(icon: Icons.person_off_outlined, title: 'Chưa có huấn luyện viên')
          else if (filteredTrainers.isEmpty)
            const EmptyState(icon: Icons.search_off_outlined, title: 'Không tìm thấy HLV phù hợp')
          else
            ...filteredTrainers.map((t) {
              final inCart = isAdmin ? false : cart.cart.any((i) => i.id == t.id && i.type == 'trainer');
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _avatar(t.imageUrl, t.id),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                                Text(t.spec, style: const TextStyle(color: Colors.blueGrey)),
                                const SizedBox(height: 2),
                                Text('⭐ ${t.rating} • ${t.exp}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text('${formatVnd(t.price)}/buổi', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w800, fontSize: 18)),
                                Text('Có sẵn: ${t.availability}', style: const TextStyle(color: Colors.blueGrey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showTrainerProfile(t),
                              icon: const Icon(Icons.info_outline),
                              label: const Text('Hồ sơ HLV'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: inCart ? null : () => _bookTrainer(t),
                              child: Text(inCart ? 'Đã chọn' : 'Chọn HLV này'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
