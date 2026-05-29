import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
            child: Text('Tümünü Oku', style: GoogleFonts.poppins(color: AppTheme.primaryColor, fontSize: 13)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.notifications_off_rounded, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('Bildirim yok', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (_, i) => _buildNotificationCard(notifications[i], ref),
            ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif, WidgetRef ref) {
    final icon = notif.type == 'promo' ? Icons.local_offer_rounded : Icons.local_shipping_rounded;
    final color = notif.type == 'promo' ? AppTheme.secondaryColor : AppTheme.primaryColor;

    return GestureDetector(
      onTap: () => ref.read(notificationsProvider.notifier).markAsRead(notif.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : AppTheme.primaryColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: notif.isRead ? null : Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(notif.title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w600)),
                const SizedBox(height: 4),
                Text(notif.body, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                Text(_timeAgo(notif.time), style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
              ]),
            ),
            if (!notif.isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    return '${diff.inDays} gün önce';
  }
}
