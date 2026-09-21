import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:locora/core/storage/token_storage.dart';

enum RequestAuth { none, driver, business }

class ApiExeption implements Exception {
  final String message;
  final int statusCode;

  new(this.message, this.statusCode);

  @override
  String toString() => message;
}

class ApiClient {
  final String _baseUrl;
  final TokenStorage _tokenStorage;

  new({required this._baseUrl, required this._tokenStorage});

  Future<Map<String, String>> _headers(RequestAuth auth) async {
    final headers = {
      'Content-type': "application/json",
      "Accept": "application/json",
    };

    if (auth == RequestAuth.none) {
      return headers;
    }

    final scope = auth == RequestAuth.driver
        ? AuthScope.driver
        : AuthScope.business;

    final token = await _tokenStorage.read(scope);

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = "Bearer $token";
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    RequestAuth auth = RequestAuth.none,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse("$_baseUrl$path")
        .replace(queryParameters: queryParameters);

    final response = await http.get(uri, headers: await _headers(auth));

    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    RequestAuth auth = RequestAuth.none,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse("$_baseUrl$path");

    final response = await http.post(
      uri,
      headers: await _headers(auth),
      body: jsonEncode(body ?? {}),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    RequestAuth auth = RequestAuth.none,
  }) async {
    final uri = Uri.parse("$_baseUrl$path");

    final response = await http.delete(uri, headers: await _headers(auth));

    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw ApiExeption(
        "Server return and Invalid response",
        response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['error']?.toString() ?? 'Request Failed.'
          : 'Request Failed.';
      throw ApiExeption(message, response.statusCode);
    }

    if (decoded is! Map<String, dynamic>) {
      throw ApiExeption("Unexpected server response", response.statusCode);
    }

    return decoded;
  }
}
