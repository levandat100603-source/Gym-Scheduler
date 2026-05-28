import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import '../main_shell_screen.dart';
import 'verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool remember = false;
  bool hidePassword = true;
  bool hasTriedSubmit = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadRemembered();
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('gym_remember_credentials');
    if (raw == null) return;
    try {
      final data = (jsonDecode(raw) as Map).cast<String, dynamic>();
      setState(() {
        emailCtrl.text = (data['email'] ?? '').toString();
        remember = data['remember'] == true;
      });
    } catch (_) {}
  }

  Future<void> _submit() async {
    setState(() {
      error = null;
      hasTriedSubmit = true;
    });

    if (!formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();

    try {
      if (remember) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'gym_remember_credentials',
          jsonEncode({'email': emailCtrl.text.trim(), 'remember': true}),
        );
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('gym_remember_credentials');
      }

      await auth.login(emailCtrl.text.trim(), passwordCtrl.text.trim());
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
        (_) => false,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 403 && e.response?.data?['requires_verification'] == true) {
        final email = e.response?.data?['email']?.toString() ?? emailCtrl.text.trim();
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email)),
        );
        return;
      }
      setState(() => error = e.response?.data?['message']?.toString() ?? 'Đăng nhập thất bại');
    }
  }

  void _comingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đăng nhập bằng $provider sẽ sớm ra mắt')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthProvider, bool>((a) => a.loading);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade900, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.tealAccent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.lightGreenAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    children: [
                      const Icon(Icons.fitness_center, size: 52, color: Colors.white),
                      const SizedBox(height: 10),
                      const Text('FitZone', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      const Text('Sẵn sàng đổ mồ hôi chưa?', style: TextStyle(color: Colors.white70, fontSize: 15)),
                      const SizedBox(height: 18),
                      Card(
                        elevation: 10,
                        shadowColor: Colors.black.withValues(alpha: 0.35),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Form(
                            key: formKey,
                            autovalidateMode: hasTriedSubmit ? AutovalidateMode.always : AutovalidateMode.disabled,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Đăng nhập', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 6),
                                const Text('Bắt đầu hành trình lột xác ngay hôm nay!', style: TextStyle(color: Colors.blueGrey)),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: emailCtrl,
                                  decoration: const InputDecoration(labelText: 'Email'),
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: passwordCtrl,
                                  obscureText: hidePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Mật khẩu',
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() => hidePassword = !hidePassword),
                                      icon: Icon(hidePassword ? Icons.visibility : Icons.visibility_off),
                                    ),
                                  ),
                                  validator: (value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return 'Vui lòng nhập mật khẩu';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(value: remember, onChanged: (v) => setState(() => remember = v ?? false)),
                                        const Text('Ghi nhớ tài khoản'),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                                      child: const Text('Quên mật khẩu?'),
                                    ),
                                  ],
                                ),
                                if (error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(error!, style: const TextStyle(color: Colors.red)),
                                  ),
                                ElevatedButton(
                                  onPressed: loading ? null : _submit,
                                  child: loading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text('Tiếp tục'),
                                ),
                                const SizedBox(height: 10),
                                const Row(
                                  children: [
                                    Expanded(child: Divider()),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Text('Hoặc'),
                                    ),
                                    Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () => _comingSoon('Google'),
                                  icon: const Icon(Icons.g_mobiledata, size: 26),
                                  label: const Text('Đăng nhập bằng Google'),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () => _comingSoon('Facebook'),
                                  icon: const Icon(Icons.facebook_outlined),
                                  label: const Text('Đăng nhập bằng Facebook'),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Text('Chưa có tài khoản? ', style: TextStyle(color: Colors.blueGrey)),
                                    TextButton(
                                      onPressed: () => Navigator.pushNamed(context, '/register'),
                                      child: const Text('Đăng ký ngay'),
                                    ),
                                  ],
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
            ),
          ),
        ],
      ),
    );
  }
}
