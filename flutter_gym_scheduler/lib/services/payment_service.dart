import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:logger/logger.dart';
import 'api_service.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  final Logger _logger = Logger();

  // Set your Stripe publishable key
  static const String stripePublishableKey = 'pk_test_YOUR_STRIPE_PUBLISHABLE_KEY';

  factory PaymentService() {
    return _instance;
  }

  PaymentService._internal() {
    Stripe.publishableKey = stripePublishableKey;
  }

  Future<bool> initializePayment({
    required String packageId,
    required double amount,
  }) async {
    try {
      // Create payment intent on backend
      final apiService = ApiService();
      final paymentIntentData = await apiService.createPaymentIntent(
        packageId: packageId,
        amount: amount,
      );

      final clientSecret = paymentIntentData['client_secret'] as String;

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Gym Scheduler',
          style: ThemeMode.light,
        ),
      );

      return true;
    } catch (e) {
      _logger.e('Initialize payment error: $e');
      return false;
    }
  }

  Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      _logger.i('Payment successful');
      return true;
    } catch (e) {
      _logger.e('Payment error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> processPayment({
    required String packageId,
    required double amount,
  }) async {
    try {
      final initialized = await initializePayment(
        packageId: packageId,
        amount: amount,
      );

      if (!initialized) {
        return {'success': false, 'message': 'Failed to initialize payment'};
      }

      final success = await presentPaymentSheet();
      if (success) {
        return {'success': true, 'message': 'Payment completed successfully'};
      } else {
        return {'success': false, 'message': 'Payment was cancelled'};
      }
    } catch (e) {
      _logger.e('Process payment error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
