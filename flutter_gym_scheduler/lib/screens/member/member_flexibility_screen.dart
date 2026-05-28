import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../providers/member_features_provider.dart';
import '../../widgets/common_widgets.dart';

class MemberFlexibilityScreen extends StatefulWidget {
  const MemberFlexibilityScreen({super.key, required this.memberId});

  final int memberId;

  @override
  State<MemberFlexibilityScreen> createState() => _MemberFlexibilityScreenState();
}

class _MemberFlexibilityScreenState extends State<MemberFlexibilityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MemberFeaturesProvider _provider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _provider = context.read<MemberFeaturesProvider>();
    _provider.fetchWaitlist(widget.memberId);
    _provider.fetchFreezeRequests(widget.memberId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _requestFreeze(BuildContext context) async {
    DateTime? startDate;
    DateTime? endDate;
    String selectedReason = 'personal';
    final notesCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              title: const Text('Bảo lưu gói tập'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tạm dừng gói tập của bạn trong một thời gian. Thời gian này sẽ được tính lại khi kết thúc bảo lưu.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Từ ngày'),
                      subtitle: Text(startDate == null ? 'Chọn ngày' : DateFormat('dd/MM/yyyy').format(startDate!)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => startDate = picked);
                      },
                    ),
                    ListTile(
                      title: const Text('Đến ngày'),
                      subtitle: Text(endDate == null ? 'Chọn ngày' : DateFormat('dd/MM/yyyy').format(endDate!)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: startDate ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => endDate = picked);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedReason,
                      decoration: const InputDecoration(labelText: 'Lý do'),
                      items: const [
                        DropdownMenuItem(value: 'vacation', child: Text('Đi du lịch')),
                        DropdownMenuItem(value: 'medical', child: Text('Lý do sức khỏe')),
                        DropdownMenuItem(value: 'personal', child: Text('Lý do cá nhân')),
                      ],
                      onChanged: (v) => setState(() => selectedReason = v ?? selectedReason),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú thêm (tùy chọn)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: startDate != null && endDate != null
                      ? () async {
                          final success = await _provider.requestFreeze(
                            widget.memberId,
                            startDate!,
                            endDate!,
                            selectedReason,
                            notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
                          );
                          if (!mounted) return;
                          Navigator.pop(dialogContext);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Yêu cầu bảo lưu đã được gửi')),
                            );
                          }
                        }
                      : null,
                  child: const Text('Gửi'),
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
        title: const Text('Tính linh hoạt'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Danh sách chờ'),
            Tab(text: 'Bảo lưu gói'),
          ],
        ),
      ),
      body: Consumer<MemberFeaturesProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Waitlist Tab
              RefreshIndicator(
                onRefresh: () => provider.fetchWaitlist(widget.memberId),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Danh sách chờ',
                      subtitle: 'Nếu lớp đầy, bạn có thể tham gia danh sách chờ để được thông báo khi có chỗ',
                    ),
                    const SizedBox(height: 16),
                    if (provider.waitlistEntries.isEmpty)
                      const EmptyState(
                        icon: Icons.list_outlined,
                        title: 'Chưa có trong danh sách chờ nào',
                      )
                    else
                      ...provider.waitlistEntries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${item.position}'),
                            ),
                            title: Text(
                              '${item.itemType == 'class' ? 'Lớp' : 'HLV'} #${item.itemId}',
                            ),
                            subtitle: Text(
                              'Thêm vào ${DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt ?? DateTime.now())}',
                            ),
                            trailing: item.notifiedAt == null
                                ? const Icon(Icons.schedule_outlined, color: Colors.orange)
                                : const Icon(Icons.done_outlined, color: Colors.green),
                            onLongPress: () {
                              // Show delete option
                            },
                          ),
                        );
                      }),
                  ],
                ),
              ),

              // Membership Freeze Tab
              RefreshIndicator(
                onRefresh: () => provider.fetchFreezeRequests(widget.memberId),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Bảo lưu gói tập',
                      subtitle: 'Tạm dừng gói tập mà không mất hạn sử dụng',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _requestFreeze(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Yêu cầu bảo lưu'),
                    ),
                    const SizedBox(height: 16),
                    if (provider.freezeRequests.isEmpty)
                      const EmptyState(
                        icon: Icons.pause_circle_outline,
                        title: 'Chưa có bảo lưu nào',
                      )
                    else
                      ...provider.freezeRequests.map((freeze) {
                        final statusColor = freeze.status == 'approved'
                            ? Colors.green
                            : freeze.status == 'active'
                                ? Colors.blue
                                : Colors.orange;
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      freeze.reason.toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        freeze.status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${DateFormat('dd/MM/yyyy').format(freeze.startDate)} - ${DateFormat('dd/MM/yyyy').format(freeze.endDate)}',
                                ),
                                Text(
                                  'Thời gian bảo lưu: ${freeze.frozenDays} ngày',
                                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                                ),
                                if (freeze.notes != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ghi chú: ${freeze.notes}',
                                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
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
