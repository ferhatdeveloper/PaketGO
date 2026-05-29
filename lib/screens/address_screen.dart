import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Adreslerim')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Yeni Adres', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
      ),
      body: addresses.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.location_off_rounded, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('Henüz adres eklenmemiş', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (_, i) => _buildAddressCard(addresses[i]),
            ),
    );
  }

  Widget _buildAddressCard(UserAddress address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: address.isDefault ? Border.all(color: AppTheme.primaryColor, width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(address.title == 'Ev' ? Icons.home_rounded : Icons.work_rounded, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(address.title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                        child: Text('Varsayılan', style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ]),
                  Text('${address.district}, ${address.city}', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
                ]),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'default') ref.read(addressesProvider.notifier).setDefault(address.id);
                  if (v == 'delete') ref.read(addressesProvider.notifier).removeAddress(address.id);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'default', child: Text('Varsayılan Yap')),
                  const PopupMenuItem(value: 'delete', child: Text('Sil')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(address.fullAddress, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final titleC = TextEditingController();
    final addressC = TextEditingController();
    final cityC = TextEditingController(text: 'İstanbul');
    final districtC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Yeni Adres Ekle', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Başlık (Ev, İş...)', prefixIcon: Icon(Icons.label_rounded))),
          const SizedBox(height: 12),
          TextField(controller: addressC, decoration: const InputDecoration(labelText: 'Tam Adres', prefixIcon: Icon(Icons.location_on_rounded)), maxLines: 2),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: cityC, decoration: const InputDecoration(labelText: 'Şehir'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: districtC, decoration: const InputDecoration(labelText: 'İlçe'))),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(addressesProvider.notifier).addAddress(UserAddress(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleC.text.isEmpty ? 'Adres' : titleC.text,
                  fullAddress: addressC.text,
                  city: cityC.text,
                  district: districtC.text,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Kaydet'),
            ),
          ),
        ]),
      ),
    );
  }
}
