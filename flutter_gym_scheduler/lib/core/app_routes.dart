import 'package:flutter/material.dart';

import '../screens/trainer/trainer_availability_screen.dart';
import '../screens/trainer/trainer_client_management_screen.dart';
import '../screens/trainer/trainer_earnings_screen.dart';
import '../screens/member/member_flexibility_screen.dart';
import '../screens/member/member_checkin_cancellation_screen.dart';
import '../screens/admin/admin_marketing_screen.dart';
import '../screens/admin/admin_reports_refunds_screen.dart';

/// App route definitions for new features
class AppRoutes {
  // Trainer Routes
  static const String trainerAvailability = '/trainer/availability';
  static const String trainerClientManagement = '/trainer/client-management';
  static const String trainerEarnings = '/trainer/earnings';

  // Member Routes
  static const String memberFlexibility = '/member/flexibility';
  static const String memberCheckInCancellation = '/member/checkin-cancellation';

  // Admin Routes
  static const String adminMarketing = '/admin/marketing';
  static const String adminReportsRefunds = '/admin/reports-refunds';

  /// Generate routes dynamically
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Trainer Routes
      case trainerAvailability:
        final trainerId = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => TrainerAvailabilityScreen(trainerId: trainerId ?? 0),
        );
      case trainerClientManagement:
        final trainerClientManagementId = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => TrainerClientManagementScreen(
            trainerId: trainerClientManagementId ?? 0,
          ),
        );
      case trainerEarnings:
        final trainerEarningsId = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => TrainerEarningsScreen(trainerId: trainerEarningsId ?? 0),
        );

      // Member Routes
      case memberFlexibility:
        final memberId = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => MemberFlexibilityScreen(memberId: memberId ?? 0),
        );
      case memberCheckInCancellation:
        final memberId = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => MemberCheckInAndCancellationScreen(memberId: memberId ?? 0),
        );

      // Admin Routes
      case adminMarketing:
        return MaterialPageRoute(
          builder: (_) => const AdminMarketingScreen(),
        );
      case adminReportsRefunds:
        return MaterialPageRoute(
          builder: (_) => const AdminReportsAndRefundsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Lỗi')),
            body: Center(
              child: Text('Không tìm thấy route: ${settings.name}'),
            ),
          ),
        );
    }
  }

  /// Helper to navigate to Trainer features
  static void navigateToTrainerAvailability(BuildContext context, int trainerId) {
    Navigator.pushNamed(context, trainerAvailability, arguments: trainerId);
  }

  static void navigateToTrainerClientManagement(BuildContext context) {
    Navigator.pushNamed(context, trainerClientManagement);
  }

  static void navigateToTrainerEarnings(BuildContext context, int trainerId) {
    Navigator.pushNamed(context, trainerEarnings, arguments: trainerId);
  }

  /// Helper to navigate to Member features
  static void navigateToMemberFlexibility(BuildContext context, int memberId) {
    Navigator.pushNamed(context, memberFlexibility, arguments: memberId);
  }

  static void navigateToMemberCheckInCancellation(BuildContext context, int memberId) {
    Navigator.pushNamed(context, memberCheckInCancellation, arguments: memberId);
  }

  /// Helper to navigate to Admin features
  static void navigateToAdminMarketing(BuildContext context) {
    Navigator.pushNamed(context, adminMarketing);
  }

  static void navigateToAdminReportsRefunds(BuildContext context) {
    Navigator.pushNamed(context, adminReportsRefunds);
  }
}
