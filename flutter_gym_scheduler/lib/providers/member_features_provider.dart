import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/app_models_extended.dart';

/// Provider for Member enhanced features: waitlist, freeze, check-in, etc.
class MemberFeaturesProvider extends ChangeNotifier {
  List<WaitlistEntry> waitlistEntries = [];
  List<MembershipFreeze> freezeRequests = [];
  List<BookingCancellation> cancellations = [];
  MemberCard? memberCard;
  
  bool loading = false;
  String? error;

  // ===== WAITLIST =====
  Future<void> fetchWaitlist(int memberId) async {
    loading = true;
    notifyListeners();
    try {
      final res = await ApiClient.instance.dio.get('/member/waitlist/$memberId');
      waitlistEntries = (res.data as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map((e) => WaitlistEntry.fromJson(e))
          .toList();
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message']?.toString() ?? 'Failed to load waitlist';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> joinWaitlist(int memberId, String itemType, int itemId) async {
    try {
      final res = await ApiClient.instance.dio.post('/member/waitlist/join', data: {
        'member_id': memberId,
        'item_type': itemType,
        'item_id': itemId,
      });
      final entry = WaitlistEntry.fromJson(res.data as Map<String, dynamic>);
      waitlistEntries.add(entry);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> leaveWaitlist(int waitlistId) async {
    try {
      await ApiClient.instance.dio.delete('/member/waitlist/$waitlistId');
      waitlistEntries.removeWhere((w) => w.id == waitlistId);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  // ===== MEMBERSHIP FREEZE =====
  Future<void> fetchFreezeRequests(int memberId) async {
    loading = true;
    notifyListeners();
    try {
      final res = await ApiClient.instance.dio.get('/member/freezes/$memberId');
      freezeRequests = (res.data as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map((e) => MembershipFreeze.fromJson(e))
          .toList();
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message']?.toString() ?? 'Failed to load freeze requests';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> requestFreeze(
    int memberId,
    DateTime startDate,
    DateTime endDate,
    String reason, {
    String? notes,
  }) async {
    try {
      final res = await ApiClient.instance.dio.post('/member/freezes', data: {
        'member_id': memberId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'reason': reason,
        'notes': notes,
      });
      final freeze = MembershipFreeze.fromJson(res.data as Map<String, dynamic>);
      freezeRequests.add(freeze);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> cancelFreezeRequest(int freezeId) async {
    try {
      await ApiClient.instance.dio.delete('/member/freezes/$freezeId');
      freezeRequests.removeWhere((f) => f.id == freezeId);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  // ===== MEMBER CARD & CHECK-IN =====
  Future<void> fetchMemberCard(int memberId) async {
    loading = true;
    notifyListeners();
    try {
      final res = await ApiClient.instance.dio.get('/member/card/$memberId');
      final data = res.data;
      if (data == null) {
        memberCard = null;
      } else {
        memberCard = MemberCard.fromJson(data as Map<String, dynamic>);
      }
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message']?.toString() ?? 'Failed to load member card';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> generateMemberCard(int memberId) async {
    try {
      final res = await ApiClient.instance.dio.post('/member/card/generate', data: {'member_id': memberId});
      memberCard = MemberCard.fromJson(res.data as Map<String, dynamic>);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> checkInFacility(int memberId, String qrCode) async {
    try {
      await ApiClient.instance.dio.post('/member/checkin', data: {
        'member_id': memberId,
        'qr_code': qrCode,
      });
      return true;
    } on DioException {
      return false;
    }
  }

  // ===== BOOKING CANCELLATION =====
  Future<void> fetchCancellations(int memberId) async {
    loading = true;
    notifyListeners();
    try {
      final res = await ApiClient.instance.dio.get('/member/cancellations/$memberId');
      cancellations = (res.data as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map((e) => BookingCancellation.fromJson(e))
          .toList();
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message']?.toString() ?? 'Failed to load cancellations';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> checkCancellationPolicy(int bookingId) async {
    try {
      final res = await ApiClient.instance.dio.get('/member/cancellation-policy/$bookingId');
      return res.data as Map<String, dynamic>?;
    } on DioException {
      return null;
    }
  }

  Future<bool> cancelBooking(
    int memberId,
    int bookingId,
    String reason,
  ) async {
    try {
      await ApiClient.instance.dio.post('/member/cancel-booking', data: {
        'member_id': memberId,
        'booking_id': bookingId,
        'reason': reason,
      });
      await fetchCancellations(memberId);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }
}
