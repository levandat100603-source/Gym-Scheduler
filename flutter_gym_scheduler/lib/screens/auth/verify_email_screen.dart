import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../providers/auth_provider.dart';
import '../main_shell_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final codeCtrl = TextEditingController();
  int seconds = 60;
  bool loading = false;
  bool resendLoading = false;
  String? error;
  String? success;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  Future<void> _tick() async {
    while (mounted && seconds > 0) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => seconds -= 1);
    }
  }

  Future<void> verify() async {
    final auth = context.read<AuthProvider>();
    setState(() {
      error = null;
      success = null;
      loading = true;
    });

    try {
      final res = await ApiClient.instance.dio.post('/verify-email', data: {
        'email': widget.email,
        'code': codeCtrl.text.trim(),
      });

      await auth.applyAuthResponse((res.data as Map).cast<String, dynamic>());
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
        (_) => false,
      );
    } on DioException catch (e) {
      setState(() => error = e.response?.data?['message']?.toString() ?? 'Xac thuc that bai');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> resendCode() async {
    setState(() {
      resendLoading = true;
      error = null;
      success = null;
    });
    try {
      await ApiClient.instance.dio.post('/send-verification-code', data: {'email': widget.email});
      setState(() {
        success = 'Da gui lai ma xac thuc';
        seconds = 60;
      });
      _tick();
    } on DioException catch (e) {
      setState(() => error = e.response?.data?['message']?.toString() ?? 'Khong the gui lai ma');
    } finally {
      if (mounted) setState(() => resendLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expired = seconds <= 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Xac thuc email')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${widget.email}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(expired ? 'Ma da het han' : 'Ma het han sau $seconds giay'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: codeCtrl,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ma xac thuc'),
                  ),
                  if (error != null) Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(error!, style: const TextStyle(color: Colors.red)),
                  ),
                  if (success != null) Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(success!, style: const TextStyle(color: Colors.green)),
                  ),
                  ElevatedButton(onPressed: loading || expired ? null : verify, child: loading ? const CircularProgressIndicator() : const Text('Xac thuc')),
                  TextButton(onPressed: resendLoading ? null : resendCode, child: Text(resendLoading ? 'Dang gui...' : 'Gui lai ma')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
