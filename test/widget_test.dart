import 'package:flutter_test/flutter_test.dart';
import 'package:paketgo/main.dart';

void main() {
  testWidgets('PaketGO app starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PaketGoApp());
    await tester.pump();

    expect(find.text('PaketGO'), findsOneWidget);
    expect(find.text('Hızlı & Güvenli Teslimat'), findsOneWidget);

    // Allow the splash timer to complete
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
