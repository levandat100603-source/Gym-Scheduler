import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../providers/member_features_provider.dart';
import '../../widgets/common_widgets.dart';

class MemberCheckInAndCancellationScreen extends StatefulWidget {
  const MemberCheckInAndCancellationScreen({super.key, required this.memberId});

  final int memberId;

  @override
  State<MemberCheckInAndCancellationScreen> createState() => _MemberCheckInAndCancellationScreenState();
}

class _MemberCheckInAndCancellationScreenState extends State<MemberCheckInAndCancellationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MemberFeaturesProvider _provider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _provider = context.read<MemberFeaturesProvider>();
    _provider.fetchMemberCard(widget.memberId);
    _provider.fetchCancellations(widget.memberId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showCheckInCode(BuildContext context) async {
    if (_provider.memberCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có thẻ hội viên, vui lòng tạo trước')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Thẻ Check-in'),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_2_rounded, size: 100, color: Colors.teal),
                const SizedBox(height: 16),
                const Text(
                  'Quét mã QR này tại cổng check-in phòng tập',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  _provider.memberCard!.cardNumber,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hiệu lực từ: ${DateFormat('dd/MM/yyyy').format(_provider.memberCard!.createdAt ?? DateTime.now())}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Đóng')),
          ],
        );
      },
    );
  }

  Future<void> _cancelBooking(BuildContext context, int bookingId) async {
    final reasonCtrl = TextEditingController();

    // First check cancellation policy
    final policy = await _provider.checkCancellationPolicy(bookingId);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hủy lịch tập'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (policy != null) ...[
                  const Text('Chính sách hủy:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hủy trước ${policy['hours_before'] ?? 2} giờ: Hoàn tiền 100%',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hủy trong ${policy['hours_before'] ?? 2} giờ: Mất lượt tập',
                          style: const TextStyle(fontSize: 13, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: reasonCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Lý do hủy',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Quay lại')),
            ElevatedButton(
              onPressed: () async {
                final success = await _provider.cancelBooking(
                  widget.memberId,
                  bookingId,
                  reasonCtrl.text.isEmpty ? 'Lý do cá nhân' : reasonCtrl.text,
                );
                if (!mounted) return;
                Navigator.pop(dialogContext);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lịch tập đã được hủy')),
                  );
                }
              },
              child: const Text('Xác nhận hủy'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Check-in & Hủy lịch'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thẻ hội viên'),
            Tab(text: 'Hủy lịch'),
            Tab(text: 'Lịch sử'),
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
              // Member Card Tab
              RefreshIndicator(
                onRefresh: () => provider.fetchMemberCard(widget.memberId),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Thẻ hội viên điện tử',
                      subtitle: 'Quét thẻ QR tại cổng check-in',
                    ),
                    const SizedBox(height: 16),
                    if (provider.memberCard == null)
                      Column(
                        children: [
                          const EmptyState(
                            icon: Icons.card_membership_outlined,
                            title: 'Chưa có thẻ hội viên',
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final success = await provider.generateMemberCard(widget.memberId);
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Thẻ đã được tạo thành công')),
                                );
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Tạo thẻ hội viên'),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.qr_code_2_rounded, size: 120, color: Colors.teal),
                                  const SizedBox(height: 16),
                                  SelectableText(
                                    provider.memberCard!.cardNumber,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Trạng thái: ${provider.memberCard!.isActive ? 'Hoạt động' : 'Vô hiệu'}',
                                    style: TextStyle(
                                      color: provider.memberCard!.isActive ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _showCheckInCode(context),
                              icon: const Icon(Icons.visibility),
                              label: const Text('Xem chi tiết'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Cancel Booking Tab
              RefreshIndicator(
                onRefresh: () => Future.value(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Hủy lịch tập',
                      subtitle: 'Hủy lịch trước khi hết hạn quy định',
                    ),
                    const SizedBox(height: 16),
                    const InfoCard(
                      title: 'Lưu ý quan trọng',
                      message:
                          'Hủy lịch trong thời hạn quy định để nhận hoàn tiền hoặc giữ lượt tập. Hủy muộn có thể mất lượt tập hoặc bị trừ phí.',
                      icon: Icons.info_outlined,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    const EmptyState(
                      icon: Icons.cancel_outlined,
                      title: 'Chọn lịch để hủy',
                      subtitle: 'Danh sách lịch sắp tới sẽ hiển thị tại đây',
                    ),
                  ],
                ),
              ),

              // Cancellation History Tab
              RefreshIndicator(
                onRefresh: () => provider.fetchCancellations(widget.memberId),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Lịch sử hủy',
                      subtitle: 'Các lịch tập đã hủy',
                    ),
                    const SizedBox(height: 16),
                    if (provider.cancellations.isEmpty)
                      const EmptyState(
                        icon: Icons.history_outlined,
                        title: 'Chưa có hủy lịch nào',
                      )
                    else
                      ...provider.cancellations.map((cancellation) {
                        return Card(
                          child: ListTile(
                            title: Text('Lịch #${cancellation.bookingId}'),
                            subtitle: Text(
                              '${cancellation.reason}\n${DateFormat('dd/MM/yyyy HH:mm').format(cancellation.cancelledAt ?? DateTime.now())}',
                            ),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (cancellation.penalty != null)
                                  Text(
                                    'Phạt: -${formatVnd(cancellation.penalty!)}',
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12),
                                  ),
                                if (cancellation.refundAmount != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Hoàn: +${formatVnd(cancellation.refundAmount!)}',
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12),
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

/// Info card widget for displaying important information
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
