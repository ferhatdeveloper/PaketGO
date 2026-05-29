import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Görünüm', [
            _buildSwitchTile('Karanlık Mod', Icons.dark_mode_rounded, isDark, (v) => ref.read(themeProvider.notifier).toggleTheme()),
          ]),
          _buildSection('Bildirimler', [
            _buildSwitchTile('Push Bildirimler', Icons.notifications_rounded, true, (_) {}),
            _buildSwitchTile('E-posta Bildirimleri', Icons.email_rounded, false, (_) {}),
            _buildSwitchTile('Kampanya Bildirimleri', Icons.local_offer_rounded, true, (_) {}),
          ]),
          _buildSection('Gizlilik', [
            _buildTile('Konum İzni', Icons.location_on_rounded, 'Her zaman'),
            _buildTile('Veri Paylaşımı', Icons.analytics_rounded, 'Anonim'),
          ]),
          _buildSection('Dil', [
            _buildTile('Uygulama Dili', Icons.language_rounded, 'Türkçe'),
          ]),
          _buildSection('Hakkında', [
            _buildTile('Versiyon', Icons.info_rounded, '1.0.0'),
            _buildTile('Lisanslar', Icons.description_rounded, ''),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      ),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
        child: Column(children: children),
      ),
    ]);
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      secondary: Icon(icon, color: AppTheme.primaryColor, size: 22),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildTile(String title, IconData icon, String trailing) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor, size: 22),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      trailing: Text(trailing, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
    );
  }
}
