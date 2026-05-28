import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api_client.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with WidgetsBindingObserver {
  String paymentMethod = 'vnpay_sandbox';
  bool processing = false;
  int? pendingOrderId;
  bool _checkingStatus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && pendingOrderId != null && !_checkingStatus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || pendingOrderId == null || _checkingStatus) return;
        final cart = context.read<CartProvider>();
        checkVnpayStatus(cart);
      });
    }
  }

  Future<void> checkVnpayStatus(CartProvider cart) async {
    if (pendingOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chưa có giao dịch VNPay nào đang chờ')));
      return;
    }

    if (_checkingStatus) return;

    _checkingStatus = true;

    try {
      final res = await ApiClient.instance.dio.get('/checkout/$pendingOrderId/status');
      final data = (res.data as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      final status = data['status']?.toString();

      if (status == 'completed') {
        await cart.clearCart();
        if (!mounted) return;
        setState(() {
          pendingOrderId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('VNPay đã thanh toán thành công')));
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanh toán VNPay chưa hoàn tất.')));
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.response?.data?['message']?.toString() ?? 'Không kiểm tra được trạng thái thanh toán')));
    } finally {
      _checkingStatus = false;
    }
  }

  Future<void> checkout(CartProvider cart) async {
    if (cart.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gio hang trong')));
      return;
    }

    setState(() => processing = true);
    final vat = cart.cartTotal * 0.1;
    final total = cart.cartTotal + vat;

    try {
      final res = await ApiClient.instance.dio.post('/checkout', data: {
        'cart': cart.cart.map((e) => e.toJson()).toList(),
        'payment_method': paymentMethod,
        'total': total,
      });

      final responseData = (res.data as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      final paymentUrl = responseData['payment_url']?.toString().trim() ?? '';
      final orderId = responseData['order_id'];

      if (paymentUrl.isNotEmpty) {
        if (mounted) {
          setState(() {
            pendingOrderId = (orderId as num?)?.toInt();
          });
        }
        if (!mounted) return;

        // Show QR code + link dialog so user can scan or open the payment page
        final dialogResult = await showDialog<String?>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Thanh toán bằng VNPay'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Use a public QR image generator service so user can scan the link
                    Image.network(
                      'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent(paymentUrl)}',
                      width: 200,
                      height: 200,
                      errorBuilder: (c, e, s) => const Icon(Icons.qr_code_rounded, size: 120),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: paymentUrl));
                    Navigator.of(ctx).pop('copied');
                  },
                  child: const Text('Sao chép liên kết'),
                ),
                TextButton(
                  onPressed: () {
                    final uri = Uri.parse(paymentUrl);
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                    Navigator.of(ctx).pop('opened');
                  },
                  child: const Text('Mở trang thanh toán'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );

        if (!mounted) return;
        if (dialogResult == 'copied') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép liên kết thanh toán')));
        } else if (dialogResult == 'opened') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã mở trang thanh toán VNPay. Hoàn tất thanh toán rồi quay lại app.')));
        }
      } else {
        await cart.clearCart();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanh toan thanh cong')));
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.response?.data?['message']?.toString() ?? 'Thanh toan that bai')));
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cart, __) {
        final vat = cart.cartTotal * 0.1;
        final total = cart.cartTotal + vat;

        return Scaffold(
          appBar: AppBar(title: const Text('Thanh toán')),
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              SectionHeader(title: 'Giỏ hàng (${cart.cartCount})', subtitle: 'Kiểm tra dịch vụ trước khi thanh toán'),
              const SizedBox(height: 12),
              if (cart.cart.isEmpty)
                const EmptyState(
                  icon: Icons.remove_shopping_cart_outlined,
                  title: 'Giỏ hàng đang trống',
                  subtitle: 'Bạn chưa chọn lịch tập nào. Hãy khám phá các lớp nổi bật ngay!',
                )
              else
                ...cart.cart.map(
                  (item) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.type} ${item.schedule ?? ''}',
                                  style: const TextStyle(color: Colors.black54),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 88, maxWidth: 108),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatVnd(item.price * (item.quantity ?? 1)),
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 2),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => cart.removeFromCart(item.id, item.type, memberId: item.memberId),
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _line('Tam tinh', formatVnd(cart.cartTotal)),
                      _line('VAT (10%)', formatVnd(vat)),
                      const Divider(),
                      _line('Tong cong', formatVnd(total), bold: true),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: paymentMethod,
                        items: const [
                          DropdownMenuItem(value: 'vnpay_sandbox', child: Text('VNPay Sandbox')),
                          DropdownMenuItem(value: 'bank_transfer', child: Text('Chuyen khoan ngan hang')),
                        ],
                        onChanged: (v) => setState(() => paymentMethod = v ?? paymentMethod),
                        decoration: const InputDecoration(labelText: 'Phuong thuc thanh toan'),
                      ),
                      if (pendingOrderId != null) ...[
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: (processing || _checkingStatus) ? null : () => checkVnpayStatus(cart),
                          icon: const Icon(Icons.verified_outlined),
                          label: Text(_checkingStatus ? 'Đang kiểm tra...' : 'Kiểm tra thanh toán VNPay'),
                        ),
                      ],
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: processing ? null : () => checkout(cart),
                        child: Text(processing ? 'Dang xu ly...' : 'Xac nhan thanh toan'),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _line(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}
