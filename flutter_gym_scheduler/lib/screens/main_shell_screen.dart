import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_management_screen.dart';
import 'auth/login_screen.dart';
import 'member/checkout_screen.dart';
import 'member/member_bookings_screen.dart';
import 'member/memberships_screen.dart';
import 'member/notifications_screen.dart';
import 'member/profile_screen.dart';
import 'member/schedules_screen.dart';
import 'member/trainers_screen.dart';
import 'trainer/trainer_classes_screen.dart';
import 'trainer/pending_bookings_screen.dart';
import 'trainer/trainer_availability_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int bottomNavIndex = 0;
  int adminDrawerIndex = 0;
  String? _cachedAvatar;
  int _avatarRetryCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCachedAvatar();
    _warmupDrawerAvatar();
  }

  Future<void> _loadCachedAvatar() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(auth.profileAvatarKey(userId))?.trim() ?? '';
    if (!mounted) return;
    setState(() => _cachedAvatar = cached.isNotEmpty ? cached : null);
  }

  void _warmupDrawerAvatar() {
    Future<void>.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final hasAvatar = (auth.displayAvatar ?? '').trim().isNotEmpty;
      if (hasAvatar || _avatarRetryCount >= 6) return;

      _avatarRetryCount += 1;
      await auth.ensureProfileLoaded();
      if (!mounted) return;
      _warmupDrawerAvatar();
    });
  }

  String _avatarUrl(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return '';
    final baseUrl = ApiClient.instance.dio.options.baseUrl.replaceAll('/api', '');
    final baseUri = Uri.tryParse(baseUrl);
    final revision = context.read<AuthProvider>().avatarRevision;

    String appendRevision(String url) {
      if (revision <= 0) return url;
      final separator = url.contains('?') ? '&' : '?';
      return '$url${separator}v=$revision';
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      final rawUri = Uri.tryParse(raw);
      final isLocalHost = rawUri != null && (rawUri.host == '127.0.0.1' || rawUri.host == 'localhost');
      if (isLocalHost && baseUri != null) {
        return appendRevision(rawUri.replace(
          scheme: baseUri.scheme,
          host: baseUri.host,
          port: baseUri.hasPort ? baseUri.port : null,
        ).toString());
      }
      return appendRevision(raw);
    }

    if (raw.startsWith('/')) {
      return appendRevision('$baseUrl$raw');
    }
    return appendRevision('$baseUrl/$raw');
  }

  Widget _drawerAvatar(String? name, String? avatar) {
    final firstChar = ((name ?? 'U').trim().isEmpty ? 'U' : (name ?? 'U').trim().substring(0, 1)).toUpperCase();
    final avatarValue = (avatar ?? '').trim().isNotEmpty ? avatar : _cachedAvatar;
    final avatarUrl = _avatarUrl(avatarValue);
    final localBase64 = context.read<AuthProvider>().localAvatarBase64;

    if (localBase64 != null && localBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(localBase64);
        return CircleAvatar(
          radius: 36,
          backgroundColor: Colors.grey[300],
          backgroundImage: MemoryImage(bytes),
          child: Text(
            firstChar,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.transparent),
          ),
        );
      } catch (_) {
        // ignore and fall back to network
      }
    }

    if (avatarUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: Text(
          firstChar,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      );
    }

    return CircleAvatar(
      radius: 36,
      backgroundColor: Colors.grey[300],
      backgroundImage: NetworkImage(avatarUrl),
      onBackgroundImageError: (_, __) {},
      child: Text(
        firstChar,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.transparent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final role = user?.role ?? 'member';
    final cartCount = context.watch<CartProvider>().cartCount;
    const notificationCount = 0;
    final displayAvatar = auth.displayAvatar;

    // Fetch avatar early if not yet loaded
    if ((displayAvatar ?? '').trim().isEmpty && user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (context.read<AuthProvider>().displayAvatar ?? '').trim().isEmpty) {
          context.read<AuthProvider>().ensureProfileLoaded();
        }
      });
    }

    // ===== Định nghĩa các tab cho từng vai trò =====
    final memberTabs = <Widget>[
      const SchedulesScreen(),      // 0: Lớp học
      const TrainersScreen(),       // 1: HLV
      const MembershipsScreen(),    // 2: Gói tập
      const MemberBookingsScreen(), // 3: Lịch đặt
    ];

    final trainerTabs = <Widget>[
      TrainerClassesScreen(trainerId: user?.id ?? 0),      // 0: Lớp của tôi
      const PendingBookingsScreen(),                       // 1: Booking
      TrainerAvailabilityScreen(trainerId: user?.id ?? 0),  // 2: Khung giờ
    ];

    // Admin drawer screens
    final adminDrawerScreens = <Widget>[
      const AdminDashboardScreen(),      // 0: Tổng quan
      const AdminManagementScreen(),     // 1: Quản trị tổng
      const AdminManagementScreen(initialTab: 'classes'),    // 2: Lớp tập
      const AdminManagementScreen(initialTab: 'trainers'),    // 3: HLV
      const AdminManagementScreen(initialTab: 'trainer_schedules'), // 4: Lịch làm HLV
      const AdminManagementScreen(initialTab: 'packages'),    // 5: Gói tập
      const AdminManagementScreen(initialTab: 'members'),     // 6: Thành viên
      const AdminManagementScreen(initialTab: 'bookings'),    // 7: Booking
      const ProfileScreen(),             // 8: Hồ sơ
    ];

    final adminBottomNavScreens = <Widget>[
      const SchedulesScreen(),           // 0: Lớp tập
      const TrainersScreen(),            // 1: HLV
      const MembershipsScreen(),         // 2: Gói tập
    ];

    // ===== Lựa chọn các tab dựa trên vai trò =====
    final pages = role == 'admin'
        ? adminBottomNavScreens
        : role == 'trainer'
            ? trainerTabs
            : memberTabs;

    final navItems = role == 'admin'
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Lop tap',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_mma_outlined),
              label: 'HLV',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.workspace_premium_outlined),
              label: 'Goi tap',
            ),
          ]
        : role == 'trainer'
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.class_outlined),
                  label: 'Lớp của tôi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  label: 'Booking',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.schedule_outlined),
                  label: 'Khung giờ',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  label: 'Lop hoc',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_mma_outlined),
                  label: 'HLV',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.workspace_premium_outlined),
                  label: 'Goi tap',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_outline),
                  label: 'Lich dat',
                ),
              ];

    if (bottomNavIndex >= pages.length) bottomNavIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('FitZone - ${user?.name ?? ''}'),
        elevation: 0,
      ),
      drawer: _buildDrawer(
        context,
        user,
        role,
        adminDrawerScreens,
        cartCount,
        notificationCount,
        displayAvatar,
      ),
      body: IndexedStack(
        index: bottomNavIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomNavIndex,
        type: BottomNavigationBarType.fixed,
        items: navItems,
        onTap: (v) => setState(() => bottomNavIndex = v),
      ),
    );
  }

  // ===== Xây dựng Drawer dựa trên vai trò =====
  Widget _buildDrawer(
    BuildContext context,
    dynamic user,
    String role,
    List<Widget> adminDrawerScreens,
    int cartCount,
    int notificationCount,
    String? displayAvatar,
  ) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    currentAccountPicture: _drawerAvatar(user?.name, displayAvatar),
                    accountName: Text(user?.name ?? 'Người dùng'),
                    accountEmail: Text(user?.email ?? ''),
                  ),

                  if (role == 'admin') ...[
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: const Icon(Icons.dashboard_outlined),
                      title: const Text('Tổng quan'),
                      selected: adminDrawerIndex == 0,
                      onTap: () {
                        setState(() => adminDrawerIndex = 0);
                        Navigator.pop(context);
                        _showAdminDrawerScreen(context, adminDrawerScreens[0]);
                      },
                    ),
                    ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.manage_accounts_outlined),
                      title: const Text('Quản lý'),
                      initiallyExpanded: false,
                      controlAffinity: ListTileControlAffinity.trailing,
                      expandedAlignment: Alignment.centerLeft,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.only(left: 40),
                          leading: const Icon(Icons.calendar_month_outlined, size: 20),
                          title: const Text('Lớp tập'),
                          onTap: () {
                            Navigator.pop(context);
                            _showAdminDrawerScreen(context, adminDrawerScreens[2]);
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.only(left: 40),
                          leading: const Icon(Icons.sports_mma_outlined, size: 20),
                          title: const Text('HLV'),
                          onTap: () {
                            Navigator.pop(context);
                            _showAdminDrawerScreen(context, adminDrawerScreens[3]);
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.only(left: 40),
                          leading: const Icon(Icons.schedule_outlined, size: 20),
                          title: const Text('Lịch làm HLV'),
                          onTap: () {
                            Navigator.pop(context);
                            _showAdminDrawerScreen(context, adminDrawerScreens[4]);
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.only(left: 40),
                          leading: const Icon(Icons.workspace_premium_outlined, size: 20),
                          title: const Text('Gói tập'),
                          onTap: () {
                            Navigator.pop(context);
                            _showAdminDrawerScreen(context, adminDrawerScreens[5]);
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.only(left: 40),
                          leading: const Icon(Icons.people_outline, size: 20),
                          title: const Text('Thành viên'),
                          onTap: () {
                            Navigator.pop(context);
                            _showAdminDrawerScreen(context, adminDrawerScreens[6]);
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.only(left: 40),
                          leading: const Icon(Icons.event_note_outlined, size: 20),
                          title: const Text('Booking'),
                          onTap: () {
                            Navigator.pop(context);
                            _showAdminDrawerScreen(context, adminDrawerScreens[7]);
                          },
                        ),
                      ],
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Hồ sơ'),
                      selected: adminDrawerIndex == 8,
                      selectedColor: Colors.teal,
                      selectedTileColor: Colors.teal.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onTap: () {
                        setState(() => adminDrawerIndex = 8);
                        Navigator.pop(context);
                        _showAdminDrawerScreen(context, adminDrawerScreens[8]);
                      },
                    ),
                  ],

                  if (role != 'admin') ...[
                    ListTile(
                      leading: Badge(
                        isLabelVisible: notificationCount > 0,
                        label: Text('$notificationCount'),
                        child: const Icon(Icons.notifications_outlined),
                      ),
                      title: const Text('Thông báo'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                    ),
                  ],

                  if (role != 'admin') ...[
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Hồ sơ'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                    ),
                  ],

                  if (role != 'trainer') ...[
                    ListTile(
                      leading: Badge(
                        isLabelVisible: cartCount > 0,
                        label: Text('$cartCount'),
                        child: const Icon(Icons.shopping_cart_outlined),
                      ),
                      title: const Text('Giỏ hàng'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                        );
                      },
                    ),
                  ],

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Trợ giúp và hỗ trợ'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Liên hệ: support@fitzone.com')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Về chúng tôi'),
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
              ),
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;
    if (!context.mounted) return;

    Navigator.pop(context);
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  // Hiển thị một màn hình từ Drawer của Admin
  void _showAdminDrawerScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  // Hiển thị About Dialog
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FitZone',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 FitZone. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text('FitZone - Ung dung quan ly phong tap gym va lich tren lai.'),
      ],
    );
  }
}
