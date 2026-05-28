import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../core/api_client.dart';

import '../models/app_models.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> cart = [];
  String? _storageKey;
  int? _activeUserId;
  int _syncVersion = 0;

  int get cartCount => cart.length;

  double get cartTotal {
    return cart.fold<double>(
      0,
      (sum, item) => sum + item.price * (item.quantity ?? 1),
    );
  }

  String _keyForUser(int? userId) => userId == null ? 'my_cart_guest' : 'my_cart_user_$userId';

  Future<void> init({int? userId}) async {
    await syncForUser(userId);
  }

  Future<void> syncForUser(int? userId) async {
    _syncVersion += 1;
    final currentSync = _syncVersion;

    // Immediately clear visible cart when account context changes
    if (_activeUserId != userId) {
      _activeUserId = userId;
      cart = [];
      notifyListeners();
    }

    final prefs = await SharedPreferences.getInstance();
    _storageKey = _keyForUser(userId);

    if (currentSync != _syncVersion) return;

    // Try to load local cache first
    final raw = prefs.getString(_storageKey!);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
      if (currentSync != _syncVersion) return;
      cart = list;
    } else {
      if (currentSync != _syncVersion) return;
      cart = [];
    }

    // Remove legacy shared key
    await prefs.remove('my_cart');

    // If user is logged in, try to fetch server-side cart and merge/replace local cache
    if (userId != null) {
      try {
        final res = await ApiClient.instance.dio.get('/cart');
        if (currentSync != _syncVersion) return;
        final items = (res.data as Map?)?['items'] as List?;
        if (items != null) {
          final serverCart = items.map((e) => CartItem.fromJson((e as Map).cast<String, dynamic>())).toList();
          // Replace local cart with server cart (server is source of truth)
          if (currentSync != _syncVersion) return;
          cart = serverCart;
          // persist locally for offline use
          await prefs.setString(_storageKey!, jsonEncode(cart.map((e) => e.toJson()).toList()));
        }
      } on DioException {
        // ignore network errors and keep local cache
      } catch (_) {}
    }

    if (currentSync != _syncVersion) return;
    notifyListeners();
  }

  Future<void> addToCart(CartItem item) async {
    final exists = cart.any(
      (i) =>
          i.id == item.id &&
          i.type == item.type &&
          i.memberId == item.memberId &&
          i.bookedForMember == item.bookedForMember,
    );

    if (!exists) {
      cart = [...cart, item];
      await _persist();
    }
  }

  Future<void> removeFromCart(dynamic id, String type, {int? memberId}) async {
    cart = cart
        .where((i) => !(i.id == id && i.type == type && (memberId == null || i.memberId == memberId)))
        .toList();
    await _persist();
  }

  Future<void> clearCart() async {
    cart = [];
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _storageKey ?? _keyForUser(null);
    await prefs.setString(key, jsonEncode(cart.map((e) => e.toJson()).toList()));
    // Sync to backend only for logged-in users in current active account context.
    if (_activeUserId != null && _activeUserId! > 0) {
      try {
        await ApiClient.instance.dio.post('/cart', data: {'items': cart.map((e) => e.toJson()).toList()});
      } on DioException {
        // ignore sync failures (will retry next change or on login)
      } catch (_) {}
    }
    notifyListeners();
  }
}
