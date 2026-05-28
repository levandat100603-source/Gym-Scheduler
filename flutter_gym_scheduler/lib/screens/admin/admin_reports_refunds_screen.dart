import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../providers/admin_management_provider.dart';
import '../../widgets/common_widgets.dart';

class AdminReportsAndRefundsScreen extends StatefulWidget {
  const AdminReportsAndRefundsScreen({super.key});

  @override
  State<AdminReportsAndRefundsScreen> createState() => _AdminReportsAndRefundsScreenState();
}

class _AdminReportsAndRefundsScreenState extends State<AdminReportsAndRefundsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AdminManagementProvider _provider;
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _provider = context.read<AdminManagementProvider>();
    selectedFromDate = DateTime.now().subtract(const Duration(days: 30));
    selectedToDate = DateTime.now();
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    await _provider.fetchRefundRequests();
    await _provider.fetchTransactionReports(
      fromDate: selectedFromDate,
      toDate: selectedToDate,
    );
  }

  Future<void> _approveRefund(int refundId, double amount) async {
    final success = await _provider.approveRefund(
      refundId,
      amount,
      refundMethod: 'wallet',
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hoàn tiền đã được phê duyệt')),
      );
    }
  }

  Future<void> _rejectRefund(int refundId) async {
    final success = await _provider.rejectRefund(refundId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yêu cầu hoàn tiền đã bị từ chối')),
      );
    }
  }

  Future<void> _exportReport() async {
    final result = await _provider.exportTransactionReports(
      fromDate: selectedFromDate,
      toDate: selectedToDate,
      format: 'csv',
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tải xuống báo cáo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Báo cáo & Hoàn tiền'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hoàn tiền'),
            Tab(text: 'Giao dịch'),
            Tab(text: 'Thu nhập'),
          ],
        ),
      ),
      body: Consumer<AdminManagementProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Refund Requests Tab
              RefreshIndicator(
                onRefresh: () => provider.fetchRefundRequests(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Yêu cầu hoàn tiền',
                      subtitle: 'Duyệt hoặc từ chối yêu cầu hoàn tiền từ hội viên',
                    ),
                    const SizedBox(height: 16),
                    if (provider.refundRequests.isEmpty)
                      const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Không có yêu cầu nào',
                      )
                    else
                      ...provider.refundRequests
                          .where((r) => r.status == 'pending')
                          .map((refund) {
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
                                      'Hội viên #${refund.memberId}',
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      formatVnd(refund.requestedAmount ?? 0),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.teal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Lý do: ${refund.reason}',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _rejectRefund(refund.id),
                                        child: const Text('Từ chối', style: TextStyle(color: Colors.red)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _approveRefund(refund.id, refund.requestedAmount ?? 0),
                                        child: const Text('Phê duyệt'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                    const Text(
                      'Lịch sử hoàn tiền',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ...provider.refundRequests
                        .where((r) => r.status != 'pending')
                        .map((refund) {
                      final statusColor = refund.status == 'approved'
                          ? Colors.green
                          : refund.status == 'processed'
                              ? Colors.blue
                              : Colors.red;
                      return Card(
                        child: ListTile(
                          title: Text('Yêu cầu #${refund.id}'),
                          subtitle: Text('${refund.reason} • ${formatVnd(refund.approvedAmount ?? 0)}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              refund.status ?? 'unknown',
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 11),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Transactions Tab
              RefreshIndicator(
                onRefresh: _loadReports,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Báo cáo giao dịch',
                      subtitle: 'Chi tiết tất cả giao dịch',
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: const Text('Từ'),
                                    subtitle: Text(
                                      selectedFromDate == null
                                          ? 'Chọn'
                                          : DateFormat('dd/MM/yyyy').format(selectedFromDate!),
                                    ),
                                    trailing: const Icon(Icons.calendar_today),
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: selectedFromDate ?? DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) setState(() => selectedFromDate = picked);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: ListTile(
                                    title: const Text('Đến'),
                                    subtitle: Text(
                                      selectedToDate == null
                                          ? 'Chọn'
                                          : DateFormat('dd/MM/yyyy').format(selectedToDate!),
                                    ),
                                    trailing: const Icon(Icons.calendar_today),
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: selectedToDate ?? DateTime.now(),
                                        firstDate: selectedFromDate ?? DateTime(2020),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) setState(() => selectedToDate = picked);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _loadReports,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Làm mới'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _exportReport,
                                    icon: const Icon(Icons.download_outlined),
                                    label: const Text('Tải xuống'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (provider.transactionReports.isEmpty)
                      const EmptyState(
                        icon: Icons.receipt_outlined,
                        title: 'Không có giao dịch',
                      )
                    else
                      ...provider.transactionReports.map((report) {
                        return Card(
                          child: ListTile(
                            title: Text(report.type ?? 'Giao dịch'),
                            subtitle: Text(
                              '${DateFormat('dd/MM/yyyy HH:mm').format(report.date)}\n${report.description ?? ''}',
                            ),
                            isThreeLine: true,
                            trailing: Text(
                              formatVnd(report.amount ?? 0),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: (report.amount ?? 0) > 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),

              // Revenue Stats Tab
              FutureBuilder<Map<String, dynamic>?>(
                future: _provider.getRevenueStats(
                  fromDate: selectedFromDate,
                  toDate: selectedToDate,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final stats = snapshot.data;
                  if (stats == null) {
                    return const Center(child: Text('Không thể tải dữ liệu'));
                  }

                  final totalRevenue = (stats['total_revenue'] as num?)?.toDouble() ?? 0;
                  final totalBookings = (stats['total_bookings'] as num?)?.toInt() ?? 0;
                  final avgOrderValue = (stats['avg_order_value'] as num?)?.toDouble() ?? 0;

                  return RefreshIndicator(
                    onRefresh: _loadReports,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const SectionHeader(
                          title: 'Thống kê thu nhập',
                          subtitle: 'Tóm tắt doanh thu trong khoảng thời gian',
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                          children: [
                            _statTile('Doanh thu', formatVnd(totalRevenue), Colors.teal),
                            _statTile('Giao dịch', totalBookings.toString(), Colors.blue),
                            _statTile('Trung bình', formatVnd(avgOrderValue), Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(Icons.trending_up, color: color, size: 24),
            ),
            Column(
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
