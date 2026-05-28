/// Extended models for new features across all roles
/// Including Trainer availability, Member features, and Admin tools

// ============= TRAINER FEATURES =============

/// Trainer's working hours setup
class WorkingHours {
  WorkingHours({
    required this.id,
    required this.trainerId,
    required this.dayOfWeek, // 0=Monday, 6=Sunday
    required this.startTime, // HH:mm format
    required this.endTime,   // HH:mm format
    this.isActive = true,
  });

  final int id;
  final int trainerId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isActive;

  static String _normalizeTime(dynamic raw) {
    final value = (raw ?? '').toString().trim();
    final hhmmss = RegExp(r'^([01]\d|2[0-3]):[0-5]\d:[0-5]\d$');
    if (hhmmss.hasMatch(value)) {
      return value.substring(0, 5);
    }
    return value;
  }

  factory WorkingHours.fromJson(Map<String, dynamic> json) => WorkingHours(
    id: (json['id'] as num?)?.toInt() ?? 0,
    trainerId: (json['trainer_id'] as num?)?.toInt() ?? 0,
    dayOfWeek: (json['day_of_week'] as num?)?.toInt() ?? 0,
    startTime: _normalizeTime(json['start_time']),
    endTime: _normalizeTime(json['end_time']),
    isActive: json['is_active'] != false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'trainer_id': trainerId,
    'day_of_week': dayOfWeek,
    'start_time': startTime,
    'end_time': endTime,
    'is_active': isActive,
  };
}

/// Time-off request (nghỉ phép, ốm, bận...)
class TimeOff {
  TimeOff({
    required this.id,
    required this.trainerId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = 'pending', // pending, approved, rejected
    this.description,
    this.createdAt,
  });

  final int id;
  final int trainerId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason; // sick, leave, personal, etc.
  final String status;
  final String? description;
  final DateTime? createdAt;

  factory TimeOff.fromJson(Map<String, dynamic> json) => TimeOff(
    id: (json['id'] as num?)?.toInt() ?? 0,
    trainerId: (json['trainer_id'] as num?)?.toInt() ?? 0,
    startDate: DateTime.tryParse((json['start_date'] ?? '').toString()) ?? DateTime.now(),
    endDate: DateTime.tryParse((json['end_date'] ?? '').toString()) ?? DateTime.now(),
    reason: (json['reason'] ?? 'personal').toString(),
    status: (json['status'] ?? 'pending').toString(),
    description: json['description']?.toString(),
    createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'trainer_id': trainerId,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'reason': reason,
    'status': status,
    'description': description,
    'created_at': createdAt?.toIso8601String(),
  };
}

/// Member's health/body profile
class HealthProfile {
  HealthProfile({
    required this.id,
    required this.memberId,
    required this.height,      // cm
    required this.weight,      // kg
    this.fatPercentage,        // %
    this.goalType,             // weight_loss, muscle_gain, maintenance
    this.targetWeight,         // kg
    this.medicalNotes,
    this.updatedAt,
  });

  final int id;
  final int memberId;
  final double height;
  final double weight;
  final double? fatPercentage;
  final String? goalType;
  final double? targetWeight;
  final String? medicalNotes;
  final DateTime? updatedAt;

  double get bmi => weight / ((height / 100) * (height / 100));

  factory HealthProfile.fromJson(Map<String, dynamic> json) => HealthProfile(
    id: (json['id'] as num?)?.toInt() ?? 0,
    memberId: (json['member_id'] as num?)?.toInt() ?? 0,
    height: (json['height'] as num?)?.toDouble() ?? 170,
    weight: (json['weight'] as num?)?.toDouble() ?? 70,
    fatPercentage: (json['fat_percentage'] as num?)?.toDouble(),
    goalType: json['goal_type']?.toString(),
    targetWeight: (json['target_weight'] as num?)?.toDouble(),
    medicalNotes: json['medical_notes']?.toString(),
    updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'member_id': memberId,
    'height': height,
    'weight': weight,
    'fat_percentage': fatPercentage,
    'goal_type': goalType,
    'target_weight': targetWeight,
    'medical_notes': medicalNotes,
    'updated_at': updatedAt?.toIso8601String(),
  };
}

/// Session notes by trainer for a member
class SessionNote {
  SessionNote({
    required this.id,
    required this.bookingId,
    required this.trainerId,
    required this.memberId,
    required this.content,
    this.focusAreas,        // e.g., "chest,shoulders"
    this.performance,       // 1-5 scale
    this.nextFocus,
    this.createdAt,
  });

  final int id;
  final int bookingId;
  final int trainerId;
  final int memberId;
  final String content;
  final String? focusAreas;
  final int? performance;
  final String? nextFocus;
  final DateTime? createdAt;

  factory SessionNote.fromJson(Map<String, dynamic> json) => SessionNote(
    id: (json['id'] as num?)?.toInt() ?? 0,
    bookingId: (json['booking_id'] as num?)?.toInt() ?? 0,
    trainerId: (json['trainer_id'] as num?)?.toInt() ?? 0,
    memberId: (json['member_id'] as num?)?.toInt() ?? 0,
    content: (json['content'] ?? '').toString(),
    focusAreas: json['focus_areas']?.toString(),
    performance: (json['performance'] as num?)?.toInt(),
    nextFocus: json['next_focus']?.toString(),
    createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_id': bookingId,
    'trainer_id': trainerId,
    'member_id': memberId,
    'content': content,
    'focus_areas': focusAreas,
    'performance': performance,
    'next_focus': nextFocus,
    'created_at': createdAt?.toIso8601String(),
  };
}

/// Workout plan assigned by trainer to member
class WorkoutPlan {
  WorkoutPlan({
    required this.id,
    required this.trainerId,
    required this.memberId,
    required this.title,
    required this.content,     // JSON string with exercises
    required this.duration,    // weeks
    this.difficulty,           // beginner, intermediate, advanced
    this.startDate,
    this.endDate,
    this.isActive = true,
  });

  final int id;
  final int trainerId;
  final int memberId;
  final String title;
  final String content;
  final int duration;
  final String? difficulty;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => WorkoutPlan(
    id: (json['id'] as num?)?.toInt() ?? 0,
    trainerId: (json['trainer_id'] as num?)?.toInt() ?? 0,
    memberId: (json['member_id'] as num?)?.toInt() ?? 0,
    title: (json['title'] ?? '').toString(),
    content: (json['content'] ?? '').toString(),
    duration: (json['duration'] as num?)?.toInt() ?? 4,
    difficulty: json['difficulty']?.toString(),
    startDate: DateTime.tryParse((json['start_date'] ?? '').toString()),
    endDate: DateTime.tryParse((json['end_date'] ?? '').toString()),
    isActive: json['is_active'] != false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'trainer_id': trainerId,
    'member_id': memberId,
    'title': title,
    'content': content,
    'duration': duration,
    'difficulty': difficulty,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'is_active': isActive,
  };
}

/// Trainer earnings/wallet summary
class TrainerEarnings {
  TrainerEarnings({
    required this.trainerId,
    required this.totalEarnings,
    required this.completedSessions,
    required this.pendingSessions,
    required this.cancelledSessions,
    this.monthlyBreakdown,
    this.withdrawalBalance,
  });

  final int trainerId;
  final double totalEarnings;
  final int completedSessions;
  final int pendingSessions;
  final int cancelledSessions;
  final Map<String, double>? monthlyBreakdown; // "2024-01" => amount
  final double? withdrawalBalance;

  factory TrainerEarnings.fromJson(Map<String, dynamic> json) => TrainerEarnings(
    trainerId: (json['trainer_id'] as num?)?.toInt() ?? 0,
    totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0,
    completedSessions: (json['completed_sessions'] as num?)?.toInt() ?? 0,
    pendingSessions: (json['pending_sessions'] as num?)?.toInt() ?? 0,
    cancelledSessions: (json['cancelled_sessions'] as num?)?.toInt() ?? 0,
    withdrawalBalance: (json['withdrawal_balance'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'trainer_id': trainerId,
    'total_earnings': totalEarnings,
    'completed_sessions': completedSessions,
    'pending_sessions': pendingSessions,
    'cancelled_sessions': cancelledSessions,
    'withdrawal_balance': withdrawalBalance,
  };
}

// ============= MEMBER FEATURES =============

/// Waitlist entry for full classes
class WaitlistEntry {
  WaitlistEntry({
    required this.id,
    required this.memberId,
    required this.itemType,    // class or trainer
    required this.itemId,
    required this.position,
    this.createdAt,
    this.notifiedAt,
  });

  final int id;
  final int memberId;
  final String itemType;
  final int itemId;
  final int position;
  final DateTime? createdAt;
  final DateTime? notifiedAt;

  factory WaitlistEntry.fromJson(Map<String, dynamic> json) => WaitlistEntry(
    id: (json['id'] as num?)?.toInt() ?? 0,
    memberId: (json['member_id'] as num?)?.toInt() ?? 0,
    itemType: (json['item_type'] ?? 'class').toString(),
    itemId: (json['item_id'] as num?)?.toInt() ?? 0,
    position: (json['position'] as num?)?.toInt() ?? 1,
    createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    notifiedAt: DateTime.tryParse((json['notified_at'] ?? '').toString()),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'member_id': memberId,
    'item_type': itemType,
    'item_id': itemId,
    'position': position,
    'created_at': createdAt?.toIso8601String(),
    'notified_at': notifiedAt?.toIso8601String(),
  };
}

/// Membership freeze request
class MembershipFreeze {
  MembershipFreeze({
    required this.id,
    required this.memberId,
    required this.reason,      // vacation, medical, personal
    required this.startDate,
    required this.endDate,
    required this.status,      // pending, approved, active, expired
    this.approvedBy,
    this.notes,
    this.createdAt,
  });

  final int id;
  final int memberId;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final int? approvedBy;
  final String? notes;
  final DateTime? createdAt;

  int get frozenDays => endDate.difference(startDate).inDays;

  factory MembershipFreeze.fromJson(Map<String, dynamic> json) => MembershipFreeze(
    id: (json['id'] as num?)?.toInt() ?? 0,
    memberId: (json['member_id'] as num?)?.toInt() ?? 0,
    reason: (json['reason'] ?? 'personal').toString(),
    startDate: DateTime.tryParse((json['start_date'] ?? '').toString()) ?? DateTime.now(),
    endDate: DateTime.tryParse((json['end_date'] ?? '').toString()) ?? DateTime.now(),
    status: (json['status'] ?? 'pending').toString(),
    approvedBy: (json['approved_by'] as num?)?.toInt(),
    notes: json['notes']?.toString(),
    createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'member_id': memberId,
    'reason': reason,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'status': status,
    'approved_by': approvedBy,
    'notes': notes,
    'created_at': createdAt?.toIso8601String(),
  };
}

/// Member digital card for facility check-in
class MemberCard {
  MemberCard({
    required this.id,
    required this.memberId,
    required this.cardNumber,  // Unique identifier
    required this.qrCode,      // QR code data
    this.isActive = true,
    this.createdAt,
  });

  final int id;
  final int memberId;
  final String cardNumber;
  final String qrCode;
  final bool isActive;
  final DateTime? createdAt;

  factory MemberCard.fromJson(Map<String, dynamic> json) => MemberCard(
    id: (json['id'] as num?)?.toInt() ?? 0,
    memberId: (json['member_id'] as num?)?.toInt() ?? 0,
    cardNumber: (json['card_number'] ?? '').toString(),
    qrCode: (json['qr_code'] ?? '').toString(),
    isActive: json['is_active'] != false,
    createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'member_id': memberId,
    'card_number': cardNumber,
    'qr_code': qrCode,
    'is_active': isActive,
    'created_at': createdAt?.toIso8601String(),
  };
}

/// Booking cancellation with policy
class BookingCancellation {
  BookingCancellation({
    required this.id,
    required this.bookingId,
    required this.memberId,
    required this.reason,
    this.cancelledAt,
    this.penalty,              // amount deducted
    this.refundAmount,
    this.status,               // pending, approved, refunded
  });

  final int id;
  final int bookingId;
  final int memberId;
  final String reason;
  final DateTime? cancelledAt;
  final double? penalty;
  final double? refundAmount;
  final String? status;

  factory BookingCancellation.fromJson(Map<String, dynamic> json) => BookingCancellation(
    id: (json['id'] as num?)?.toInt() ?? 0,
    bookingId: (json['booking_id'] as num?)?.toInt() ?? 0,
    memberId: (json['member_id'] as num?)?.toInt() ?? 0,
    reason: (json['reason'] ?? '').toString(),
    cancelledAt: DateTime.tryParse((json['cancelled_at'] ?? '').toString()),
    penalty: (json['penalty'] as num?)?.toDouble(),
    refundAmount: (json['refund_amount'] as num?)?.toDouble(),
    status: json['status']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_id': bookingId,
    'member_id': memberId,
    'reason': reason,
    'cancelled_at': cancelledAt?.toIso8601String(),
    'penalty': penalty,
    'refund_amount': refundAmount,
    'status': status,
  };
}

// ============= ADMIN FEATURES =============

/// Promotional voucher/discount code
class Voucher {
  Voucher({
    required this.id,
    required this.code,
    required this.discountType,   // percentage or fixed
    required this.discountValue,
    this.maxUses,
    this.usedCount = 0,
    this.minOrderAmount,
    this.validFrom,
    this.validUntil,
    this.applicableTo,            // all, new_members, specific_packages
    this.isActive = true,
  });

  final int id;
  final String code;
  final String discountType;
  final double discountValue;
  final int? maxUses;
  final int usedCount;
  final double? minOrderAmount;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? applicableTo;
  final bool isActive;

  bool get isExpired => validUntil != null && DateTime.now().isAfter(validUntil!);
  bool get isExhausted => maxUses != null && usedCount >= maxUses!;
  bool get isValid => isActive && !isExpired && !isExhausted;

  factory Voucher.fromJson(Map<String, dynamic> json) => Voucher(
    id: (json['id'] as num?)?.toInt() ?? 0,
    code: (json['code'] ?? '').toString(),
    discountType: (json['discount_type'] ?? 'percentage').toString(),
    discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0,
    maxUses: (json['max_uses'] as num?)?.toInt(),
    usedCount: (json['used_count'] as num?)?.toInt() ?? 0,
    minOrderAmount: (json['min_order_amount'] as num?)?.toDouble(),
    validFrom: DateTime.tryParse((json['valid_from'] ?? '').toString()),
    validUntil: DateTime.tryParse((json['valid_until'] ?? '').toString()),
    applicableTo: json['applicable_to']?.toString(),
    isActive: json['is_active'] != false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'discount_type': discountType,
    'discount_value': discountValue,
    'max_uses': maxUses,
    'used_count': usedCount,
    'min_order_amount': minOrderAmount,
    'valid_from': validFrom?.toIso8601String(),
    'valid_until': validUntil?.toIso8601String(),
    'applicable_to': applicableTo,
    'is_active': isActive,
  };
}

/// Push notification campaign
class PushCampaign {
  PushCampaign({
    required this.id,
    required this.title,
    required this.message,
    this.targetAudience,       // all, new_members, inactive, specific_packages
    this.sendAt,
    this.sentAt,
    this.status,               // draft, scheduled, sent
    this.recipientCount,
    this.successCount,
  });

  final int id;
  final String title;
  final String message;
  final String? targetAudience;
  final DateTime? sendAt;
  final DateTime? sentAt;
  final String? status;
  final int? recipientCount;
  final int? successCount;

  factory PushCampaign.fromJson(Map<String, dynamic> json) => PushCampaign(
    id: (json['id'] as num?)?.toInt() ?? 0,
    title: (json['title'] ?? '').toString(),
    message: (json['message'] ?? '').toString(),
    targetAudience: json['target_audience']?.toString(),
    sendAt: DateTime.tryParse((json['send_at'] ?? '').toString()),
    sentAt: DateTime.tryParse((json['sent_at'] ?? '').toString()),
    status: json['status']?.toString(),
    recipientCount: (json['recipient_count'] as num?)?.toInt(),
    successCount: (json['success_count'] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'target_audience': targetAudience,
    'send_at': sendAt?.toIso8601String(),
    'sent_at': sentAt?.toIso8601String(),
    'status': status,
    'recipient_count': recipientCount,
    'success_count': successCount,
  };
}

/// Refund/Make-up session request
class RefundRequest {
  RefundRequest({
    required this.id,
    required this.bookingId,
    required this.memberId,
    required this.reason,
    this.requestedAmount,
    this.approvedAmount,
    this.status,               // pending, approved, rejected, processed
    this.approvedBy,
    this.refundMethod,         // wallet, bank_transfer
    this.notes,
    this.createdAt,
    this.processedAt,
  });

  final int id;
  final int bookingId;
  final int memberId;
  final String reason;
  final double? requestedAmount;
  final double? approvedAmount;
  final String? status;
  final int? approvedBy;
  final String? refundMethod;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? processedAt;

  factory RefundRequest.fromJson(Map<String, dynamic> json) => RefundRequest(
    id: (json['id'] as num?)?.toInt() ?? 0,
    bookingId: (json['booking_id'] as num?)?.toInt() ?? 0,
    memberId: (json['member_id'] as num?)?.toInt() ?? 0,
    reason: (json['reason'] ?? '').toString(),
    requestedAmount: (json['requested_amount'] as num?)?.toDouble(),
    approvedAmount: (json['approved_amount'] as num?)?.toDouble(),
    status: json['status']?.toString(),
    approvedBy: (json['approved_by'] as num?)?.toInt(),
    refundMethod: json['refund_method']?.toString(),
    notes: json['notes']?.toString(),
    createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    processedAt: DateTime.tryParse((json['processed_at'] ?? '').toString()),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_id': bookingId,
    'member_id': memberId,
    'reason': reason,
    'requested_amount': requestedAmount,
    'approved_amount': approvedAmount,
    'status': status,
    'approved_by': approvedBy,
    'refund_method': refundMethod,
    'notes': notes,
    'created_at': createdAt?.toIso8601String(),
    'processed_at': processedAt?.toIso8601String(),
  };
}

/// Transaction/Revenue report entry
class TransactionReport {
  TransactionReport({
    required this.id,
    required this.date,
    this.memberId,
    this.trainerId,
    this.type,                 // booking, refund, voucher, membership
    this.amount,
    this.description,
    this.details,              // JSON with additional info
  });

  final int id;
  final DateTime date;
  final int? memberId;
  final int? trainerId;
  final String? type;
  final double? amount;
  final String? description;
  final Map<String, dynamic>? details;

  factory TransactionReport.fromJson(Map<String, dynamic> json) => TransactionReport(
    id: (json['id'] as num?)?.toInt() ?? 0,
    date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
    memberId: (json['member_id'] as num?)?.toInt(),
    trainerId: (json['trainer_id'] as num?)?.toInt(),
    type: json['type']?.toString(),
    amount: (json['amount'] as num?)?.toDouble(),
    description: json['description']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'member_id': memberId,
    'trainer_id': trainerId,
    'type': type,
    'amount': amount,
    'description': description,
    'details': details,
  };
}
