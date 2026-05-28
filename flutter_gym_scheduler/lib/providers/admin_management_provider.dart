import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/app_models_extended.dart';

/// Provider for Admin management features: vouchers, campaigns, reports, etc.
class AdminManagementProvider extends ChangeNotifier {
  List<Voucher> vouchers = [];
  List<PushCampaign> campaigns = [];
  List<RefundRequest> refundRequests = [];
  List<TransactionReport> transactionReports = [];

  bool loading = false;
  String? error;

  // ===== VOUCHERS =====
  Future<void> fetchVouchers() async {
    loading = true;
    notifyListeners();
    try {
      final res = await ApiClient.instance.dio.get('/admin/vouchers');
      vouchers = (res.data as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map((e) => Voucher.fromJson(e))
          .toList();
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message']?.toString() ?? 'Failed to load vouchers';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> createVoucher({
    required String code,
    required String discountType,    // percentage or fixed
    required double discountValue,
    int? maxUses,
    double? minOrderAmount,
    DateTime? validFrom,
    DateTime? validUntil,
    String? applicableTo,
  }) async {
    try {
      final res = await ApiClient.instance.dio.post('/admin/vouchers/create', data: {
        'code': code,
        'discount_type': discountType,
        'discount_value': discountValue,
        'max_uses': maxUses,
        'min_order_amount': minOrderAmount,
        'valid_from': validFrom?.toIso8601String(),
        'valid_until': validUntil?.toIso8601String(),
        'applicable_to': applicableTo,
      });
      final voucher = Voucher.fromJson(res.data as Map<String, dynamic>);
      vouchers.add(voucher);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> updateVoucher(int voucherId, {
    String? code,
    String? discountType,
    double? discountValue,
    int? maxUses,
    double? minOrderAmount,
    DateTime? validFrom,
    DateTime? validUntil,
    bool? isActive,
  }) async {
    try {
      final res = await ApiClient.instance.dio.put('/admin/vouchers/$voucherId', data: {
        'code': code,
        'discount_type': discountType,
        'discount_value': discountValue,
        'max_uses': maxUses,
        'min_order_amount': minOrderAmount,
        'valid_from': validFrom?.toIso8601String(),
        'valid_until': validUntil?.toIso8601String(),
        'is_active': isActive,
      });
      final updated = Voucher.fromJson(res.data as Map<String, dynamic>);
      final index = vouchers.indexWhere((v) => v.id == voucherId);
      if (index >= 0) {
        vouchers[index] = updated;
        notifyListeners();
      }
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> deleteVoucher(int voucherId) async {
    try {
      await ApiClient.instance.dio.delete('/admin/vouchers/$voucherId');
      vouchers.removeWhere((v) => v.id == voucherId);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  // ===== PUSH CAMPAIGNS =====
  Future<void> fetchCampaigns() async {
    loading = true;
    notifyListeners();
    try {
      final res = await ApiClient.instance.dio.get('/admin/campaigns');
      campaigns = (res.data as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map((e) => PushCampaign.fromJson(e))
          .toList();
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message']?.toString() ?? 'Failed to load campaigns';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> createCampaign({
    required String title,
    required String message,
    String? targetAudience,
    DateTime? sendAt,
  }) async {
    try {
      final res = await ApiClient.instance.dio.post('/admin/campaigns/create', data: {
        'title': title,
        'message': message,
        'target_audience': targetAudience ?? 'all',
        'send_at': sendAt?.toIso8601String(),
      });
      final campaign = PushCampaign.fromJson(res.data as Map<String, dynamic>);
      campaigns.add(campaign);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> scheduleCampaign(int campaignId, DateTime sendAt) async {
    try {
      await ApiClient.instance.dio.post('/admin/campaigns/$campaignId/schedule', data: {
        'send_at': sendAt.toIso8601String(),
      });
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> sendCampaignNow(int campaignId) async {
    try {
      await ApiClient.instance.dio.post('/admin/campaigns/$campaignId/send-now');
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> deleteCampaign(int campaignId) async {
    try {
      await ApiClient.instance.dio.delete('/admin/campaigns/$campaignId');
      campaigns.removeWhere((c) => c.id == campaignId);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  // ===== REFUND REQUESTS =====
  Future<void> fetchRefundRequests() async {
    loading = true;
    notifyListeners();
    try {
      final res = await ApiClient.instance.dio.get('/admin/refund-requests');
      refundRequests = (res.data as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map((e) => RefundRequest.fromJson(e))
          .toList();
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message']?.toString() ?? 'Failed to load refund requests';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> approveRefund(
    int refundId,
    double approvedAmount, {
    String? refundMethod,
    String? notes,
  }) async {
    try {
      await ApiClient.instance.dio.post('/admin/refund-requests/$refundId/approve', data: {
        'approved_amount': approvedAmount,
        'refund_method': refundMethod ?? 'wallet',
        'notes': notes,
      });
      final index = refundRequests.indexWhere((r) => r.id == refundId);
      if (index >= 0) {
        refundRequests[index] = RefundRequest(
          id: refundRequests[index].id,
          bookingId: refundRequests[index].bookingId,
          memberId: refundRequests[index].memberId,
          reason: refundRequests[index].reason,
          status: 'approved',
          approvedAmount: approvedAmount,
        );
        notifyListeners();
      }
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> rejectRefund(int refundId, [String? reason]) async {
    try {
      await ApiClient.instance.dio.post('/admin/refund-requests/$refundId/reject', data: {
        'reason': reason,
      });
      final index = refundRequests.indexWhere((r) => r.id == refundId);
      if (index >= 0) {
        refundRequests[index] = RefundRequest(
          id: refundRequests[index].id,
          bookingId: refundRequests[index].bookingId,
          memberId: refundRequests[index].memberId,
          reason: refundRequests[index].reason,
          status: 'rejected',
        );
        notifyListeners();
      }
      return true;
    } on DioException {
      return false;
    }
  }

  // ===== TRANSACTION REPORTS =====
  Future<void> fetchTransactionReports({
    DateTime? fromDate,
    DateTime? toDate,
    String? type,
  }) async {
    loading = true;
    notifyListeners();
    try {
      final params = <String, dynamic>{};
      if (fromDate != null) params['from_date'] = fromDate.toIso8601String();
      if (toDate != null) params['to_date'] = toDate.toIso8601String();
      if (type != null) params['type'] = type;

      final res = await ApiClient.instance.dio.get(
        '/admin/reports/transactions',
        queryParameters: params,
      );
      transactionReports = (res.data as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map((e) => TransactionReport.fromJson(e))
          .toList();
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message']?.toString() ?? 'Failed to load reports';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> exportTransactionReports({
    DateTime? fromDate,
    DateTime? toDate,
    String? format = 'csv',
  }) async {
    try {
      final params = <String, dynamic>{'format': format};
      if (fromDate != null) params['from_date'] = fromDate.toIso8601String();
      if (toDate != null) params['to_date'] = toDate.toIso8601String();

      final res = await ApiClient.instance.dio.get(
        '/admin/reports/transactions/export',
        queryParameters: params,
        options: Options(responseType: ResponseType.bytes),
      );
      // Return file path or download URL (implementation depends on backend)
      return res.data?.toString();
    } on DioException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRevenueStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (fromDate != null) params['from_date'] = fromDate.toIso8601String();
      if (toDate != null) params['to_date'] = toDate.toIso8601String();

      final res = await ApiClient.instance.dio.get(
        '/admin/reports/revenue-stats',
        queryParameters: params,
      );
      return res.data as Map<String, dynamic>?;
    } on DioException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTrainerPayrollStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (fromDate != null) params['from_date'] = fromDate.toIso8601String();
      if (toDate != null) params['to_date'] = toDate.toIso8601String();

      final res = await ApiClient.instance.dio.get(
        '/admin/reports/trainer-payroll',
        queryParameters: params,
      );
      return res.data as Map<String, dynamic>?;
    } on DioException {
      return null;
    }
  }
}
