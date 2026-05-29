import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şifre Sıfırla')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.lock_reset_rounded, size: 40, color: AppTheme.primaryColor),
          ),
        ),
        const SizedBox(height: 24),
        Text('Şifrenizi mi unuttunuz?', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text('E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.', style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 14)),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: 'E-posta', prefixIcon: const Icon(Icons.email_rounded, color: AppTheme.primaryColor)),
        ),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() => _sent = true), child: const Text('Gönder'))),
      ],
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: AppTheme.successColor.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.mark_email_read_rounded, size: 50, color: AppTheme.successColor),
          ),
          const SizedBox(height: 24),
          Text('E-posta Gönderildi!', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Şifre sıfırlama bağlantısı\n${_emailController.text} adresine gönderildi.', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Giriş Ekranına Dön')),
        ],
      ),
    );
  }
}
