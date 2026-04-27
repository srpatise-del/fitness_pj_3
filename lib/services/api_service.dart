import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost/fitness_pj_3/php.api',
  );
  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/$endpoint'),
          headers: _headers(token),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(_timeout);
    return _decode(response);
  }

  Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    final response = await http
        .get(Uri.parse('$baseUrl/$endpoint'), headers: _headers(token))
        .timeout(_timeout);
    return _decode(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/$endpoint'),
          headers: _headers(token),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(_timeout);
    return _decode(response);
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/$endpoint'), headers: _headers(token))
        .timeout(_timeout);
    return _decode(response);
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    final data =
        response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data is Map<String, dynamic>) return data;
      return {'data': data};
    }
    throw Exception(
      data is Map<String, dynamic>
          ? data['message']?.toString() ?? 'API Error ${response.statusCode}'
          : 'API Error ${response.statusCode}',
    );
  }
}
