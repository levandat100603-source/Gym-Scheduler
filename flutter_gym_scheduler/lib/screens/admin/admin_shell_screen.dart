import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../member/checkout_screen.dart';
import '../member/memberships_screen.dart';
import '../member/profile_screen.dart';
import '../member/schedules_screen.dart';
import '../member/trainers_screen.dart';
import 'admin_allinfo_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_management_screen.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int mainIndex = 0;
  String adminSection = 'overview';

  final List<_AdminMenuItem> _mainMenu = const [
    _AdminMenuItem('lops', 'Lich tap', Icons.calendar_month_outlined),
    _AdminMenuItem('trainers', 'Huấn luyện viên', Icons.person_outline),
    _AdminMenuItem('memberships', 'Thẻ thành viên', Icons.badge_outlined),
    _AdminMenuItem('profile', 'Hồ sơ', Icons.account_circle_outlined),
    _AdminMenuItem('checkout', 'Giỏ hàng', Icons.shopping_cart_outlined),
  ];

  final List<_AdminMenuItem> _adminMenu = const [
    _AdminMenuItem('overview', 'Tổng quan', Icons.dashboard_outlined),
    _AdminMenuItem('classes', 'Lớp tập', Icons.view_list_outlined),
    _AdminMenuItem('trainers', 'HLV', Icons.fitness_center_outlined),
    _AdminMenuItem('packages', 'Gói tập', Icons.workspace_premium_outlined),
    _AdminMenuItem('members', 'Thành viên', Icons.groups_outlined),
    _AdminMenuItem('bookings', 'Xác nhận lịch', Icons.event_available_outlined),
    _AdminMenuItem('system', 'Thông tin hệ thống', Icons.bar_chart_outlined),
  ];

  List<Widget> get _mainPages => const [
        SchedulesScreen(),
        TrainersScreen(),
        MembershipsScreen(),
        ProfileScreen(),
        CheckoutScreen(),
      ];

  Widget _adminPage() {
    switch (adminSection) {
      case 'classes':
      case 'trainers':
      case 'packages':
      case 'members':
      case 'bookings':
        return AdminManagementScreen(initialTab: adminSection);
      case 'system':
        return const AdminAllInfoScreen();
      case 'overview':
      default:
        return const AdminDashboardScreen();
    }
  }

  void _selectMain(int index) {
    setState(() => mainIndex = index);
    Navigator.of(context).maybePop();
  }

  void _selectAdminSection(String section) {
    setState(() {
      mainIndex = 0;
      adminSection = section;
    });
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('FitZone Gym', style: TextStyle(fontWeight: FontWeight.w800)),
            Text('Hệ thống quản lý', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                    IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    ..._mainMenu.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          tileColor: Colors.teal.withValues(alpha: 0.08),
                          leading: Icon(item.icon, color: Colors.teal.shade800),
                          title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                          onTap: () {
                            final mapping = {
                              'lops': 0,
                              'trainers': 1,
                              'memberships': 2,
                              'profile': 3,
                              'checkout': 4,
                            };
                            _selectMain(mapping[item.id] ?? 0);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Card(
                      margin: EdgeInsets.zero,
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        leading: const Icon(Icons.shield_outlined),
                        title: const Text('Quản trị hệ thống', style: TextStyle(fontWeight: FontWeight.w700)),
                        children: [
                          ..._adminMenu.map(
                            (item) => ListTile(
                              leading: Icon(item.icon, size: 18),
                              title: Text(item.label),
                              onTap: () => _selectAdminSection(item.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await context.read<AuthProvider>().logout();
                        if (!mounted) return;
                        navigator.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (_) => false,
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: mainIndex == 0 ? _adminPage() : _mainPages[mainIndex - 1],
    );
  }
}

class _AdminMenuItem {
  const _AdminMenuItem(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;
}