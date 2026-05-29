import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class CouponsScreen extends ConsumerWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupons = ref.watch(couponsProvider);
    final points = ref.watch(loyaltyPointsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kuponlar & Puanlar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointsCard(points),
            const SizedBox(height: 24),
            Text('Aktif Kuponlar', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...coupons.map((c) => _buildCouponCard(c, context)),
            const SizedBox(height: 24),
            _buildRedeemSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard(int points) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.secondaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Text('Toplam Puanınız', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 8),
          Text('$points', style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
          Text('puan', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text('Her ₺10 harcama = 1 puan', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon, BuildContext context) {
    final daysLeft = coupon.expiresAt.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
            ),
            child: Column(children: [
              Text(coupon.isPercentage ? '%${coupon.discount.toInt()}' : '₺${coupon.discount.toInt()}', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              Text('İndirim', style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.primaryColor)),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(coupon.description, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Min. ₺${coupon.minOrder.toInt()} • $daysLeft gün kaldı', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: coupon.code));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${coupon.code} kopyalandı!'), backgroundColor: AppTheme.successColor));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(border: Border.all(color: AppTheme.primaryColor, style: BorderStyle.solid), borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(coupon.code, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor, letterSpacing: 1)),
                      const SizedBox(width: 6),
                      const Icon(Icons.copy_rounded, size: 14, color: AppTheme.primaryColor),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Puan Harca', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _buildRedeemItem('100 puan', '₺10 indirim kuponu'),
          _buildRedeemItem('250 puan', '₺30 indirim kuponu'),
          _buildRedeemItem('500 puan', 'Ücretsiz kargo'),
        ],
      ),
    );
  }

  Widget _buildRedeemItem(String points, String reward) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppTheme.warningColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.card_giftcard_rounded, color: AppTheme.warningColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(reward, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(points, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text('Kullan', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
