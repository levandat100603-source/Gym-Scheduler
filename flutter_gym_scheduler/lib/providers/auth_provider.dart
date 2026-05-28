import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// local avatar cache stored as base64 in SharedPreferences

import '../core/api_client.dart';
import '../models/app_models.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? user;
  String? token;
  int avatarRevision = 0;
  bool isInitializing = true;
  bool loading = false;
  bool _refreshingProfile = false;
  bool _profileFetched = false;
  String? _lastKnownAvatar;
  String? localAvatarBase64;

  String _prefKey(String baseKey, [int? userId]) {
    final resolvedUserId = userId ?? user?.id;
    return resolvedUserId == null ? baseKey : '${baseKey}_$resolvedUserId';
  }

  String profileAvatarKey([int? userId]) => _prefKey('profile_avatar', userId);
  String profileAvatarLocalKey([int? userId]) => _prefKey('profile_avatar_local', userId);
  String profileAvatarRevisionKey([int? userId]) => _prefKey('profile_avatar_version', userId);

  String? get displayAvatar {
    final currentAvatar = (user?.avatar ?? '').trim();
    if (currentAvatar.isNotEmpty) return currentAvatar;
    final cachedAvatar = (_lastKnownAvatar ?? '').trim();
    return cachedAvatar.isNotEmpty ? cachedAvatar : null;
  }

  bool get isLoggedIn => token != null && user != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userRaw = prefs.getString('user');
    token = prefs.getString('token');
    _lastKnownAvatar = null;
    localAvatarBase64 = null;
    avatarRevision = 0;

    if (userRaw != null && token != null) {
      try {
        user = AppUser.fromJson(jsonDecode(userRaw) as Map<String, dynamic>);
        final currentUserId = user?.id;
        final cachedAvatar = currentUserId == null ? '' : prefs.getString(profileAvatarKey(currentUserId))?.trim() ?? '';
        final cachedLocal = currentUserId == null ? '' : prefs.getString(profileAvatarLocalKey(currentUserId))?.trim() ?? '';
        avatarRevision = currentUserId == null ? 0 : prefs.getInt(profileAvatarRevisionKey(currentUserId)) ?? 0;
        _lastKnownAvatar = cachedAvatar.isNotEmpty ? cachedAvatar : null;
        localAvatarBase64 = cachedLocal.isNotEmpty ? cachedLocal : null;

        if (cachedAvatar.isNotEmpty && (user?.avatar ?? '').trim().isEmpty) {
          user = AppUser(
            id: user!.id,
            name: user!.name,
            email: user!.email,
            role: user!.role,
            avatar: cachedAvatar,
          );
        }
        final initAvatar = (user?.avatar ?? '').trim();
        if (initAvatar.isNotEmpty) {
          _lastKnownAvatar = initAvatar;
        }
      } catch (_) {
        user = null;
      }
    }

    final synced = await _syncFromBackend(cachedAvatar: user?.avatar);

    isInitializing = false;
    _profileFetched = synced;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    loading = true;
    notifyListeners();
    try {
      final res = await ApiClient.instance.dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      await _saveAuth(res.data as Map<String, dynamic>);
      return res.data as Map<String, dynamic>;
    } on DioException {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    loading = true;
    notifyListeners();
    try {
      final res = await ApiClient.instance.dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return res.data as Map<String, dynamic>;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> applyAuthResponse(Map<String, dynamic> data) async {
    await _saveAuth(data);
  }

  Future<void> _saveAuth(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final nextToken = (data['access_token'] ?? data['token'])?.toString();
    final userData = data['user'] as Map<String, dynamic>?;

    if (nextToken != null && userData != null) {
      token = nextToken;
      _profileFetched = false;
      _lastKnownAvatar = null;
      localAvatarBase64 = null;
      avatarRevision = 0;
      final existingAvatar = (user?.avatar ?? '').trim();
      user = AppUser.fromJson(userData);
      final currentUserId = user?.id;
      final cachedAvatar = currentUserId == null ? '' : prefs.getString(profileAvatarKey(currentUserId))?.trim() ?? '';
      final cachedLocal = currentUserId == null ? '' : prefs.getString(profileAvatarLocalKey(currentUserId))?.trim() ?? '';
      avatarRevision = currentUserId == null ? 0 : prefs.getInt(profileAvatarRevisionKey(currentUserId)) ?? 0;
      if (cachedLocal.isNotEmpty) {
        localAvatarBase64 = cachedLocal;
      }
      if ((user?.avatar ?? '').trim().isEmpty && existingAvatar.isNotEmpty) {
        user = AppUser(
          id: user!.id,
          name: user!.name,
          email: user!.email,
          role: user!.role,
          avatar: existingAvatar,
        );
      } else if ((user?.avatar ?? '').trim().isEmpty && cachedAvatar.isNotEmpty) {
        user = AppUser(
          id: user!.id,
          name: user!.name,
          email: user!.email,
          role: user!.role,
          avatar: cachedAvatar,
        );
      }
      final nextAvatar = (user?.avatar ?? '').trim();
      if (nextAvatar.isNotEmpty) {
        _lastKnownAvatar = nextAvatar;
      }
      await prefs.setString('token', token!);
      await prefs.setString('user', jsonEncode(userData));
      final synced = await _syncFromBackend();
      _profileFetched = synced;
      notifyListeners();
    }
  }

  Future<bool> _syncFromBackend({String? cachedAvatar}) async {
    final current = user;
    final authToken = token;
    if (current == null || authToken == null || authToken.isEmpty) return false;

    try {
      final res = await ApiClient.instance.dio.get('/user/history');
      final history = (res.data as Map).cast<String, dynamic>();
      final userInfo = (history['user_info'] as Map?)?.cast<String, dynamic>();
      if (userInfo == null) return false;

      final backendAvatar = (userInfo['avatar'] ?? '').toString().trim();
      final fallbackAvatar = cachedAvatar?.trim() ?? '';
      final resolvedAvatar = backendAvatar.isNotEmpty
          ? backendAvatar
          : (current.avatar?.trim().isNotEmpty == true ? current.avatar!.trim() : fallbackAvatar);

      user = AppUser(
        id: current.id,
        name: (userInfo['name'] ?? current.name).toString(),
        email: (userInfo['email'] ?? current.email).toString(),
        role: (userInfo['role'] ?? current.role).toString(),
        avatar: resolvedAvatar.isNotEmpty ? resolvedAvatar : null,
      );
      if (resolvedAvatar.isNotEmpty) {
        _lastKnownAvatar = resolvedAvatar;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user!.toJson()));
      if (resolvedAvatar.isNotEmpty) {
        await prefs.setString(profileAvatarKey(current.id), resolvedAvatar);
        await _bumpAvatarRevision(prefs, current.id);
        // Try to download and cache a local copy for instant load (fire-and-forget)
        _downloadAndCacheAvatar(resolvedAvatar);
      } else {
        localAvatarBase64 = null;
      }
      notifyListeners();
      return true;
    } catch (_) {
      // Keep locally stored user if backend sync is unavailable.
      return false;
    }
  }

  Future<void> ensureProfileLoaded() async {
    if (_refreshingProfile || _profileFetched) return;
    final current = user;
    if (current == null || token == null || token!.isEmpty) return;

    _refreshingProfile = true;
    try {
      _profileFetched = await _syncFromBackend(cachedAvatar: current.avatar);
    } finally {
      _refreshingProfile = false;
    }
  }

  Future<void> updateLocalUser(Map<String, dynamic> partial) async {
    final current = user;
    if (current == null) return;

    String? nextAvatar;
    final rawAvatar = partial['avatar']?.toString().trim();
    if (rawAvatar != null && rawAvatar.isNotEmpty && rawAvatar.toLowerCase() != 'null') {
      nextAvatar = rawAvatar;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final currentAvatar = (current.avatar ?? '').trim();
      final cachedAvatar = (prefs.getString(profileAvatarKey(current.id)) ?? '').trim();
      nextAvatar = currentAvatar.isNotEmpty ? currentAvatar : cachedAvatar;
    }

    user = AppUser(
      id: current.id,
      name: (partial['name'] ?? current.name).toString(),
      email: (partial['email'] ?? current.email).toString(),
      role: (partial['role'] ?? current.role).toString(),
      avatar: nextAvatar,
    );
      if (nextAvatar.isNotEmpty) {
        _lastKnownAvatar = nextAvatar;
      }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user!.toJson()));
    if (nextAvatar.isNotEmpty) {
      await prefs.setString(profileAvatarKey(current.id), nextAvatar);
      await _bumpAvatarRevision(prefs, current.id);
      // Also refresh local cached copy (fire-and-forget)
      _downloadAndCacheAvatar(nextAvatar);
    } else {
      localAvatarBase64 = null;
    }
    notifyListeners();
  }

  // Download avatar image and store locally for fast rendering.
  Future<void> _downloadAndCacheAvatar(String avatar) async {
    try {
      final raw = avatar.trim();
      if (raw.isEmpty) return;

      // Build full URL if needed
      final baseUrl = ApiClient.instance.dio.options.baseUrl.replaceAll('/api', '');
      String url;
      if (raw.startsWith('http://') || raw.startsWith('https://')) {
        url = raw;
      } else if (raw.startsWith('/')) {
        url = '$baseUrl$raw';
      } else {
        url = '$baseUrl/$raw';
      }

      final resp = await ApiClient.instance.dio.get<List<int>>(url, options: Options(responseType: ResponseType.bytes));
      final bytes = resp.data;
      if (bytes == null || bytes.isEmpty) return;

      final encoded = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = user?.id;
      if (currentUserId != null) {
        await prefs.setString(profileAvatarLocalKey(currentUserId), encoded);
      }
      // expose in-memory and notify so UI can update immediately
      localAvatarBase64 = encoded;
      notifyListeners();
    } catch (_) {
      // ignore errors - caching is optional
    }
  }

  Future<void> _bumpAvatarRevision(SharedPreferences prefs, [int? userId]) async {
    avatarRevision += 1;
    final resolvedUserId = userId ?? user?.id;
    if (resolvedUserId != null) {
      await prefs.setInt(profileAvatarRevisionKey(resolvedUserId), avatarRevision);
    }
  }

  Future<void> logout() async {
    final currentUserId = user?.id;
    user = null;
    token = null;
    _profileFetched = false;
    _lastKnownAvatar = null;
    localAvatarBase64 = null;
    avatarRevision = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('my_cart');
    if (currentUserId != null) {
      await prefs.remove(profileAvatarKey(currentUserId));
      await prefs.remove(profileAvatarLocalKey(currentUserId));
      await prefs.remove(profileAvatarRevisionKey(currentUserId));
    }
    notifyListeners();
  }
}
