import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'chat/chat_screen.dart';

class TrackingMapScreen extends StatefulWidget {
  final String trackingNumber;
  final String status;
  const TrackingMapScreen({super.key, required this.trackingNumber, required this.status});

  @override
  State<TrackingMapScreen> createState() => _TrackingMapScreenState();
}

class _TrackingMapScreenState extends State<TrackingMapScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _timer;
  int _etaMinutes = 8;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_etaMinutes > 1 && mounted) setState(() => _etaMinutes--);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Simulated map background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green.shade50, Colors.blue.shade50, Colors.green.shade100],
              ),
            ),
            child: CustomPaint(painter: _MapPainter()),
          ),
          // Courier marker (animated)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: MediaQuery.of(context).size.width * 0.45,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) {
                final scale = 1.0 + (_pulseController.value * 0.15);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 15, spreadRadius: 2)],
                    ),
                    child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 30),
                  ),
                );
              },
            ),
          ),
          // Destination marker
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            right: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.successColor.withOpacity(0.4), blurRadius: 10)],
              ),
              child: const Icon(Icons.flag_rounded, color: Colors.white, size: 22),
            ),
          ),
          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary), onPressed: () => Navigator.pop(context)),
              ),
            ),
          ),
          // Bottom sheet
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: SafeArea(
                top: false,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 20),
                  Row(children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.local_shipping_rounded, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.trackingNumber, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('Tahmini varış: ~$_etaMinutes dakika', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.successColor, fontWeight: FontWeight.w500)),
                    ])),
                  ]),
                  const SizedBox(height: 20),
                  // Courier info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      CircleAvatar(radius: 20, backgroundColor: AppTheme.primaryColor.withOpacity(0.12), child: Text('E', style: GoogleFonts.poppins(color: AppTheme.primaryColor, fontWeight: FontWeight.w600))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Emre Aydın', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                        Row(children: [
                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          Text(' 4.8 • Motosiklet', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
                        ]),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _buildActionChip(Icons.phone_rounded, 'Ara', AppTheme.successColor, () {}),
                    _buildActionChip(Icons.chat_rounded, 'Mesaj', AppTheme.primaryColor, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                    }),
                    _buildActionChip(Icons.share_rounded, 'Paylaş', AppTheme.warningColor, () {}),
                  ]),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 22)),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
      ]),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw simulated roads
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw route line
    final routePaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.6)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.48, size.height * 0.38);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.3, size.width * 0.75, size.height * 0.22);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
