import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/app_models_extended.dart';

/// Provider for Trainer features: availability, time-off, health profiles, etc.
class TrainerManagementProvider extends ChangeNotifier {
  List<WorkingHours> workingHours = [];
  List<TimeOff> timeOffRequests = [];
  List<SessionNote> sessionNotes = [];
  List<WorkoutPlan> workoutPlans = [];
  TrainerEarnings? earnings;

  bool loading = false;
  String? error;

  Future<void> fetchWorkingHours(int trainerId) async {
    loading = true;
    notifyListeners();
    try {
      final res = await ApiClient.instance.dio.get('/trainer/working-hours/$trainerId');
      workingHours = (res.data as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map((e) => WorkingHours.fromJson(e))
          .toList();
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message']?.toString() ?? 'Failed to load working hours';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> saveWorkingHours(int trainerId, List<WorkingHours> hours) async {
    try {
      await ApiClient.instance.dio.post('/trainer/working-hours', data: {
        'trainer_id': trainerId,
        'working_hours': hours.map((h) => h.toJson()).toList(),
      });
      workingHours = hours;
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  Future<void> fetchTimeOff(int trainerId) async {
    loading = true;
    notifyListeners();
    try {
      final res = await ApiClient.instance.dio.get('/trainer/time-off/$trainerId');
      timeOffRequests = (res.data as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map((e) => TimeOff.fromJson(e))
          .toList();
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message']?.toString() ?? 'Failed to load time-off';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> requestTimeOff(int trainerId, DateTime startDate, DateTime endDate, String reason, [String? description]) async {
    try {
      final res = await ApiClient.instance.dio.post('/trainer/time-off', data: {
        'trainer_id': trainerId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'reason': reason,
        'description': description,
      });
      final newTimeOff = TimeOff.fromJson(res.data as Map<String, dynamic>);
      timeOffRequests.add(newTimeOff);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> cancelTimeOff(int timeOffId) async {
    try {
      await ApiClient.instance.dio.delete('/trainer/time-off/$timeOffId');
      timeOffRequests.removeWhere((t) => t.id == timeOffId);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  Future<void> fetchSessionNotes(int trainerId, {int memberId = 0}) async {
    loading = true;
    notifyListeners();
    try {
      final url = memberId > 0
          ? '/trainer/session-notes/$trainerId?member_id=$memberId'
          : '/trainer/session-notes/$trainerId';
      final res = await ApiClient.instance.dio.get(url);
      sessionNotes = (res.data as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map((e) => SessionNote.fromJson(e))
          .toList();
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message']?.toString() ?? 'Failed to load session notes';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> addSessionNote(
    int trainerId,
    int bookingId,
    int memberId,
    String content, {
    List<String>? focusAreas,
    int? performance,
    String? nextFocus,
  }) async {
    try {
      final res = await ApiClient.instance.dio.post('/trainer/session-notes', data: {
        'trainer_id': trainerId,
        'booking_id': bookingId,
        'member_id': memberId,
        'content': content,
        'focus_areas': focusAreas,
        'performance': performance,
        'next_focus': nextFocus,
      });
      final note = SessionNote.fromJson(res.data as Map<String, dynamic>);
      sessionNotes.add(note);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  Future<void> fetchWorkoutPlans(int trainerId, {int memberId = 0}) async {
    loading = true;
    notifyListeners();
    try {
      final url = memberId > 0
          ? '/trainer/workout-plans/$trainerId?member_id=$memberId'
          : '/trainer/workout-plans/$trainerId';
      final res = await ApiClient.instance.dio.get(url);
      workoutPlans = (res.data as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map((e) => WorkoutPlan.fromJson(e))
          .toList();
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message']?.toString() ?? 'Failed to load workout plans';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> createWorkoutPlan(
    int trainerId,
    int memberId,
    String title,
    String content, {
    int duration = 4,
    String? difficulty,
    DateTime? startDate,
  }) async {
    try {
      final res = await ApiClient.instance.dio.post('/trainer/workout-plans', data: {
        'trainer_id': trainerId,
        'member_id': memberId,
        'title': title,
        'content': content,
        'duration': duration,
        'difficulty': difficulty,
        'start_date': startDate?.toIso8601String(),
      });
      final plan = WorkoutPlan.fromJson(res.data as Map<String, dynamic>);
      workoutPlans.add(plan);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> deleteWorkoutPlan(int planId) async {
    try {
      await ApiClient.instance.dio.delete('/trainer/workout-plans/$planId');
      workoutPlans.removeWhere((p) => p.id == planId);
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }

  Future<void> fetchEarnings(int trainerId) async {
    loading = true;
    notifyListeners();
    try {
      final res = await ApiClient.instance.dio.get('/trainer/earnings/$trainerId');
      earnings = TrainerEarnings.fromJson(res.data as Map<String, dynamic>);
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message']?.toString() ?? 'Failed to load earnings';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> requestWithdrawal(int trainerId, double amount) async {
    try {
      await ApiClient.instance.dio.post('/trainer/withdrawal', data: {
        'trainer_id': trainerId,
        'amount': amount,
        'method': 'bank_transfer',
      });
      notifyListeners();
      return true;
    } on DioException {
      return false;
    }
  }
}
