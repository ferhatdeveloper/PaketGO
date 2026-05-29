import 'package:flutter_test/flutter_test.dart';
import 'package:paketgo/models/paketgo_rpc_result.dart';

void main() {
  test('PaketGoRpcResult success durumunu cozer', () {
    final result = PaketGoRpcResult.fromJson(<String, dynamic>{
      'status': 'success',
      'message': 'Kurye otomatik atandi.',
    });

    expect(result.isSuccess, isTrue);
    expect(result.message, 'Kurye otomatik atandi.');
  });
}
