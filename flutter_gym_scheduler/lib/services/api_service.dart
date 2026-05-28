import 'package:dio/dio.dart';

import '../core/api_client.dart';

class ApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<dynamic> get(String path) async {
    final res = await _dio.get(path);
    return res.data;
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? data}) async {
    final res = await _dio.post(path, data: data);
    return res.data;
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? data}) async {
    final res = await _dio.put(path, data: data);
    return res.data;
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required String packageId,
    required double amount,
  }) async {
    final res = await _dio.post('/payments/intent', data: {
      'package_id': packageId,
      'amount': amount,
    });
    return (res.data as Map).cast<String, dynamic>();
  }
}
