import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'address_screen.dart';
import 'coupons_screen.dart';
import 'settings_screen.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final points = ref.watch(loyaltyPointsProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(auth),
            const SizedBox(height: 24),
            _buildStatsRow(points),
            const SizedBox(height: 24),
            _buildMenuSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthState auth) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primaryColor, Color(0xFF8B83FF)]),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Center(
            child: Text(
              (auth.userName ?? 'U')[0].toUpperCase(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(auth.userName ?? 'Kullanıcı', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text(auth.email ?? '', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildStatsRow(int points) {
    return Row(
      children: [
        _buildStatItem('12', 'Gönderim', AppTheme.primaryColor),
        const SizedBox(width: 12),
        _buildStatItem('$points', 'Puan', AppTheme.secondaryColor),
        const SizedBox(width: 12),
        _buildStatItem('4.8', 'Ortalama', AppTheme.warningColor),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    final menuItems = [
      _MenuItem(Icons.person_rounded, 'Hesap Bilgileri', AppTheme.primaryColor, null),
      _MenuItem(Icons.location_on_rounded, 'Adreslerim', AppTheme.accentColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen()))),
      _MenuItem(Icons.credit_card_rounded, 'Ödeme Yöntemleri', AppTheme.warningColor, null),
      _MenuItem(Icons.card_giftcard_rounded, 'Kuponlar & Puanlar', AppTheme.secondaryColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CouponsScreen()))),
      _MenuItem(Icons.notifications_rounded, 'Bildirim Ayarları', AppTheme.primaryColor, null),
      _MenuItem(Icons.settings_rounded, 'Ayarlar', AppTheme.textSecondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
      _MenuItem(Icons.help_rounded, 'Yardım & Destek', AppTheme.accentColor, null),
      _MenuItem(Icons.logout_rounded, 'Çıkış Yap', AppTheme.errorColor, () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
        }
      }),
    ];

    return Column(
      children: menuItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: ListTile(
            onTap: item.onTap,
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: item.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            title: Text(item.title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: item.color == AppTheme.errorColor ? AppTheme.errorColor : AppTheme.textPrimary)),
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary.withOpacity(0.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      }).toList(),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  _MenuItem(this.icon, this.title, this.color, this.onTap);
}
