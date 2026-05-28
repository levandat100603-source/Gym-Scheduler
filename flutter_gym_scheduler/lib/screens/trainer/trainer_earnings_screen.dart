import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../providers/trainer_management_provider.dart';
import '../../widgets/common_widgets.dart';

class TrainerEarningsScreen extends StatefulWidget {
  const TrainerEarningsScreen({super.key, required this.trainerId});

  final int trainerId;

  @override
  State<TrainerEarningsScreen> createState() => _TrainerEarningsScreenState();
}

class _TrainerEarningsScreenState extends State<TrainerEarningsScreen> {
  late TrainerManagementProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<TrainerManagementProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider.fetchEarnings(widget.trainerId);
    });
  }

  Future<void> _requestWithdrawal(BuildContext context, double availableBalance) async {
    final amountCtrl = TextEditingController();
    String selectedMethod = 'bank_transfer';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              title: const Text('Yêu cầu rút tiền'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Số dư khả dụng: ${formatVnd(availableBalance)}'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Số tiền cần rút',
                        prefixText: 'đ ',
                        hintText: '0',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedMethod,
                      decoration: const InputDecoration(labelText: 'Phương thức'),
                      items: const [
                        DropdownMenuItem(value: 'bank_transfer', child: Text('Chuyển khoản ngân hàng')),
                        DropdownMenuItem(value: 'wallet', child: Text('Ví điện tử')),
                      ],
                      onChanged: (v) => setState(() => selectedMethod = v ?? selectedMethod),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: amountCtrl.text.isEmpty
                      ? null
                      : () async {
                          final amount = double.tryParse(amountCtrl.text) ?? 0;
                          if (amount <= 0 || amount > availableBalance) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Số tiền không hợp lệ')),
                            );
                            return;
                          }
                          final success = await _provider.requestWithdrawal(widget.trainerId, amount);
                          if (!mounted) return;
                          Navigator.pop(dialogContext);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Yêu cầu rút tiền đã được gửi')),
                            );
                          }
                        },
                  child: const Text('Yêu cầu'),
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
        title: const Text('Thu nhập & Ví'),
      ),
      body: Consumer<TrainerManagementProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final earnings = provider.earnings;
          if (earnings == null) {
            return const Center(child: Text('Không thể tải dữ liệu'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchEarnings(widget.trainerId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Revenue Overview Cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _statCard(
                      label: 'Tổng thu nhập',
                      value: formatVnd(earnings.totalEarnings),
                      icon: Icons.attach_money_outlined,
                      color: Colors.teal,
                    ),
                    _statCard(
                      label: 'Buổi hoàn thành',
                      value: earnings.completedSessions.toString(),
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    _statCard(
                      label: 'Buổi chờ xử lý',
                      value: earnings.pendingSessions.toString(),
                      icon: Icons.schedule_outlined,
                      color: Colors.orange,
                    ),
                    _statCard(
                      label: 'Buổi bị hủy',
                      value: earnings.cancelledSessions.toString(),
                      icon: Icons.cancel_outlined,
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Wallet Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ví của tôi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.teal.shade700, Colors.teal.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Số dư khả dụng',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatVnd(earnings.withdrawalBalance ?? 0),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _requestWithdrawal(context, earnings.withdrawalBalance ?? 0),
                            icon: const Icon(Icons.wallet_outlined),
                            label: const Text('Yêu cầu rút tiền'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Performance Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tóm tắt hiệu suất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        _performanceLine(
                          'Tỷ lệ hoàn thành',
                          earnings.completedSessions > 0
                              ? '${(earnings.completedSessions / (earnings.completedSessions + earnings.pendingSessions + earnings.cancelledSessions) * 100).toStringAsFixed(1)}%'
                              : '0%',
                        ),
                        _performanceLine(
                          'Buổi tập trung bình/tháng',
                          earnings.completedSessions > 0
                              ? (earnings.completedSessions / 12).toStringAsFixed(1)
                              : '0',
                        ),
                        _performanceLine(
                          'Thu nhập trung bình/buổi',
                          earnings.completedSessions > 0
                              ? formatVnd(earnings.totalEarnings / earnings.completedSessions)
                              : formatVnd(0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Rating Section (placeholder)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Đánh giá từ học viên', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 32),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('4.8 trên 5', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                const Text('Dựa trên 24 đánh giá', style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            // View detailed ratings
                          },
                          icon: const Icon(Icons.rate_review_outlined),
                          label: const Text('Xem chi tiết đánh giá'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(
    {required String label,
    required String value,
    required IconData icon,
    required Color color}
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _performanceLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.teal)),
        ],
      ),
    );
  }
}
