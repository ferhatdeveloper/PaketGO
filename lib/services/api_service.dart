import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<List<dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      throw ApiException('GET failed: ${response.statusCode}', response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final response = await _client.post(
        uri,
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) return decoded.first;
        return decoded;
      }
      throw ApiException('POST failed: ${response.statusCode}', response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  Future<void> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final response = await _client.patch(uri, headers: _headers, body: jsonEncode(body));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException('PATCH failed: ${response.statusCode}', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final response = await _client.delete(uri, headers: _headers);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException('DELETE failed: ${response.statusCode}', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
