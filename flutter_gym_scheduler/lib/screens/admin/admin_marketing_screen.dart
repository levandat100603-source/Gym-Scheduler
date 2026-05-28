import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import '../../providers/admin_management_provider.dart';
import '../../models/app_models_extended.dart';
import '../../widgets/common_widgets.dart';

class AdminMarketingScreen extends StatefulWidget {
  const AdminMarketingScreen({super.key});

  @override
  State<AdminMarketingScreen> createState() => _AdminMarketingScreenState();
}

class _AdminMarketingScreenState extends State<AdminMarketingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AdminManagementProvider _provider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _provider = context.read<AdminManagementProvider>();
    _provider.fetchVouchers();
    _provider.fetchCampaigns();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createVoucher(BuildContext context) async {
    final codeCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final minAmountCtrl = TextEditingController();
    String discountType = 'percentage';
    DateTime? validFrom;
    DateTime? validUntil;
    int? maxUses;
    String selectedApplicable = 'all';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              title: const Text('Tạo mã giảm giá'),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: codeCtrl,
                        decoration: const InputDecoration(labelText: 'Mã voucher'),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: discountType,
                              decoration: const InputDecoration(labelText: 'Loại'),
                              items: const [
                                DropdownMenuItem(value: 'percentage', child: Text('Phần trăm')),
                                DropdownMenuItem(value: 'fixed', child: Text('Số tiền cố định')),
                              ],
                              onChanged: (v) => setState(() => discountType = v ?? discountType),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: valueCtrl,
                              decoration: InputDecoration(
                                labelText: 'Giá trị',
                                suffix: Text(discountType == 'percentage' ? '%' : 'đ'),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: minAmountCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Số tiền tối thiểu (tùy chọn)',
                          suffix: Text('đ'),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('Ngày bắt đầu'),
                        subtitle: Text(validFrom == null ? 'Chọn' : DateFormat('dd/MM/yyyy').format(validFrom!)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setState(() => validFrom = picked);
                        },
                      ),
                      ListTile(
                        title: const Text('Ngày kết thúc'),
                        subtitle: Text(validUntil == null ? 'Chọn' : DateFormat('dd/MM/yyyy').format(validUntil!)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: validFrom ?? DateTime.now(),
                            firstDate: validFrom ?? DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setState(() => validUntil = picked);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedApplicable,
                        decoration: const InputDecoration(labelText: 'Áp dụng cho'),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                          DropdownMenuItem(value: 'new_members', child: Text('Hội viên mới')),
                          DropdownMenuItem(value: 'specific_packages', child: Text('Gói cụ thể')),
                        ],
                        onChanged: (v) => setState(() => selectedApplicable = v ?? selectedApplicable),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: codeCtrl.text.isEmpty || valueCtrl.text.isEmpty
                      ? null
                      : () async {
                          final success = await _provider.createVoucher(
                            code: codeCtrl.text,
                            discountType: discountType,
                            discountValue: double.parse(valueCtrl.text),
                            minOrderAmount: minAmountCtrl.text.isEmpty ? null : double.parse(minAmountCtrl.text),
                            validFrom: validFrom,
                            validUntil: validUntil,
                            applicableTo: selectedApplicable,
                          );
                          if (!mounted) return;
                          Navigator.pop(dialogContext);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mã giảm giá đã được tạo')),
                            );
                            _provider.fetchVouchers();
                          }
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

  Future<void> _createCampaign(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    String targetAudience = 'all';
    DateTime? sendAt;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              title: const Text('Tạo chiến dịch thông báo'),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Tiêu đề'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: messageCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Nội dung tin nhắn',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: targetAudience,
                        decoration: const InputDecoration(labelText: 'Đối tượng'),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Tất cả hội viên')),
                          DropdownMenuItem(value: 'new_members', child: Text('Hội viên mới')),
                          DropdownMenuItem(value: 'inactive', child: Text('Hội viên không hoạt động')),
                        ],
                        onChanged: (v) => setState(() => targetAudience = v ?? targetAudience),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('Gửi lúc'),
                        subtitle: Text(sendAt == null ? 'Gửi ngay' : DateFormat('dd/MM/yyyy HH:mm').format(sendAt!)),
                        trailing: const Icon(Icons.schedule_outlined),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (picked != null) setState(() => sendAt = picked);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: titleCtrl.text.isEmpty || messageCtrl.text.isEmpty
                      ? null
                      : () async {
                          final success = await _provider.createCampaign(
                            title: titleCtrl.text,
                            message: messageCtrl.text,
                            targetAudience: targetAudience,
                            sendAt: sendAt,
                          );
                          if (!mounted) return;
                          Navigator.pop(dialogContext);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chiến dịch đã được tạo')),
                            );
                            _provider.fetchCampaigns();
                          }
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
        title: const Text('Marketing & Khuyến mãi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mã giảm giá'),
            Tab(text: 'Chiến dịch'),
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
              // Vouchers Tab
              RefreshIndicator(
                onRefresh: () => provider.fetchVouchers(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Mã giảm giá',
                      subtitle: 'Quản lý các khuyến mãi và mã giảm giá',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _createVoucher(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Tạo mã mới'),
                    ),
                    const SizedBox(height: 16),
                    if (provider.vouchers.isEmpty)
                      const EmptyState(
                        icon: Icons.local_offer_outlined,
                        title: 'Chưa có mã giảm giá',
                      )
                    else
                      ...provider.vouchers.map((voucher) {
                        final isExpired = voucher.isExpired;
                        final isExhausted = voucher.isExhausted;
                        return Card(
                          child: ListTile(
                            title: Text(voucher.code, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(
                              '${voucher.discountValue.toStringAsFixed(voucher.discountType == 'percentage' ? 0 : 2)}${voucher.discountType == 'percentage' ? '%' : 'đ'} • ${voucher.usedCount}/${voucher.maxUses ?? '∞'} dùng',
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                if (!voucher.isActive)
                                  const Chip(label: Text('Tắt'), backgroundColor: Colors.grey),
                                if (isExpired)
                                  const Chip(label: Text('Hết hạn'), backgroundColor: Colors.red),
                                if (isExhausted)
                                  const Chip(label: Text('Hết'), backgroundColor: Colors.orange),
                              ],
                            ),
                            onTap: () {
                              // Show edit dialog
                            },
                          ),
                        );
                      }),
                  ],
                ),
              ),

              // Campaigns Tab
              RefreshIndicator(
                onRefresh: () => provider.fetchCampaigns(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(
                      title: 'Chiến dịch thông báo',
                      subtitle: 'Gửi thông báo đẩy đến hội viên',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _createCampaign(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Tạo chiến dịch'),
                    ),
                    const SizedBox(height: 16),
                    if (provider.campaigns.isEmpty)
                      const EmptyState(
                        icon: Icons.campaign_outlined,
                        title: 'Chưa có chiến dịch nào',
                      )
                    else
                      ...provider.campaigns.map((campaign) {
                        final statusColor = campaign.status == 'sent'
                            ? Colors.green
                            : campaign.status == 'scheduled'
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
                                    Expanded(
                                      child: Text(
                                        campaign.title,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        campaign.status ?? 'draft',
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(campaign.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Đối tượng: ${campaign.targetAudience ?? 'Tất cả'}',
                                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                    ),
                                    if (campaign.recipientCount != null)
                                      Text(
                                        '${campaign.successCount ?? 0}/${campaign.recipientCount}',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
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
              ),
            ],
          );
        },
      ),
    );
  }
}
