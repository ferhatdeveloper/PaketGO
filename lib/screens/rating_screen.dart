import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class RatingScreen extends StatefulWidget {
  final String orderType;
  final String name;

  const RatingScreen({super.key, required this.orderType, required this.name});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _deliveryRating = 0;
  double _serviceRating = 0;
  final _commentController = TextEditingController();
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Değerlendirme')),
      body: _submitted ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(color: AppTheme.successColor.withOpacity(0.12), shape: BoxShape.circle),
          child: const Icon(Icons.thumb_up_rounded, size: 50, color: AppTheme.successColor),
        ),
        const SizedBox(height: 24),
        Text('Teşekkürler!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Değerlendirmeniz kaydedildi.', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam')),
      ]),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
                child: Text(widget.name[0], style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
              ),
              const SizedBox(height: 12),
              Text(widget.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              Text(widget.orderType == 'food' ? 'Yemek Siparişi' : 'Kargo Teslimatı', style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 32),
          Text('Teslimat Hızı', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Center(
            child: RatingBar.builder(
              initialRating: _deliveryRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: Colors.amber),
              onRatingUpdate: (r) => setState(() => _deliveryRating = r),
            ),
          ),
          const SizedBox(height: 24),
          Text(widget.orderType == 'food' ? 'Yemek Kalitesi' : 'Paket Durumu', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Center(
            child: RatingBar.builder(
              initialRating: _serviceRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: Colors.amber),
              onRatingUpdate: (r) => setState(() => _serviceRating = r),
            ),
          ),
          const SizedBox(height: 24),
          Text('Yorum (İsteğe bağlı)', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(hintText: 'Deneyiminizi paylaşın...', hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400)),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('Fotoğraf Ekle', style: GoogleFonts.poppins(color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _deliveryRating > 0 ? () => setState(() => _submitted = true) : null,
              child: const Text('Değerlendir'),
            ),
          ),
        ],
      ),
    );
  }
}
