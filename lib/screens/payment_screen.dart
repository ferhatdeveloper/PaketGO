import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  const PaymentScreen({super.key, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'card';
  bool _processing = false;
  bool _success = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme')),
      body: _success ? _buildSuccess() : _buildPaymentForm(),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 100, height: 100, decoration: BoxDecoration(color: AppTheme.successColor.withOpacity(0.12), shape: BoxShape.circle), child: const Icon(Icons.check_circle_rounded, size: 60, color: AppTheme.successColor)),
        const SizedBox(height: 24),
        Text('Ödeme Başarılı!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('₺${widget.amount.toStringAsFixed(0)} ödendi', style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.textSecondary)),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Tamam')),
      ]),
    );
  }

  Widget _buildPaymentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Toplam Tutar', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary)),
            Text('₺${widget.amount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          ]),
        ),
        const SizedBox(height: 24),
        Text('Ödeme Yöntemi', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildMethodCard('card', Icons.credit_card_rounded, 'Kredi/Banka Kartı', '**** 4242'),
        _buildMethodCard('wallet', Icons.account_balance_wallet_rounded, 'Dijital Cüzdan', 'PaketGO Pay'),
        _buildMethodCard('meal_card', Icons.restaurant_rounded, 'Yemek Kartı', 'Sodexo/Multinet'),
        _buildMethodCard('cod', Icons.money_rounded, 'Kapıda Ödeme', 'Nakit/Kart'),
        const SizedBox(height: 24),
        if (_selectedMethod == 'card') ...[
          Text('Kart Bilgileri', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Kart Numarası', prefixIcon: const Icon(Icons.credit_card), hintText: '0000 0000 0000 0000', labelStyle: GoogleFonts.poppins())),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(decoration: InputDecoration(labelText: 'Son Kullanma', hintText: 'AA/YY', labelStyle: GoogleFonts.poppins()))),
            const SizedBox(width: 12),
            Expanded(child: TextField(decoration: InputDecoration(labelText: 'CVV', hintText: '***', labelStyle: GoogleFonts.poppins()), obscureText: true)),
          ]),
          const SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Kart Üzerindeki İsim', labelStyle: GoogleFonts.poppins())),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _processing ? null : _processPayment,
            child: _processing
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('₺${widget.amount.toStringAsFixed(0)} Öde'),
          ),
        ),
        const SizedBox(height: 16),
        Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.lock_rounded, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text('256-bit SSL ile güvenli ödeme', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
        ])),
      ]),
    );
  }

  Widget _buildMethodCard(String key, IconData icon, String title, String subtitle) {
    final isSelected = _selectedMethod == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = key),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200, width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppTheme.primaryColor, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
          Radio<String>(value: key, groupValue: _selectedMethod, onChanged: (v) => setState(() => _selectedMethod = v!), activeColor: AppTheme.primaryColor),
        ]),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _processing = false; _success = true; });
  }
}
