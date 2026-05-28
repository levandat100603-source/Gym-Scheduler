import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_theme.dart';
import '../../core/api_client.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> history = {};
  String? _cachedAvatar;
  final passwordFormKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final currentPwdCtrl = TextEditingController();
  final newPwdCtrl = TextEditingController();
  final confirmPwdCtrl = TextEditingController();

  bool savingProfile = false;
  bool savingPassword = false;
  bool _fetchingHistory = false;

  String? _passwordValidator(String? value) {
    final password = (value ?? '').trim();
    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới';
    }
    if (password.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$').hasMatch(password)) {
      return 'Mật khẩu phải có cả chữ cái và số';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final confirmPassword = (value ?? '').trim();
    if (confirmPassword.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu mới';
    }
    if (confirmPassword != newPwdCtrl.text.trim()) {
      return 'Xác nhận mật khẩu không khớp';
    }
    return null;
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

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.teal, width: 1.2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _avatar(String? url) {
    final value = _avatarUrl(url);
    if (value.isEmpty) {
      final auth = context.read<AuthProvider>();
      final localBase64 = (auth.localAvatarBase64 ?? '').trim();
      if (localBase64.isNotEmpty) {
        try {
          final bytes = base64Decode(localBase64);
          return CircleAvatar(radius: 44, backgroundImage: MemoryImage(bytes));
        } catch (_) {
          // fallthrough to default icon
        }
      }
      return const CircleAvatar(radius: 44, child: Icon(Icons.person, size: 40));
    }

    return CircleAvatar(
      radius: 44,
      backgroundImage: NetworkImage(value),
      onBackgroundImageError: (_, __) {},
      child: const Icon(Icons.person, size: 40, color: Colors.transparent),
    );
  }

  @override
  void initState() {
    super.initState();
    _bootstrapLocalUser();
    _loadCachedAvatar();
    fetch();
  }

  void _bootstrapLocalUser() {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    final newHistory = {
      'user_info': {
        'name': user.name,
        'email': user.email,
        'phone': '',
        'avatar': auth.displayAvatar ?? user.avatar,
      },
      'membership': {},
    };
    nameCtrl.text = user.name;
    phoneCtrl.text = '';

    if (mounted) {
      setState(() {
        history = newHistory;
      });
    }
  }

  Future<void> _loadCachedAvatar() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(auth.profileAvatarKey(userId))?.trim() ?? '';
    if (!mounted || cached.isEmpty) return;
    setState(() => _cachedAvatar = cached);
  }

  Future<void> fetch() async {
    if (_fetchingHistory) return;
    _fetchingHistory = true;
    try {
      final res = await ApiClient.instance.dio.get('/user/history');
      final nextHistory = (res.data as Map).cast<String, dynamic>();
      if (!mounted) return;
      setState(() {
        history = nextHistory;
        nameCtrl.text = (history['user_info']?['name'] ?? nameCtrl.text).toString();
        phoneCtrl.text = (history['user_info']?['phone'] ?? phoneCtrl.text).toString();
      });
    } finally {
      _fetchingHistory = false;
    }
  }

  Future<void> saveProfile() async {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => savingProfile = true);
    try {
      final res = await ApiClient.instance.dio.put('/user/profile', data: {
        'name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
      });
      final userData = (res.data['user'] as Map?)?.cast<String, dynamic>();
      if (userData != null) {
        await auth.updateLocalUser(userData);
      }
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Da cap nhat ho so')));
      await fetch();
    } on DioException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.response?.data?['message']?.toString() ?? 'Loi cap nhat')));
    } finally {
      if (mounted) setState(() => savingProfile = false);
    }
  }

  Future<void> changePassword() async {
    if (!passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() => savingPassword = true);
    try {
      await ApiClient.instance.dio.post('/user/change-password', data: {
        'current_password': currentPwdCtrl.text.trim(),
        'new_password': newPwdCtrl.text.trim(),
        'new_password_confirmation': confirmPwdCtrl.text.trim(),
      });
      currentPwdCtrl.clear();
      newPwdCtrl.clear();
      confirmPwdCtrl.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Da doi mat khau')));
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.response?.data?['message']?.toString() ?? 'Doi mat khau that bai')));
    } finally {
      if (mounted) setState(() => savingPassword = false);
    }
  }

  Future<void> uploadAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;

    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    // Save a local preview immediately so user sees the selected image even if backend
    // requires approval and won't return a remote avatar yet.
    try {
      final bytes = await image.readAsBytes();
      final encoded = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      final userId = auth.user?.id;
      if (userId != null) {
        await prefs.setString(auth.profileAvatarLocalKey(userId), encoded);
      }
      // expose to provider for immediate UI update
      auth.localAvatarBase64 = encoded;
      setState(() {});
    } catch (_) {}

    final form = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(image.path, filename: 'avatar.jpg'),
    });

    try {
      final res = await ApiClient.instance.dio.post(
        '/user/avatar',
        data: form,
      );
      final avatar = (res.data as Map?)?['avatar']?.toString();
      if (avatar != null && avatar.isNotEmpty) {
        await auth.updateLocalUser({'avatar': avatar});
        if (mounted) {
          setState(() {
            final userInfo = (history['user_info'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
            userInfo['avatar'] = avatar;
            history['user_info'] = userInfo;
          });
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Da cap nhat avatar')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload avatar that bai')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final appUser = auth.user;
    final userInfo = (history['user_info'] as Map?)?.cast<String, dynamic>() ?? {};
    final membership = (history['membership'] as Map?)?.cast<String, dynamic>() ?? {};
    final authAvatar = (auth.displayAvatar ?? '').trim();
    final historyAvatar = (userInfo['avatar'] ?? '').toString().trim();
    final cachedAvatar = (_cachedAvatar ?? '').trim();
    final profileAvatar = authAvatar.isNotEmpty
      ? authAvatar
      : historyAvatar.isNotEmpty
        ? historyAvatar
        : cachedAvatar;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.text,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            onPressed: fetch,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: fetch,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            _avatar(profileAvatar),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: uploadAvatar,
                              icon: const Icon(Icons.image_outlined),
                              label: const Text('Đổi ảnh đại diện'),
                            ),
                            const SizedBox(height: 8),
                            Text(appUser?.name ?? nameCtrl.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(appUser?.email ?? '', style: const TextStyle(color: Colors.blueGrey)),
                            if (membership.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  '${membership['package'] ?? 'Thành viên'} | Hết hạn ${membership['expiry'] ?? '--'}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Thông tin cơ bản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            TextField(controller: nameCtrl, decoration: _fieldDecoration('Họ và tên')),
                            const SizedBox(height: 16),
                            TextField(enabled: false, controller: TextEditingController(text: appUser?.email ?? ''), decoration: _fieldDecoration('Email')),
                            const SizedBox(height: 16),
                            TextField(controller: phoneCtrl, decoration: _fieldDecoration('Số điện thoại')),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: savingProfile ? null : saveProfile,
                                child: Text(savingProfile ? 'Đang lưu...' : 'Lưu thay đổi'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Form(
                          key: passwordFormKey,
                          autovalidateMode: savingPassword ? AutovalidateMode.always : AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Đổi mật khẩu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: currentPwdCtrl,
                                obscureText: true,
                                decoration: _fieldDecoration('Mật khẩu hiện tại'),
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return 'Vui lòng nhập mật khẩu hiện tại';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: newPwdCtrl,
                                obscureText: true,
                                decoration: _fieldDecoration('Mật khẩu mới'),
                                validator: _passwordValidator,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: confirmPwdCtrl,
                                obscureText: true,
                                decoration: _fieldDecoration('Xác nhận mật khẩu mới'),
                                validator: _confirmPasswordValidator,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: savingPassword ? null : changePassword,
                                  child: Text(savingPassword ? 'Đang cập nhật...' : 'Cập nhật mật khẩu'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_fetchingHistory)
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      ),
    );
  }
}
