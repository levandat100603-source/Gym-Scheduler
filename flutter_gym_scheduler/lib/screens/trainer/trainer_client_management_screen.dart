import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../providers/trainer_management_provider.dart';
import '../../models/app_models_extended.dart';
import '../../widgets/common_widgets.dart';

class TrainerClientManagementScreen extends StatefulWidget {
  const TrainerClientManagementScreen({super.key, required this.trainerId});

  final int trainerId;

  @override
  State<TrainerClientManagementScreen> createState() => _TrainerClientManagementScreenState();
}

class _TrainerClientManagementScreenState extends State<TrainerClientManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TrainerManagementProvider _provider;
  int? selectedMemberId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _provider = context.read<TrainerManagementProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider.fetchSessionNotes(widget.trainerId);
      _provider.fetchWorkoutPlans(widget.trainerId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addSessionNote(BuildContext context, int bookingId, int memberId) async {
    final contentCtrl = TextEditingController();
    final focusCtrl = TextEditingController();
    final nextCtrl = TextEditingController();
    int? selectedPerformance;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              title: const Text('Ghi chú buổi tập'),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: contentCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Nhận xét buổi tập',
                          border: OutlineInputBorder(),
                          hintText: 'Ví dụ: Tập tạ 10kg tốt, form cần cải thiện...',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: focusCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nhóm cơ tập (phẩy phân cách)',
                          hintText: 'chest, shoulders, triceps',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedPerformance,
                        decoration: const InputDecoration(labelText: 'Mức độ hiệu suất'),
                        items: List.generate(5, (i) {
                          final score = i + 1;
                          return DropdownMenuItem(
                            value: score,
                            child: Text('$score sao${score == 5 ? ' (Xuất sắc)' : score == 4 ? ' (Tốt)' : score == 3 ? ' (Bình thường)' : score == 2 ? ' (Cần cải thiện)' : ' (Yếu)'}'),
                          );
                        }),
                        onChanged: (v) => setState(() => selectedPerformance = v),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nextCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Tiếp theo cần làm',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: contentCtrl.text.isEmpty
                      ? null
                      : () async {
                          final success = await _provider.addSessionNote(
                            widget.trainerId,
                            bookingId,
                            memberId,
                            contentCtrl.text,
                            focusAreas: focusCtrl.text.isEmpty
                                ? null
                                : focusCtrl.text
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList(),
                            performance: selectedPerformance,
                            nextFocus: nextCtrl.text.isEmpty ? null : nextCtrl.text,
                          );
                          if (!mounted) return;
                          Navigator.pop(dialogContext);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ghi chú đã được lưu')),
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

  Future<void> _createWorkoutPlan(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String selectedDifficulty = 'intermediate';
    int selectedDuration = 4;
    DateTime? startDate;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              title: const Text('Tạo bài tập mới'),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Tên bài tập'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: contentCtrl,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Chi tiết bài tập (JSON)',
                          border: OutlineInputBorder(),
                          hintText: '[{"day": 1, "exercises": [...]}]',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedDifficulty,
                        decoration: const InputDecoration(labelText: 'Mức độ khó'),
                        items: const [
                          DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                          DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                          DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                        ],
                        onChanged: (v) => setState(() => selectedDifficulty = v ?? selectedDifficulty),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: selectedDuration.toDouble(),
                        min: 1,
                        max: 12,
                        divisions: 11,
                        label: '$selectedDuration tuần',
                        onChanged: (v) => setState(() => selectedDuration = v.toInt()),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('Ngày bắt đầu'),
                        subtitle: Text(startDate == null ? 'Chọn ngày' : DateFormat('dd/MM/yyyy').format(startDate!)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 180)),
                          );
                          if (picked != null) setState(() => startDate = picked);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: titleCtrl.text.isEmpty || contentCtrl.text.isEmpty
                      ? null
                      : () async {
                          // TODO: Get selected member ID from context
                          // For now, show message
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Tạo'),
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
        title: const Text('Quản lý Học viên'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ghi chú buổi'),
            Tab(text: 'Bài tập'),
            Tab(text: 'Hồ sơ sức khỏe'),
          ],
        ),
      ),
      body: Consumer<TrainerManagementProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Session Notes Tab
              RefreshIndicator(
                onRefresh: () => provider.fetchSessionNotes(widget.trainerId),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Ghi chú buổi tập',
                      subtitle: 'Theo dõi tiến độ của học viên',
                    ),
                    const SizedBox(height: 16),
                    if (provider.sessionNotes.isEmpty)
                      const EmptyState(
                        icon: Icons.note_outlined,
                        title: 'Không có ghi chú nào',
                        subtitle: 'Ghi chú sẽ xuất hiện sau buổi tập đầu tiên',
                      )
                    else
                      ...provider.sessionNotes.map((note) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Buổi tập #${note.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                    if (note.performance != null)
                                      Text(
                                        '${'⭐' * note.performance!} ${note.performance}/5',
                                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.amber),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(note.content),
                                if (note.focusAreas != null) ...[
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    children: note.focusAreas!
                                        .split(',')
                                        .map((e) => Chip(label: Text(e.trim())))
                                        .toList(),
                                  ),
                                ],
                                if (note.nextFocus != null) ...[
                                  const SizedBox(height: 8),
                                  Text('Tiếp theo: ${note.nextFocus}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.teal)),
                                ],
                                if (note.createdAt != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(note.createdAt!),
                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),

              // Workout Plans Tab
              RefreshIndicator(
                onRefresh: () => provider.fetchWorkoutPlans(widget.trainerId),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Bài tập',
                      subtitle: 'Các chương trình tập luyện bạn đã tạo',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _createWorkoutPlan(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Tạo bài tập mới'),
                    ),
                    const SizedBox(height: 16),
                    if (provider.workoutPlans.isEmpty)
                      const EmptyState(
                        icon: Icons.fitness_center_outlined,
                        title: 'Không có bài tập nào',
                        subtitle: 'Tạo bài tập đầu tiên để cung cấp cho học viên',
                      )
                    else
                      ...provider.workoutPlans.map((plan) {
                        return Card(
                          child: ListTile(
                            title: Text(plan.title),
                            subtitle: Text(
                              '${plan.difficulty ?? 'N/A'} • ${plan.duration} tuần',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                // Confirm delete
                              },
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),

              // Health Profiles Tab
              RefreshIndicator(
                onRefresh: () => Future.value(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Hồ sơ sức khỏe học viên',
                      subtitle: 'Xem chỉ số cơ thể của các học viên đang hướng dẫn',
                    ),
                    const SizedBox(height: 16),
                    const EmptyState(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Chọn học viên để xem hồ sơ',
                      subtitle: 'Thông tin sẽ hiển thị tại đây',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
