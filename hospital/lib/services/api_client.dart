import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'session.dart';

/// A failed request, with a message that can be shown to the patient.
class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Thin wrapper around `http` for the HealthNova API.
///
/// Every response from the backend is JSON. Successful calls return the
/// decoded body; failures throw [ApiException] carrying the backend's
/// `message`, so screens can show exactly what went wrong.
class ApiClient {
  ApiClient._();

  static const Duration _timeout = Duration(seconds: 20);

  /// Called when the backend rejects the token (expired or invalid). The app
  /// uses it to send the patient back to the login screen.
  static void Function()? onUnauthorized;

  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) {
    return _send(
      () => http.get(_uri(path, query), headers: _headers(true)),
      auth: true,
    );
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) {
    return _send(
      () => http.post(
        _uri(path),
        headers: _headers(auth),
        body: jsonEncode(body),
      ),
      auth: auth,
    );
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) {
    return _send(
      () => http.put(_uri(path), headers: _headers(true), body: jsonEncode(body)),
      auth: true,
    );
  }

  static Future<Map<String, dynamic>> delete(String path) {
    return _send(
      () => http.delete(_uri(path), headers: _headers(true)),
      auth: true,
    );
  }

  static Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: query);
  }

  static Map<String, String> _headers(bool auth) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = Session.token;
    // The backend's authMiddleware verifies the header value as the token
    // itself, so it is sent bare - a "Bearer " prefix would be rejected.
    if (auth && token != null) headers['Authorization'] = token;
    return headers;
  }

  /// Runs the request, turning network failures into readable messages.
  static Future<http.Response> _perform(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Please try again.',
      );
    } catch (_) {
      throw ApiException(
        'Cannot reach the HealthNova server at ${ApiConfig.baseUrl}. '
        'Check that the backend is running and the address is correct.',
      );
    }
  }

  static Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request, {
    required bool auth,
  }) async {
    final response = await _perform(request);

    var body = <String, dynamic>{};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) body = decoded;
      } on FormatException {
        // Not JSON (for example a proxy error page); the status decides below.
      }
    }

    final status = response.statusCode;
    if (status >= 200 && status < 300) return body;

    if (status == 401 && auth) {
      await Session.clear();
      onUnauthorized?.call();
      throw const ApiException(
        'Your session has expired. Please log in again.',
        401,
      );
    }

    final message = body['message'];
    throw ApiException(
      message is String && message.isNotEmpty
          ? message
          : 'Something went wrong (error $status). Please try again.',
      status,
    );
  }
}
