import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../home_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next.isLoggedIn) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hesap Oluştur', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Bilgilerinizi girerek ücretsiz hesap oluşturun', style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Ad Soyad', prefixIcon: const Icon(Icons.person_rounded, color: AppTheme.primaryColor), labelStyle: GoogleFonts.poppins()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'E-posta', prefixIcon: const Icon(Icons.email_rounded, color: AppTheme.primaryColor), labelStyle: GoogleFonts.poppins()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Telefon', prefixIcon: const Icon(Icons.phone_rounded, color: AppTheme.primaryColor), hintText: '+90 5XX XXX XXXX', labelStyle: GoogleFonts.poppins()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Şifre',
                prefixIcon: const Icon(Icons.lock_rounded, color: AppTheme.primaryColor),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                labelStyle: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                  activeColor: AppTheme.primaryColor,
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(text: 'Kullanım koşullarını ', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary), children: [
                      TextSpan(text: 'kabul ediyorum', style: GoogleFonts.poppins(color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (authState.isLoading || !_acceptTerms) ? null : () {
                  ref.read(authProvider.notifier).register(
                    _nameController.text,
                    _emailController.text,
                    _phoneController.text,
                    _passwordController.text,
                  );
                },
                child: authState.isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Kayıt Ol'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
