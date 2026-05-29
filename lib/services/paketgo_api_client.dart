import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/paketgo_config.dart';
import '../models/paketgo_rpc_result.dart';

class PaketGoApiException implements Exception {
  PaketGoApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'PaketGoApiException($statusCode): $message';
}

class PaketGoApiClient {
  PaketGoApiClient({
    required this.jwtToken,
    this.config = const PaketGoConfig(postgrestBaseUrl: 'https://api.paketgo.com'),
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String jwtToken;
  final PaketGoConfig config;
  final http.Client _httpClient;

  Map<String, String> get _jsonHeaders => <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };

  Future<PaketGoRpcResult> assignAutoCourier(String orderId) async {
    final response = await _httpClient.post(
      config.endpoint('/rpc/rpc_assign_auto_courier'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, String>{'p_order_id': orderId}),
    );

    return _parseRpcResponse(response);
  }

  Future<PaketGoRpcResult> processNfcPayment({
    required String orderId,
    required String transactionToken,
  }) async {
    final response = await _httpClient.post(
      config.endpoint('/rpc/rpc_process_nfc_payment'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, String>{
        'p_order_id': orderId,
        'p_transaction_token': transactionToken,
      }),
    );

    return _parseRpcResponse(response);
  }

  PaketGoRpcResult _parseRpcResponse(http.Response response) {
    final decodedBody = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PaketGoRpcResult.fromJson(decodedBody);
    }

    final message = decodedBody['message'] as String? ?? 'PostgREST istegi basarisiz oldu.';
    throw PaketGoApiException(message, statusCode: response.statusCode);
  }

  void close() => _httpClient.close();
}
