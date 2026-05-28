import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/app_theme.dart';
import 'providers/admin_management_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/member_features_provider.dart';
import 'providers/trainer_management_provider.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.init();

  final auth = AuthProvider();
  final cart = CartProvider();
  await auth.init();
  await cart.init(userId: auth.user?.id);

  int? lastSyncedUserId = auth.user?.id;
  auth.addListener(() {
    final currentUserId = auth.user?.id;
    if (currentUserId == lastSyncedUserId) {
      return;
    }
    lastSyncedUserId = currentUserId;
    cart.syncForUser(currentUserId);
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider<CartProvider>.value(value: cart),
        ChangeNotifierProvider<TrainerManagementProvider>(
          create: (_) => TrainerManagementProvider(),
        ),
        ChangeNotifierProvider<MemberFeaturesProvider>(
          create: (_) => MemberFeaturesProvider(),
        ),
        ChangeNotifierProvider<AdminManagementProvider>(
          create: (_) => AdminManagementProvider(),
        ),
      ],
      child: const GymSchedulerApp(),
    ),
  );
}

class GymSchedulerApp extends StatelessWidget {
  const GymSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitZone Gym Scheduler',
      theme: AppTheme.light,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
      },
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isInitializing) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!auth.isLoggedIn) {
          return const LoginScreen();
        }
        return const MainShellScreen();
      },
    );
  }
}
