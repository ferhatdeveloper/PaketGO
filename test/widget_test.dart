import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paketgo/main.dart';
import 'package:paketgo/screens/onboarding/onboarding_screen.dart';
import 'package:paketgo/screens/auth/login_screen.dart';

void main() {
  testWidgets('App starts and shows onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PaketGoApp()));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Should show onboarding or login depending on state
    final hasOnboarding = find.text('Hızlı Kargo Takip').evaluate().isNotEmpty;
    final hasLogin = find.text('PaketGO\'ya Giriş').evaluate().isNotEmpty;
    final hasPaketGO = find.text('PaketGO').evaluate().isNotEmpty;

    expect(hasOnboarding || hasLogin || hasPaketGO, isTrue);
  });

  testWidgets('Onboarding screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Hızlı Kargo Takip'), findsOneWidget);
    expect(find.text('Devam'), findsOneWidget);
    expect(find.text('Atla'), findsOneWidget);
  });

  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('PaketGO\'ya Giriş'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
    expect(find.text('Google ile Giriş'), findsOneWidget);
    expect(find.text('Apple ile Giriş'), findsOneWidget);
  });
}
