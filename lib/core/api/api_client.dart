import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@lazySingleton
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = String.fromEnvironment('API_BASE_URL');
  final http.Client _client;

  bool get isConfigured => _baseUrl.trim().isNotEmpty;

  Future<Map<String, dynamic>?> getJson(String path) async {
    if (!isConfigured) return null;

    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}
