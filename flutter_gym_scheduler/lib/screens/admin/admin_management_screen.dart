import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key, this.initialTab});

  final String? initialTab;

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> with SingleTickerProviderStateMixin {
  late final TabController _controller;
  bool loading = true;
  int _currentTabIndex = 0;
  String _classSearchQuery = '';
  String _trainerSearchQuery = '';
  String _scheduleSearchQuery = '';
  String _memberSearchQuery = '';
  String _bookingSearchQuery = '';

  List<dynamic> classes = [];
  List<dynamic> trainers = [];
  List<dynamic> packages = [];
  List<dynamic> members = [];
  List<dynamic> availableUsers = [];
  List<dynamic> bookings = [];
  List<dynamic> trainerSchedules = [];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 6, vsync: this, initialIndex: _initialTabIndex());
    _controller.addListener(() {
      if (!mounted) return;
      setState(() => _currentTabIndex = _controller.index);
    });
    fetchAll();
  }

  Future<void> _safePop(BuildContext ctx) async {
    try {
      // ensure focus and keyboard are hidden before popping
      FocusManager.instance.primaryFocus?.unfocus();
      await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      await Future<void>.delayed(const Duration(milliseconds: 60));
    } catch (_) {}
    if (ctx.mounted) Navigator.of(ctx).pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _initialTabIndex() {
    switch (widget.initialTab?.toLowerCase().trim() ?? '') {
      case 'trainers':
        return 1;
      case 'working_hours':
      case 'trainer_schedules':
        return 2;
      case 'packages':
        return 3;
      case 'members':
        return 4;
      case 'bookings':
        return 5;
      default:
        return 0;
    }
  }

  String get _screenTitle {
    switch (_currentTabIndex) {
      case 1:
        return 'Quản lý huấn luyện viên';
      case 2:
        return 'Lịch làm huấn luyện viên';
      case 3:
        return 'Quản lý gói tập';
      case 4:
        return 'Quản lý thành viên';
      case 5:
        return 'Xác nhận booking';
      default:
        return 'Quản lý lớp tập';
    }
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  TimeOfDay _parseTimeOfDay(String value) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
    if (match == null) return const TimeOfDay(hour: 6, minute: 0);
    final hour = int.tryParse(match.group(1) ?? '') ?? 6;
    final minute = int.tryParse(match.group(2) ?? '') ?? 0;
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }

  DateTime? _parseClassDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    for (final format in ['Y-m-d', 'd/m/Y', 'd-m-Y', 'd.m.Y']) {
      try {
        return DateTime.parse(
          format == 'Y-m-d'
              ? value
              : (() {
                  final parts = value.split(RegExp(r'[./-]'));
                  if (parts.length != 3) return value;
                  if (format == 'd/m/Y' || format == 'd-m-Y' || format == 'd.m.Y') {
                    final day = int.parse(parts[0]);
                    final month = int.parse(parts[1]);
                    final year = int.parse(parts[2]);
                    return DateTime(year, month, day).toIso8601String();
                  }
                  return value;
                })(),
        ).toLocal();
      } catch (_) {}
    }

    final isoMatch = RegExp(r'(\d{4}-\d{2}-\d{2})').firstMatch(value);
    if (isoMatch != null) {
      try {
        return DateTime.parse(isoMatch.group(1)!).toLocal();
      } catch (_) {}
    }

    return null;
  }

  String _formatClassDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  List<String> _upcomingTimeSlots({String? initialValue, DateTime? forDate}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // If forDate is provided and is not today, allow earlier time slots (use permissive start).
    // Otherwise (for today or unspecified), start from the next half-hour after now.
    final bool isToday = forDate == null ? true : (DateTime(forDate.year, forDate.month, forDate.day).compareTo(today) == 0);

    final startMinutes = now.hour * 60 + now.minute;
    final roundedNowStart = ((startMinutes + 29) ~/ 30) * 30;

    // For future dates allow starting from 06:00 by default to avoid midnight slots.
    const int defaultMorning = 6 * 60;

    final roundedStart = isToday ? roundedNowStart : defaultMorning;

    final initialMinutes = initialValue == null || initialValue.trim().isEmpty
        ? roundedStart
        : (_parseTimeOfDay(initialValue).hour * 60) + _parseTimeOfDay(initialValue).minute;
    final firstSlot = initialMinutes < roundedStart ? roundedStart : initialMinutes;

    final slots = <String>[];
    for (var minutes = firstSlot; minutes < 24 * 60; minutes += 30) {
      final hour = minutes ~/ 60;
      final minute = minutes % 60;
      slots.add('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    }
    return slots;
  }

  String _formatCurrency(dynamic value) {
    return formatVnd(_toDouble(value));
  }

  String _fieldLabel(String key, String type) {
    const classLabels = {
      'name': 'Tên lớp',
      'price': 'Học phí',
      'time': 'Giờ học',
      'duration': 'Thời lượng',
      'location': 'Địa điểm',
      'trainer_name': 'Tên HLV',
      'days': 'Ngày học',
      'capacity': 'Số lượng',
    };

    const packageLabels = {
      'name': 'Tên gói',
      'price': 'Giá',
      'duration': 'Thời hạn (tháng)',
      'benefits_text': 'Quyền lợi',
      'old_price': 'Giá cũ',
    };

    const trainerLabels = {
      'name': 'Họ tên',
      'email': 'Email',
      'phone': 'Số điện thoại',
      'spec': 'Chuyên môn',
      'price': 'Học phí',
    };

    const memberLabels = {
      'name': 'Họ tên',
      'email': 'Email',
      'phone': 'Số điện thoại',
      'pack': 'Gói tập',
      'start': 'Ngày bắt đầu',
      'duration': 'Thời hạn',
      'status': 'Trạng thái',
    };

    final labelsByType = {
      'classes': classLabels,
      'packages': packageLabels,
      'trainers': trainerLabels,
      'members': memberLabels,
    };

    return labelsByType[type]?[key] ?? key.replaceAll('_', ' ');
  }

  Future<String?> _pickTrainerName(BuildContext context, List<dynamic> trainerList, {String? initialValue}) async {
    String query = '';
    String? selected = initialValue?.trim().isNotEmpty == true ? initialValue!.trim() : null;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final filtered = trainerList.where((raw) {
              final trainer = (raw as Map).cast<String, dynamic>();
              final name = (trainer['name'] ?? '').toString();
              final email = (trainer['email'] ?? '').toString();
              final spec = (trainer['spec'] ?? '').toString();
              final haystack = '$name $email $spec'.toLowerCase();
              return query.trim().isEmpty || haystack.contains(query.trim().toLowerCase());
            }).toList();

            return AlertDialog(
              title: const Text('Chọn HLV'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Tìm theo tên HLV',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => setDialogState(() => query = value),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final trainer = (filtered[index] as Map).cast<String, dynamic>();
                          final name = (trainer['name'] ?? '').toString();
                          final email = (trainer['email'] ?? '').toString();
                          final spec = (trainer['spec'] ?? '').toString();
                          final subtitle = [if (email.isNotEmpty) email, if (spec.isNotEmpty) spec].join(' • ');
                          final isSelected = selected == name;
                          return ListTile(
                            title: Text(name.isEmpty ? 'Không có tên' : name),
                            subtitle: subtitle.isEmpty ? null : Text(subtitle),
                            trailing: isSelected ? const Icon(Icons.check, color: Colors.teal) : null,
                            onTap: () {
                              selected = name;
                              Navigator.of(dialogContext).pop(selected);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () async { await _safePop(dialogContext); }, child: const Text('Hủy')),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _pickUpcomingTime(BuildContext context, {String? initialValue, DateTime? forDate}) async {
    final slots = _upcomingTimeSlots(initialValue: initialValue, forDate: forDate);
    if (slots.isEmpty) return null;

    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: slots.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final slot = slots[index];
              return ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(slot),
                onTap: () => Navigator.of(sheetContext).pop(slot),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> fetchAll() async {
    try {
      setState(() => loading = true);
      final res = await ApiClient.instance.dio.get('/admin/data');
      final data = (res.data as Map).cast<String, dynamic>();

      classes = (data['classes'] as List?) ?? [];
      trainers = (data['trainers'] as List?) ?? [];
      packages = (data['packages'] as List?) ?? [];
      members = (data['members'] as List?) ?? [];
      availableUsers = (data['available_users'] as List?) ?? [];

      final bookingsRes = await ApiClient.instance.dio.get('/admin/bookings');
      bookings = (bookingsRes.data as List?) ?? [];

      final workingHoursByTrainer = (data['working_hours'] as Map?)?.cast<String, dynamic>() ?? {};
      trainerSchedules = trainers.map((e) {
        final trainer = (e as Map).cast<String, dynamic>();
        final trainerName = (trainer['name'] ?? '').toString();
        final trainerUserId = trainer['user_id']?.toString() ?? trainer['id']?.toString() ?? '';
        final workingHours = (trainer['working_hours'] as List?)?.cast<dynamic>() ??
            (workingHoursByTrainer[trainerUserId] as List?)?.cast<dynamic>() ??
            [];
        final relatedBookings = bookings
            .where((b) => ((b as Map)['schedule_info'] ?? '').toString().contains(trainerName))
            .cast<Map>()
            .map((b) => (b['schedule_info'] ?? '').toString())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList();

        final formattedHours = workingHours.map((hourRaw) {
          final hour = (hourRaw as Map).cast<String, dynamic>();
          const dayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
          final dayIndex = _toInt(hour['day_of_week']);
          final dayLabel = dayIndex >= 0 && dayIndex < dayNames.length ? dayNames[dayIndex] : 'Ngày ${dayIndex + 1}';
          final start = (hour['start_time'] ?? '').toString();
          final end = (hour['end_time'] ?? '').toString();
          final active = hour['is_active'] == true || hour['is_active'] == 1;
          return '$dayLabel: ${active ? '$start - $end' : 'Off'}';
        }).toList();

        return {
          'trainer_id': trainer['id'],
          'trainer_user_id': trainer['user_id'],
          'trainer_name': trainerName,
          'working_hours': formattedHours,
          'booked_slots': relatedBookings,
        };
      }).toList();

      if (mounted) {
        setState(() {});
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> deleteItem(String type, dynamic id) async {
    try {
      await ApiClient.instance.dio.post('/admin/delete', data: {'type': type, 'id': id});
      await fetchAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa thành công')));
    } on DioException catch (e) {
      _handleApiError(e, fallbackMessage: 'Xóa thất bại');
    }
  }

  Future<void> confirmBooking(int id, String action) async {
    try {
      await ApiClient.instance.dio.post('/bookings/confirm', data: {'booking_id': id, 'action': action});
      await fetchAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(action == 'confirm' ? 'Đã xác nhận lịch' : 'Đã từ chối lịch')),
      );
    } on DioException catch (e) {
      _handleApiError(e, fallbackMessage: 'Lỗi xử lý booking');
    }
  }

  Future<void> _showTrainerScheduleDetails(Map<String, dynamic> trainer) async {
    final trainerId = _toInt(trainer['trainer_id']);
    if (trainerId <= 0) return;

    final messenger = ScaffoldMessenger.of(context);
    List<dynamic> workingHours = [];
    List<dynamic> weeklyBookings = [];
    Map<String, dynamic> trainerInfo = trainer;

    try {
      final res = await ApiClient.instance.dio.get('/admin/trainer-schedules/$trainerId');
      final data = (res.data as Map).cast<String, dynamic>();
      trainerInfo = (data['trainer'] as Map?)?.cast<String, dynamic>() ?? trainerInfo;
      workingHours = (data['working_hours'] as List?) ?? [];
      weeklyBookings = (data['weekly_bookings'] as List?) ?? [];
    } on DioException catch (e) {
      _handleApiError(e, fallbackMessage: 'Không thể tải chi tiết HLV');
      return;
    }

    if (!mounted) return;

    final dayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];

    String formatHour(dynamic raw) {
      final item = (raw as Map).cast<String, dynamic>();
      final dayIndex = _toInt(item['day_of_week']);
      final dayLabel = dayIndex >= 0 && dayIndex < dayNames.length ? dayNames[dayIndex] : 'Ngày ${dayIndex + 1}';
      final start = (item['start_time'] ?? '').toString();
      final end = (item['end_time'] ?? '').toString();
      final active = item['is_active'] == true || item['is_active'] == 1;
      return '$dayLabel: ${active ? '$start - $end' : 'Off'}';
    }

    Widget bookingCard(Map<String, dynamic> booking) {
      final scheduleInfo = (booking['schedule_info'] ?? '').toString();
      final userName = (booking['user_name'] ?? '').toString();
      final userEmail = (booking['user_email'] ?? '').toString();
      final userPhone = (booking['user_phone'] ?? '').toString();
      final status = (booking['status'] ?? '').toString();

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(scheduleInfo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 3),
              Text('Khách: $userName', style: const TextStyle(color: Colors.black87, fontSize: 11)),
              if (userEmail.isNotEmpty)
                Text('Email: $userEmail', style: const TextStyle(fontSize: 10, color: Colors.black54)),
              if (userPhone.isNotEmpty)
                Text('SĐT: $userPhone', style: const TextStyle(fontSize: 10, color: Colors.black54)),
              if (status.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text('Trạng thái: $status', style: const TextStyle(fontSize: 10, color: Colors.teal)),
              ],
              if ((booking['schedule_date'] ?? '').toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    'Ngày: ${booking['schedule_date']}',
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    var showAllWeeklyBookings = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setSheetState) {
            final visibleWeeklyBookings = showAllWeeklyBookings ? weeklyBookings : weeklyBookings.take(3).toList();

            return AlertDialog(
              title: Text((trainerInfo['name'] ?? '').toString()),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Chi tiết lịch làm và booking trong tuần',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 10),
                      const Text('Khung giờ làm việc', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      if (workingHours.isEmpty)
                        const Text('Chưa cập nhật', style: TextStyle(color: Colors.black54, fontSize: 12))
                      else
                        ...workingHours.map(
                          (hour) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontSize: 12)),
                                Expanded(child: Text(formatHour(hour), style: const TextStyle(fontSize: 12))),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        'Booking trong tuần (${weeklyBookings.length})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      if (weeklyBookings.isEmpty)
                        const Text('Chưa có booking trong tuần này', style: TextStyle(color: Colors.black54, fontSize: 12))
                      else ...[
                        ...visibleWeeklyBookings.map((booking) => bookingCard((booking as Map).cast<String, dynamic>())),
                        if (weeklyBookings.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: TextButton(
                              onPressed: () => setSheetState(() => showAllWeeklyBookings = !showAllWeeklyBookings),
                              child: Text(showAllWeeklyBookings ? 'Thu gọn' : 'Xem thêm'),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async { await _safePop(dialogContext); },
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> openCrudDialog(String type, {Map<String, dynamic>? item}) async {
    if (!mounted) return;

    if (type == 'trainers') {
      await _openTrainerCrudSheet(item: item);
      return;
    }

    final formKey = GlobalKey<FormState>();
    final controllers = <String, TextEditingController>{};

    String titleText = 'Quản lý ' + (type == 'classes' ? 'lớp tập' : type == 'trainers' ? 'huấn luyện viên' : type == 'packages' ? 'gói tập' : 'thành viên');

    // helper to get initial value
    String init(String k) => item == null ? '' : (item[k] ?? '').toString();

    void ensureCtrl(String key) {
      controllers.putIfAbsent(key, () => TextEditingController(text: init(key)));
    }

    // fields per type
    if (type == 'classes') {
      for (final k in ['name', 'price', 'time', 'duration', 'location', 'trainer_name', 'days', 'capacity']) ensureCtrl(k);
    } else if (type == 'packages') {
      for (final k in ['name', 'price', 'duration', 'benefits_text', 'old_price']) ensureCtrl(k);
    } else if (type == 'trainers') {
      for (final k in ['name', 'email', 'phone', 'spec', 'price']) ensureCtrl(k);
    } else if (type == 'members') {
      for (final k in ['name', 'email', 'phone', 'pack', 'start', 'duration', 'status']) ensureCtrl(k);
    } else {
      ensureCtrl('name');
    }

    DateTime? selectedClassDate = _parseClassDate(init('days'));
    if (selectedClassDate == null && item == null && type == 'classes') {
      selectedClassDate = DateTime.now();
    }
    String classDateText = selectedClassDate == null ? '' : _formatClassDate(selectedClassDate);
    bool hasTriedSubmit = false;
    String? classDateError;
    String? timeError;
    String? trainerError;
    if (type == 'classes') {
      final timeText = init('time').trim().isNotEmpty ? init('time').trim() : '06:00';
      controllers['time']?.text = timeText;
      controllers['days']?.text = selectedClassDate == null ? '' : selectedClassDate.toIso8601String().split('T').first;
      controllers['trainer_name']?.text = init('trainer_name');
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (dialogContext, setDialogState) {
          XFile? pickedImage;
          bool removeImage = false;

          Widget imageSection() {
            final imageUrl = item == null ? null : (item['image_url'] ?? item['image'] ?? '').toString();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty && !removeImage)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(imageUrl, width: 72, height: 72, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Ảnh hiện tại')),
                        Checkbox(value: removeImage, onChanged: (v) => setDialogState(() => removeImage = v ?? false)),
                      ],
                    ),
                  ),
                if (pickedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [Image.file(File(pickedImage!.path), width: 72, height: 72, fit: BoxFit.cover), const SizedBox(width: 8), Expanded(child: Text(pickedImage!.name))]),
                  ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final img = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
                        if (img != null) setDialogState(() => pickedImage = img);
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Chọn ảnh'),
                    ),
                    const SizedBox(width: 8),
                    if (pickedImage != null)
                      TextButton(onPressed: () => setDialogState(() => pickedImage = null), child: const Text('Bỏ chọn'))
                  ],
                ),
              ],
            );
          }

          return AlertDialog(
            title: Text(titleText),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: hasTriedSubmit ? AutovalidateMode.always : AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (type == 'trainers') imageSection(),
                    if (type == 'classes') ...[
                      TextFormField(
                        controller: controllers['name'],
                        decoration: const InputDecoration(labelText: 'Tên lớp'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập tên lớp' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['price'],
                        decoration: const InputDecoration(labelText: 'Học phí'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập học phí';
                          }
                          if (num.tryParse(value.replaceAll(',', '')) == null) {
                            return 'Nhập số hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['time'],
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Giờ học',
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        onTap: () async {
                          final picked = await _pickUpcomingTime(
                            context,
                            initialValue: controllers['time']!.text,
                            forDate: selectedClassDate,
                          );
                          if (picked != null && picked.isNotEmpty) {
                            setDialogState(() {
                              controllers['time']!.text = picked;
                              timeError = null;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Vui lòng chọn giờ học';
                          return null;
                        },
                      ),
                      if (timeError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(timeError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                        ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['duration'],
                        decoration: const InputDecoration(labelText: 'Thời lượng (phút)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập thời lượng';
                          }
                          if (num.tryParse(value.replaceAll(',', '')) == null) {
                            return 'Nhập số hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['location'],
                        decoration: const InputDecoration(labelText: 'Địa điểm'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập địa điểm' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['trainer_name'],
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'HLV phụ trách',
                          suffixIcon: Icon(Icons.arrow_drop_down_circle_outlined),
                        ),
                        onTap: () async {
                          final selectedTrainer = await _pickTrainerName(context, trainers, initialValue: controllers['trainer_name']?.text);
                          if (selectedTrainer != null && selectedTrainer.isNotEmpty) {
                            setDialogState(() {
                              controllers['trainer_name']!.text = selectedTrainer;
                              trainerError = null;
                            });
                          }
                        },
                        validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng chọn HLV' : null,
                      ),
                      if (trainerError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(trainerError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ngày học', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                final now = DateTime.now();
                                final initial = selectedClassDate ?? now;
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: initial.isBefore(now) ? now : initial,
                                  firstDate: DateTime(now.year, now.month, now.day),
                                  lastDate: DateTime(now.year + 5, now.month, now.day),
                                );
                                if (picked != null) {
                                  setDialogState(() {
                                    selectedClassDate = DateTime(picked.year, picked.month, picked.day);
                                    classDateText = selectedClassDate == null ? '' : _formatClassDate(selectedClassDate!);
                                    controllers['days']!.text = selectedClassDate!.toIso8601String().split('T').first;
                                    classDateError = null;
                                  });
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_outlined, color: Colors.teal),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        classDateText.isEmpty ? 'Chọn một ngày cụ thể' : classDateText,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: classDateText.isEmpty ? Colors.black54 : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              classDateText.isEmpty ? 'Chưa chọn ngày học' : 'Ngày đã chọn: $classDateText',
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                            if (classDateError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(classDateError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['days'],
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Ngày học (YYYY-MM-DD)'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng chọn ngày học';
                          }
                          return _parseClassDate(value) == null ? 'Ngày học không hợp lệ' : null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controllers['capacity'],
                        decoration: const InputDecoration(labelText: 'Số lượng'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập số lượng';
                          }
                          if (num.tryParse(value.replaceAll(',', '')) == null) {
                            return 'Nhập số hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      ...controllers.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextFormField(
                            controller: e.value,
                            decoration: InputDecoration(labelText: _fieldLabel(e.key, type)),
                            validator: (v) {
                              // name is required across types
                              if (e.key == 'name' && (v == null || v.trim().isEmpty)) return 'Vui lòng nhập tên';
                              // prevent duplicate package names
                              if (e.key == 'name' && type == 'packages' && v != null && v.trim().isNotEmpty) {
                                final newName = v.trim().toLowerCase();
                                final exists = packages.any((p) {
                                  try {
                                    final map = (p as Map).cast<String, dynamic>();
                                    final pname = (map['name'] ?? '').toString().trim().toLowerCase();
                                    if (item != null && map['id'] != null && item['id'] == map['id']) return false;
                                    return pname == newName;
                                  } catch (_) {
                                    return false;
                                  }
                                });
                                if (exists) return 'Tên gói đã tồn tại';
                              }
                              // price required for packages and trainers
                              if ((e.key == 'price') && (type == 'packages' || type == 'trainers')) {
                                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập giá';
                                final n = num.tryParse(v.replaceAll(',', ''));
                                if (n == null) return 'Nhập số hợp lệ';
                                if (n <= 0) return 'Giá phải lớn hơn 0';
                              }
                              // For packages, duration (in months) is required and must be numeric
                              if (e.key == 'duration' && type == 'packages') {
                                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập thời hạn';
                                final n = num.tryParse(v.replaceAll(',', ''));
                                if (n == null) return 'Nhập số hợp lệ';
                                if (n < 1 || n > 12) return 'Thời hạn phải trong khoảng 1-12 tháng';
                              }
                              // For packages, benefits_text is required
                              if (e.key == 'benefits_text' && type == 'packages') {
                                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập quyền lợi';
                              }
                              // numeric checks for other numeric fields (old_price, capacity)
                              if ((e.key == 'old_price' || e.key == 'capacity') && (v != null && v.isNotEmpty)) {
                                final n = num.tryParse(v.replaceAll(',', ''));
                                if (n == null) return 'Nhập số hợp lệ';
                              }
                              return null;
                            },
                            keyboardType: (e.key == 'price' || e.key == 'duration' || e.key == 'capacity') ? TextInputType.number : TextInputType.text,
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () async { await _safePop(dialogContext); }, child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    setDialogState(() => hasTriedSubmit = true);
                    if (!formKey.currentState!.validate()) return;
                    // Additional cross-field validations for classes
                    if (type == 'classes') {
                      setDialogState(() {
                        classDateError = null;
                        timeError = null;
                        trainerError = null;
                      });

                      // Ensure trainer selected
                      if (controllers['trainer_name']!.text.trim().isEmpty) {
                        setDialogState(() => trainerError = 'Vui lòng chọn HLV phụ trách');
                        return;
                      }

                      // Ensure a concrete date is selected.
                      if (selectedClassDate == null) {
                        setDialogState(() => classDateError = 'Vui lòng chọn ngày học');
                        return;
                      }

                      // Ensure time is selected
                      if (controllers['time']!.text.trim().isEmpty) {
                        setDialogState(() => timeError = 'Vui lòng chọn giờ học');
                        return;
                      }

                      // Validate that the selected date/time is in the future.
                      final pickedTime = _parseTimeOfDay(controllers['time']!.text.trim());
                      final now = DateTime.now();
                      final combined = DateTime(selectedClassDate!.year, selectedClassDate!.month, selectedClassDate!.day, pickedTime.hour, pickedTime.minute);
                      if (!combined.isAfter(now)) {
                        setDialogState(() => classDateError = 'Ngày/giờ lớp phải ở tương lai');
                        return;
                      }

                      // Capacity and duration numeric checks (validators cover but double-check)
                      if (controllers['capacity']!.text.trim().isNotEmpty && num.tryParse(controllers['capacity']!.text.replaceAll(',', '')) == null) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số lượng không hợp lệ')));
                        return;
                      }
                      if (controllers['duration']!.text.trim().isNotEmpty && num.tryParse(controllers['duration']!.text.replaceAll(',', '')) == null) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thời lượng không hợp lệ')));
                        return;
                      }
                    }

                    try {
                      // Build payload or FormData when image present
                      if (type == 'trainers' && (pickedImage != null || removeImage)) {
                        final form = FormData();
                        form.fields.add(MapEntry('type', type));
                        if (item != null && item['id'] != null) form.fields.add(MapEntry('id', item['id'].toString()));
                        if (removeImage) form.fields.add(MapEntry('remove_image', '1'));
                        controllers.forEach((k, v) {
                          form.fields.add(MapEntry(k, v.text));
                        });
                        if (pickedImage != null) {
                          form.files.add(MapEntry('image', await MultipartFile.fromFile(pickedImage!.path, filename: pickedImage!.name)));
                        }
                        final res = await ApiClient.instance.dio.post('/admin/store', data: form);
                        if (res.data != null && res.data['success'] == true) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.data['message']?.toString() ?? 'Đã lưu')));
                          await _safePop(dialogContext);
                          await fetchAll();
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.data['message']?.toString() ?? 'Lỗi khi lưu')));
                        }
                      } else {
                        final payload = <String, dynamic>{'type': type};
                        if (item != null && item['id'] != null) payload['id'] = item['id'];
                        if (type == 'classes') {
                          payload['days'] = controllers['days']?.text ?? '';
                        }
                        controllers.forEach((k, v) {
                          if (type == 'classes' && k == 'days') return;
                          payload[k] = v.text;
                        });
                        final res = await ApiClient.instance.dio.post('/admin/store', data: payload);
                        if (res.data != null && res.data['success'] == true) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.data['message']?.toString() ?? 'Đã lưu')));
                          await _safePop(dialogContext);
                          await fetchAll();
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.data['message']?.toString() ?? 'Lỗi khi lưu')));
                        }
                      }
                    } on DioException catch (e) {
                      _handleApiError(e, fallbackMessage: 'Lỗi khi lưu mục');
                    }
                  } catch (e, st) {
                    // Show a readable dialog instead of letting Flutter show the red error screen
                    debugPrint('Unhandled error in save handler: $e\n$st');
                    if (!mounted) return;
                    await showDialog<void>(
                      context: context,
                      builder: (dctx) => AlertDialog(
                        title: const Text('Lỗi nội bộ'),
                        content: SingleChildScrollView(child: Text(e.toString())),
                        actions: [TextButton(onPressed: () => Navigator.of(dctx).pop(), child: const Text('Đóng'))],
                      ),
                    );
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _openTrainerCrudSheet({Map<String, dynamic>? item}) async {
    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: (item?['name'] ?? '').toString());
    final emailCtrl = TextEditingController(text: (item?['email'] ?? '').toString());
    final phoneCtrl = TextEditingController(text: (item?['phone'] ?? '').toString());
    final specCtrl = TextEditingController(text: (item?['spec'] ?? '').toString());
    final priceCtrl = TextEditingController(text: (item?['price'] ?? '').toString());

    XFile? pickedImage;
    bool removeImage = false;
    bool hasTriedSubmit = false;

    String? validateEmail(String? value) {
      final v = value?.trim() ?? '';
      if (v.isEmpty) return 'Vui lòng nhập email';
      final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v);
      return ok ? null : 'Email không đúng định dạng';
    }

    String? validatePhone(String? value) {
      final v = (value ?? '').replaceAll(RegExp(r'\s+'), '');
      if (v.isEmpty) return 'Vui lòng nhập số điện thoại';
      final ok = RegExp(r'^\d{9,11}$').hasMatch(v);
      return ok ? null : 'Số điện thoại phải từ 9-11 chữ số';
    }

    String? validateRequired(String? value, String field) {
      return value == null || value.trim().isEmpty ? 'Vui lòng nhập $field' : null;
    }

    String? validatePrice(String? value) {
      final v = (value ?? '').replaceAll(',', '').trim();
      if (v.isEmpty) return 'Vui lòng nhập học phí';
      final n = num.tryParse(v);
      if (n == null) return 'Nhập số hợp lệ';
      if (n <= 0) return 'Học phí phải lớn hơn 0';
      return null;
    }

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setSheetState) {
              final imageUrl = (item?['image_url'] ?? item?['image'] ?? '').toString();

              Widget imageSection() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl.isNotEmpty && !removeImage)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(child: Text('Ảnh hiện tại')),
                              Checkbox(
                                value: removeImage,
                                onChanged: (value) => setSheetState(() => removeImage = value ?? false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (pickedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(pickedImage!.path),
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(pickedImage!.name)),
                            ],
                          ),
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: 160,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final image = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 1200,
                                maxHeight: 1200,
                                imageQuality: 85,
                              );
                              if (image != null) {
                                setSheetState(() {
                                  pickedImage = image;
                                  removeImage = false;
                                });
                              }
                            },
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Chọn ảnh'),
                          ),
                        ),
                        if (pickedImage != null)
                          TextButton(
                            onPressed: () => setSheetState(() => pickedImage = null),
                            child: const Text('Bỏ chọn'),
                          ),
                      ],
                    ),
                  ],
                );
              }

              return AlertDialog(
                title: Text(item == null ? 'Thêm HLV' : 'Chỉnh sửa HLV'),
                content: SizedBox(
                  width: 560,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      autovalidateMode: hasTriedSubmit ? AutovalidateMode.always : AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          imageSection(),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(labelText: 'Họ tên'),
                            validator: (value) => validateRequired(value, 'họ tên'),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: emailCtrl,
                            decoration: const InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            validator: validateEmail,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: phoneCtrl,
                            decoration: const InputDecoration(labelText: 'Số điện thoại'),
                            keyboardType: TextInputType.phone,
                            validator: validatePhone,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: specCtrl,
                            decoration: const InputDecoration(labelText: 'Chuyên môn'),
                            validator: (value) => validateRequired(value, 'chuyên môn'),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: priceCtrl,
                            decoration: const InputDecoration(labelText: 'Học phí'),
                            keyboardType: TextInputType.number,
                            validator: validatePrice,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      FocusScope.of(dialogContext).unfocus();
                      await Future<void>.delayed(const Duration(milliseconds: 40));
                      if (dialogContext.mounted) {
                          await _safePop(dialogContext);
                      }
                    },
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setSheetState(() => hasTriedSubmit = true);
                      if (!(formKey.currentState?.validate() ?? false)) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng sửa các trường đang báo lỗi')),
                        );
                        return;
                      }

                      try {
                        final hasImageChange = pickedImage != null || removeImage;
                        if (hasImageChange) {
                          final form = FormData();
                          form.fields.add(const MapEntry('type', 'trainers'));
                          if (item != null && item['id'] != null) {
                            form.fields.add(MapEntry('id', item['id'].toString()));
                          }
                          if (removeImage) {
                            form.fields.add(const MapEntry('remove_image', '1'));
                          }
                          form.fields.add(MapEntry('name', nameCtrl.text));
                          form.fields.add(MapEntry('email', emailCtrl.text));
                          form.fields.add(MapEntry('phone', phoneCtrl.text));
                          form.fields.add(MapEntry('spec', specCtrl.text));
                          form.fields.add(MapEntry('price', priceCtrl.text));
                          if (pickedImage != null) {
                            form.files.add(
                              MapEntry(
                                'image',
                                await MultipartFile.fromFile(
                                  pickedImage!.path,
                                  filename: pickedImage!.name,
                                ),
                              ),
                            );
                          }
                          final res = await ApiClient.instance.dio.post('/admin/store', data: form);
                          if (res.data != null && res.data['success'] == true) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res.data['message']?.toString() ?? 'Đã lưu')),
                            );
                            await _safePop(dialogContext);
                            await fetchAll();
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res.data['message']?.toString() ?? 'Lỗi khi lưu')),
                            );
                          }
                        } else {
                          final payload = <String, dynamic>{
                            'type': 'trainers',
                            if (item != null && item['id'] != null) 'id': item['id'],
                            'name': nameCtrl.text,
                            'email': emailCtrl.text,
                            'phone': phoneCtrl.text,
                            'spec': specCtrl.text,
                            'price': priceCtrl.text,
                          };
                          final res = await ApiClient.instance.dio.post('/admin/store', data: payload);
                          if (res.data != null && res.data['success'] == true) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res.data['message']?.toString() ?? 'Đã lưu')),
                            );
                            await _safePop(dialogContext);
                            await fetchAll();
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res.data['message']?.toString() ?? 'Lỗi khi lưu')),
                            );
                          }
                        }
                      } on DioException catch (e) {
                        _handleApiError(e, fallbackMessage: 'Lỗi khi lưu HLV');
                      }
                    },
                    child: const Text('Lưu'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {}
  }

  Widget _header(String title, String subtitle, {VoidCallback? onAdd}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          if (onAdd != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Thêm mới'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _crudList(String type, List<dynamic> data) {
    return RefreshIndicator(
      onRefresh: fetchAll,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: data.map((e) {
          final item = (e as Map).cast<String, dynamic>();
          return Card(
            child: ListTile(
              title: Text((item['name'] ?? 'Untitled').toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  item['price'] != null ? _formatCurrency(item['price']) : '',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
              trailing: Wrap(
                spacing: 6,
                children: [
                  IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => openCrudDialog(type, item: item)),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => deleteItem(type, item['id'])),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<dynamic> _filteredTrainers() {
    final query = _trainerSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return trainers;

    return trainers.where((e) {
      final item = (e as Map).cast<String, dynamic>();
      final name = (item['name'] ?? '').toString().toLowerCase();
      final email = (item['email'] ?? '').toString().toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  List<dynamic> _filteredClasses() {
    final query = _classSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return classes;

    return classes.where((e) {
      final item = (e as Map).cast<String, dynamic>();
      final name = (item['name'] ?? '').toString().toLowerCase();
      final trainerName = (item['trainer_name'] ?? '').toString().toLowerCase();
      final day = (item['days'] ?? '').toString().toLowerCase();
      return name.contains(query) || trainerName.contains(query) || day.contains(query);
    }).toList();
  }

  List<dynamic> _filteredTrainersByPrice() {
    final query = _trainerSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return trainers;

    return trainers.where((e) {
      final item = (e as Map).cast<String, dynamic>();
      final name = (item['name'] ?? '').toString().toLowerCase();
      final priceText = _formatCurrency(item['price']).toLowerCase();
      final rawPrice = (item['price'] ?? '').toString().toLowerCase();
      return name.contains(query) || priceText.contains(query) || rawPrice.contains(query);
    }).toList();
  }

  List<dynamic> _filteredTrainerSchedules() {
    final query = _scheduleSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return trainerSchedules;

    String trainerEmailFor(Map<String, dynamic> schedule) {
      final trainerUserId = schedule['trainer_user_id']?.toString() ?? '';
      final trainerId = schedule['trainer_id']?.toString() ?? '';
      for (final rawTrainer in trainers) {
        final trainer = (rawTrainer as Map).cast<String, dynamic>();
        final userId = trainer['user_id']?.toString() ?? '';
        final id = trainer['id']?.toString() ?? '';
        if (userId == trainerUserId || id == trainerId) {
          return (trainer['email'] ?? '').toString().toLowerCase();
        }
      }
      return '';
    }

    return trainerSchedules.where((e) {
      final item = (e as Map).cast<String, dynamic>();
      final name = (item['trainer_name'] ?? '').toString().toLowerCase();
      final email = trainerEmailFor(item);
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  List<dynamic> _filteredMembers() {
    final query = _memberSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return members;

    return members.where((e) {
      final item = (e as Map).cast<String, dynamic>();
      final name = (item['name'] ?? '').toString().toLowerCase();
      final email = (item['email'] ?? '').toString().toLowerCase();
      final phone = (item['phone'] ?? '').toString().toLowerCase();
      return name.contains(query) || email.contains(query) || phone.contains(query);
    }).toList();
  }

  List<dynamic> _filteredBookings() {
    final query = _bookingSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return bookings;

    return bookings.where((e) {
      final item = (e as Map).cast<String, dynamic>();
      final name = (item['user_name'] ?? '').toString().toLowerCase();
      return name.contains(query);
    }).toList();
  }

  Widget _membersList({List<dynamic>? filteredItems}) {
    final source = filteredItems ?? members;
    return RefreshIndicator(
      onRefresh: fetchAll,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: source.map((e) {
          final item = (e as Map).cast<String, dynamic>();
          return Card(
            child: ListTile(
              title: Text((item['name'] ?? '').toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${item['email'] ?? ''}\n${item['pack'] ?? ''} • ${item['status'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
              isThreeLine: true,
              trailing: Wrap(
                spacing: 6,
                children: [
                  IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => openCrudDialog('members', item: item)),
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => deleteItem('members', item['id'])),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _bookingsList({List<dynamic>? filteredItems}) {
    final source = filteredItems ?? bookings;
    return RefreshIndicator(
      onRefresh: fetchAll,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: source.map((e) {
          final item = (e as Map).cast<String, dynamic>();
          final id = _toInt(item['id']);

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((item['user_name'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text((item['user_email'] ?? '').toString(), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  if ((item['user_phone'] ?? '').toString().isNotEmpty)
                    Text((item['user_phone'] ?? '').toString(), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text((item['schedule_info'] ?? '').toString(), style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  if ((item['created_at'] ?? '').toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Tạo lúc: ${item['created_at']}', style: const TextStyle(fontSize: 11, color: Colors.black45)),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => confirmBooking(id, 'reject'),
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text('Từ chối', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => confirmBooking(id, 'confirm'),
                          icon: const Icon(Icons.check),
                          label: const Text('Xác nhận'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _trainerSchedulesList({List<dynamic>? filteredItems}) {
    final source = filteredItems ?? trainerSchedules;
    return RefreshIndicator(
      onRefresh: fetchAll,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: source.map((e) {
          final item = (e as Map).cast<String, dynamic>();

          return Card(
            child: InkWell(
              onTap: () => _showTrainerScheduleDetails(item),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((item['trainer_name'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 4),
                          const Text('Bấm để xem lịch làm và booking', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black38),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(_screenTitle),
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Lớp tập'),
            Tab(text: 'HLV'),
            Tab(text: 'Lịch làm HLV'),
            Tab(text: 'Gói tập'),
            Tab(text: 'Thành viên'),
            Tab(text: 'Đặt lịch'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _controller,
          children: [
            Column(
              children: [
                _header('Lớp tập', '', onAdd: () => openCrudDialog('classes')),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: TextField(
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
                ),
                Expanded(child: _crudList('classes', _filteredClasses())),
              ],
            ),
            Column(
              children: [
                _header('Huấn luyện viên', '', onAdd: () => openCrudDialog('trainers')),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: TextField(
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
                ),
                Expanded(child: _crudList('trainers', _filteredTrainersByPrice())),
              ],
            ),
            Column(
              children: [
                _header('Lịch làm huấn luyện viên', 'Danh sách lịch làm hiện tại của HLV'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: TextField(
                    onChanged: (value) => setState(() => _scheduleSearchQuery = value),
                    decoration: InputDecoration(
                      labelText: 'Tìm theo tên HLV hoặc gmail',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _scheduleSearchQuery.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Xóa tìm kiếm',
                              onPressed: () => setState(() => _scheduleSearchQuery = ''),
                              icon: const Icon(Icons.close),
                            ),
                    ),
                  ),
                ),
                Expanded(child: _trainerSchedulesList(filteredItems: _filteredTrainerSchedules())),
              ],
            ),
            Column(
              children: [
                _header('Gói tập', '', onAdd: () => openCrudDialog('packages')),
                Expanded(child: _crudList('packages', packages)),
              ],
            ),
            Column(
              children: [
                _header('Thành viên', '', onAdd: () => openCrudDialog('members')),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: TextField(
                    onChanged: (value) => setState(() => _memberSearchQuery = value),
                    decoration: InputDecoration(
                      labelText: 'Tìm theo tên, gmail hoặc số điện thoại',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _memberSearchQuery.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Xóa tìm kiếm',
                              onPressed: () => setState(() => _memberSearchQuery = ''),
                              icon: const Icon(Icons.close),
                            ),
                    ),
                  ),
                ),
                Expanded(child: _membersList(filteredItems: _filteredMembers())),
              ],
            ),
            Column(
              children: [
                _header('Xác nhận lịch', ''),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: TextField(
                    onChanged: (value) => setState(() => _bookingSearchQuery = value),
                    decoration: InputDecoration(
                      labelText: 'Tìm theo tên người đặt',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _bookingSearchQuery.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Xóa tìm kiếm',
                              onPressed: () => setState(() => _bookingSearchQuery = ''),
                              icon: const Icon(Icons.close),
                            ),
                    ),
                  ),
                ),
                Expanded(child: _bookingsList(filteredItems: _filteredBookings())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleApiError(DioException e, {String? fallbackMessage}) {
    if (!mounted) return;
    final status = e.response?.statusCode;
    final msg = e.response?.data?['message']?.toString() ?? fallbackMessage ?? 'Lỗi kết nối';
    if (status == 401 || status == 403) {
      showDialog<void>(
        context: context,
        builder: (d) {
          return AlertDialog(
            title: const Text('Yêu cầu đăng nhập'),
            content: Text('$msg\nVui lòng đăng nhập bằng tài khoản admin để tiếp tục.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(d).pop(), child: const Text('Đóng')),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(d).pop();
                  Navigator.of(context).pushNamed('/login');
                },
                child: const Text('Đến trang đăng nhập'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}