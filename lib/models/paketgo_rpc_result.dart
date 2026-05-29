class PaketGoRpcResult {
  const PaketGoRpcResult({
    required this.status,
    required this.message,
    this.payload = const <String, dynamic>{},
  });

  factory PaketGoRpcResult.fromJson(Map<String, dynamic> json) {
    return PaketGoRpcResult(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String? ?? 'Bilinmeyen cevap alindi.',
      payload: json,
    );
  }

  final String status;
  final String message;
  final Map<String, dynamic> payload;

  bool get isSuccess => status == 'success';
}
