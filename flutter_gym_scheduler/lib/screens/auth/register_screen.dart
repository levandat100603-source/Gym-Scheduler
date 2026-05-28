import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import 'verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool loading = false;
  bool hidePassword = true;
  String? error;
  bool hasTriedSubmit = false;

  String? _passwordValidator(String? value) {
    final password = (value ?? '').trim();
    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (password.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$').hasMatch(password)) {
      return 'Mật khẩu phải có cả chữ cái và số';
    }
    return null;
  }

  Future<void> _register() async {
    setState(() {
      error = null;
      hasTriedSubmit = true;
      loading = true;
    });

    if (!formKey.currentState!.validate()) {
      setState(() => loading = false);
      return;
    }

    if (passwordCtrl.text.trim() != confirmCtrl.text.trim()) {
      setState(() {
        error = 'Mật khẩu xác nhận không khớp';
        loading = false;
      });
      return;
    }

    try {
      final res = await ApiClient.instance.dio.post('/register', data: {
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'password': passwordCtrl.text.trim(),
      });
      final data = (res.data as Map).cast<String, dynamic>();
      if (!mounted) return;
      final pending = data['pending_id'] != null;
      if (pending) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: emailCtrl.text.trim())),
        );
      } else {
        Navigator.of(context).pop();
      }
    } on DioException catch (e) {
      setState(() => error = e.response?.data?['message']?.toString() ?? 'Đăng ký thất bại');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _comingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đăng ký bằng $provider sẽ sớm ra mắt')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            top: -40,
            left: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.tealAccent.withValues(alpha: 0.12),
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
                      const Text('Tạo tài khoản FitZone', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      const Text('Bắt đầu hành trình lột xác ngay hôm nay!', style: TextStyle(color: Colors.white70, fontSize: 14)),
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
                              children: [
                                TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Họ và tên')),
                                const SizedBox(height: 14),
                                TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
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
                                  validator: _passwordValidator,
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: confirmCtrl,
                                  obscureText: hidePassword,
                                  decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu'),
                                  validator: (value) {
                                    final confirm = (value ?? '').trim();
                                    if (confirm.isEmpty) {
                                      return 'Vui lòng nhập lại mật khẩu';
                                    }
                                    if (confirm != passwordCtrl.text.trim()) {
                                      return 'Mật khẩu xác nhận không khớp';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
                                const SizedBox(height: 10),
                                ElevatedButton(onPressed: loading ? null : _register, child: Text(loading ? 'Đang xử lý...' : 'Đăng ký ngay')),
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
                                  label: const Text('Đăng ký bằng Google'),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () => _comingSoon('Facebook'),
                                  icon: const Icon(Icons.facebook_outlined),
                                  label: const Text('Đăng ký bằng Facebook'),
                                ),
                                const SizedBox(height: 6),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Đã có tài khoản? Đăng nhập'),
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
