import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool loading = false;
  String step = 'send-code';
  String? error;

  Future<void> sendCode() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await ApiClient.instance.dio.post('/forgot-password', data: {'email': emailCtrl.text.trim()});
      setState(() => step = 'reset-password');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi mã 8 ký tự qua email')));
    } on DioException catch (e) {
      setState(() => error = e.response?.data?['message']?.toString() ?? 'Không thể gửi mã');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> resetPassword() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await ApiClient.instance.dio.post('/reset-password', data: {
        'email': emailCtrl.text.trim(),
        'token': codeCtrl.text.trim().toUpperCase(),
        'password': newPasswordCtrl.text.trim(),
        'password_confirmation': confirmPasswordCtrl.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đặt lại mật khẩu thành công')));
      Navigator.of(context).pop();
    } on DioException catch (e) {
      setState(() => error = e.response?.data?['message']?.toString() ?? 'Đặt lại thất bại');
    } finally {
      if (mounted) setState(() => loading = false);
    }
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.black.withValues(alpha: 0.35),
                    margin: const EdgeInsets.all(4),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quên mật khẩu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          const Text('Lấy lại tài khoản để tiếp tục hành trình tập luyện', style: TextStyle(color: Colors.blueGrey)),
                          const SizedBox(height: 14),
                          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                          const SizedBox(height: 14),
                          if (step == 'reset-password') ...[
                            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Mã reset (8 ký tự)')),
                            const SizedBox(height: 14),
                            TextField(controller: newPasswordCtrl, decoration: const InputDecoration(labelText: 'Mật khẩu mới'), obscureText: true),
                            const SizedBox(height: 14),
                            TextField(controller: confirmPasswordCtrl, decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu'), obscureText: true),
                            const SizedBox(height: 14),
                          ],
                          if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: loading ? null : (step == 'send-code' ? sendCode : resetPassword),
                            child: Text(step == 'send-code' ? 'Gửi mã đặt lại' : 'Cập nhật mật khẩu'),
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Quay lại đăng nhập'),
                          ),
                        ],
                      ),
                    ),
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
