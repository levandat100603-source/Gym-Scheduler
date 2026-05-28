import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static String _baseUrl() {
    const env = String.fromEnvironment('API_URL');
    if (env.isNotEmpty) {
      return env.endsWith('/api') ? env : '$env/api';
    }
    // Use production backend in release builds; keep local fallback for debug/dev.
    if (kReleaseMode) {
      return 'https://gym-scheduler-3kbu.onrender.com/api';
    }
    // Local development backend - change to your backend URL
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api'; // Android emulator reaches host via this
    }
    if (Platform.isIOS) {
      return 'http://127.0.0.1:8000/api';
    }
    return 'http://127.0.0.1:8000/api'; // For testing/web
  }

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
      headers: {'Accept': 'application/json'},
    ),
  );

  Future<void> init() async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null && token.isNotEmpty && options.headers['Authorization'] == null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }
}
