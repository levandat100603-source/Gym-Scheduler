import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/trainer_management_provider.dart';
import '../../models/app_models_extended.dart';
import '../../widgets/common_widgets.dart';

class TrainerAvailabilityScreen extends StatefulWidget {
  const TrainerAvailabilityScreen({super.key, required this.trainerId});

  final int trainerId;

  @override
  State<TrainerAvailabilityScreen> createState() => _TrainerAvailabilityScreenState();
}

class _TrainerAvailabilityScreenState extends State<TrainerAvailabilityScreen> {
  late TrainerManagementProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<TrainerManagementProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider.fetchWorkingHours(widget.trainerId);
    });
  }

  Future<void> _editWorkingHours(BuildContext context, List<WorkingHours> current) async {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final messenger = ScaffoldMessenger.of(context);
    final byDay = <int, WorkingHours>{
      for (final item in current) item.dayOfWeek: item,
    };
    final timeOptions = List.generate(48, (index) {
      final hour = index ~/ 2;
      final minute = index.isEven ? '00' : '30';
      return '${hour.toString().padLeft(2, '0')}:$minute';
    });
    final startTimes = List.generate(
      7,
      (i) => byDay[i]?.startTime.isNotEmpty == true ? byDay[i]!.startTime : '06:00',
    );
    final endTimes = List.generate(
      7,
      (i) => byDay[i]?.endTime.isNotEmpty == true ? byDay[i]!.endTime : '20:00',
    );
    final activeFlags = List.generate(7, (i) => byDay[i]?.isActive ?? true);

    int timeToMinutes(String value) {
      final parts = value.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      return hour * 60 + minute;
    }

    List<String> endOptionsFor(String startTime) {
      final startMinutes = timeToMinutes(startTime);
      return timeOptions.where((option) => timeToMinutes(option) > startMinutes).toList();
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final navigator = Navigator.of(dialogContext);
        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              title: const Text('Khung giờ làm việc'),
              content: SizedBox(
                width: 500,
                child: ListView(
                  shrinkWrap: true,
                  children: List.generate(7, (i) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(dayNames[i], style: const TextStyle(fontWeight: FontWeight.w600)),
                                ),
                                const Text('Off', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                Switch(
                                  value: !activeFlags[i],
                                  onChanged: (value) => setState(() => activeFlags[i] = !value),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: startTimes[i],
                                    isExpanded: true,
                                    decoration: const InputDecoration(labelText: 'Từ'),
                                    items: timeOptions
                                        .map((time) => DropdownMenuItem<String>(value: time, child: Text(time)))
                                        .toList(),
                                    onChanged: activeFlags[i]
                                        ? (value) {
                                            if (value == null) return;
                                            setState(() {
                                              startTimes[i] = value;
                                              if (timeToMinutes(endTimes[i]) <= timeToMinutes(value)) {
                                                final nextEnd = endOptionsFor(value).isNotEmpty ? endOptionsFor(value).first : value;
                                                endTimes[i] = nextEnd;
                                              }
                                            });
                                          }
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: endTimes[i],
                                    isExpanded: true,
                                    decoration: const InputDecoration(labelText: 'Đến'),
                                    items: endOptionsFor(startTimes[i])
                                        .map((time) => DropdownMenuItem<String>(value: time, child: Text(time)))
                                        .toList(),
                                    onChanged: activeFlags[i]
                                        ? (value) {
                                            if (value == null) return;
                                            setState(() => endTimes[i] = value);
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    for (var i = 0; i < 7; i++) {
                      if (!activeFlags[i]) continue;
                      if (timeToMinutes(endTimes[i]) <= timeToMinutes(startTimes[i])) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Giờ kết thúc ngày ${dayNames[i]} phải lớn hơn giờ bắt đầu')),
                        );
                        return;
                      }
                    }

                    final hours = List.generate(
                      7,
                      (i) => WorkingHours(
                        id: byDay[i]?.id ?? 0,
                        trainerId: widget.trainerId,
                        dayOfWeek: i,
                        startTime: startTimes[i].trim(),
                        endTime: endTimes[i].trim(),
                        isActive: activeFlags[i],
                      ),
                    );

                    final success = await _provider.saveWorkingHours(widget.trainerId, hours);
                    if (!mounted) return;
                    if (success) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (navigator.canPop()) {
                          navigator.pop();
                        }
                      });
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Đã lưu khung giờ làm việc')),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Lưu khung giờ thất bại')),
                      );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Quản lý Lịch làm việc'),
      ),
      body: Consumer<TrainerManagementProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchWorkingHours(widget.trainerId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionHeader(
                  title: 'Khung giờ làm việc',
                  subtitle: 'Cập nhật lịch khả dụng của bạn cho Member đặt',
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _editWorkingHours(context, provider.workingHours),
                  icon: const Icon(Icons.edit),
                  label: const Text('Chỉnh sửa khung giờ'),
                ),
                const SizedBox(height: 16),
                if (provider.workingHours.isEmpty)
                  const EmptyState(
                    icon: Icons.schedule_outlined,
                    title: 'Chưa có khung giờ',
                    subtitle: 'Bấm "Chỉnh sửa" để thiết lập lịch làm việc',
                  )
                else
                  ...provider.workingHours.map((wh) {
                    const dayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
                    return Card(
                      child: ListTile(
                        title: Text(dayNames[wh.dayOfWeek]),
                        subtitle: Text(wh.isActive ? '${wh.startTime} - ${wh.endTime}' : 'Off'),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

