import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// The signed-in patient: the login token and the account details returned
/// with it. Kept in memory for the API calls and saved to the device so the
/// patient stays signed in between launches.
class Session {
  Session._();

  static const String _tokenKey = 'healthnova.token';
  static const String _userKey = 'healthnova.user';

  static String? _token;
  static Map<String, dynamic>? _user;

  static String? get token => _token;

  static Map<String, dynamic> get user => _user ?? const <String, dynamic>{};

  static bool get isLoggedIn => _token != null && !isExpired(_token!);

  static String get email => _text(user['email']);

  static String get phone => _text(user['phone']);

  /// The patient's name, or their email for accounts created without one.
  static String get displayName {
    final name = _text(user['name']);
    return name.isNotEmpty ? name : email;
  }

  /// Restores a saved session. An expired token is discarded.
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      final raw = prefs.getString(_userKey);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) _user = decoded;
      }
    } catch (_) {
      // Storage unavailable or corrupt: start signed out.
      _token = null;
      _user = null;
    }
    if (_token != null && isExpired(_token!)) {
      await clear();
    }
  }

  static Future<void> save(String token, Map<String, dynamic> user) async {
    _token = token;
    _user = Map<String, dynamic>.from(user);
    await _persist();
  }

  /// Merges changed account details, e.g. after the profile is edited.
  static Future<void> updateUser(Map<String, dynamic> changes) async {
    _user = <String, dynamic>{...user, ...changes};
    await _persist();
  }

  static Future<void> clear() async {
    _token = null;
    _user = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (_) {
      // Nothing saved to remove.
    }
  }

  static Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) await prefs.setString(_tokenKey, _token!);
      await prefs.setString(_userKey, jsonEncode(user));
    } catch (_) {
      // The session still works for this launch; it just will not be kept.
    }
  }

  /// A JWT is three base64url parts; the middle one is JSON with `exp`, the
  /// expiry time in seconds. The backend issues tokens valid for 7 days.
  static bool isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload is Map ? payload['exp'] : null;
      if (exp is! num) return false;
      return DateTime.now().millisecondsSinceEpoch >= exp * 1000;
    } catch (_) {
      return true;
    }
  }

  static String _text(Object? value) => value is String ? value.trim() : '';
}
