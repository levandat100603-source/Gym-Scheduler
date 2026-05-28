import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../models/app_models.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common_widgets.dart';

class MembershipsScreen extends StatefulWidget {
  const MembershipsScreen({super.key});

  @override
  State<MembershipsScreen> createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends State<MembershipsScreen> {
  bool loading = true;
  List<MembershipPackage> packages = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      setState(() => loading = true);
      final res = await ApiClient.instance.dio.get('/packages');
      final list = (res.data as List).cast<dynamic>();
      final activeOnly = list
          .map((e) => (e as Map).cast<String, dynamic>())
          .where((e) => (e['status'] ?? 'active').toString().toLowerCase() == 'active')
          .map(MembershipPackage.fromJson)
          .toList();
      setState(() => packages = activeOnly);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: fetch,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const SectionHeader(title: 'Gói thành viên', subtitle: 'Basic, Standard, Premium, VIP từ backend Laravel'),
          const SizedBox(height: 12),
          if (packages.isEmpty)
            const EmptyState(
              icon: Icons.workspace_premium_outlined,
              title: 'Chưa có gói nào',
              subtitle: 'Hãy quay lại sau để xem các gói tập mới nhất.',
            )
          else
            ...packages.map(
              (p) => Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: AppTheme.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 110,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.teal.shade700,
                                Colors.teal.shade400,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              const Icon(Icons.fitness_center, color: Colors.white, size: 36),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                          if (p.isPopular)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(999)),
                              child: const Text('Phổ biến', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.brown)),
                            )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formatVnd(p.price)} | ${p.duration} tháng',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.teal, fontSize: 17),
                      ),
                      if (p.oldPrice != null)
                        Text(
                          'Giá gốc: ${formatVnd(p.oldPrice!)}',
                          style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.blueGrey),
                        ),
                      const SizedBox(height: 8),
                      ...p.benefits.take(4).map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(children: [const Icon(Icons.check, size: 16, color: Colors.green), const SizedBox(width: 6), Expanded(child: Text(b))]),
                          )),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await context.read<CartProvider>().addToCart(
                                CartItem(
                                  id: p.id,
                                  name: p.name,
                                  price: p.price,
                                  type: 'membership',
                                  schedule: '${p.duration} tháng',
                                ),
                              );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm ${p.name} vào giỏ hàng')));
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Đăng ký ngay'),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
