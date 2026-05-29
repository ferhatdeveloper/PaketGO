import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedCategory = 'Tümü';
  final Map<String, int> _cart = {};

  final _categories = ['Tümü', 'Su & İçecek', 'Atıştırmalık', 'Temel Gıda', 'Temizlik', 'Kişisel Bakım'];

  final _products = [
    _Product(id: '1', name: 'Erikli Su 6x1.5L', price: 85, category: 'Su & İçecek', icon: Icons.water_drop_rounded),
    _Product(id: '2', name: 'Damacana 19L', price: 55, category: 'Su & İçecek', icon: Icons.water_drop_rounded),
    _Product(id: '3', name: 'Cola 1L', price: 35, category: 'Su & İçecek', icon: Icons.local_drink_rounded),
    _Product(id: '4', name: 'Ayran 1L', price: 25, category: 'Su & İçecek', icon: Icons.local_drink_rounded),
    _Product(id: '5', name: 'Cips Paket', price: 30, category: 'Atıştırmalık', icon: Icons.cookie_rounded),
    _Product(id: '6', name: 'Çikolata', price: 20, category: 'Atıştırmalık', icon: Icons.cookie_rounded),
    _Product(id: '7', name: 'Kuruyemiş 200g', price: 65, category: 'Atıştırmalık', icon: Icons.cookie_rounded),
    _Product(id: '8', name: 'Ekmek', price: 12, category: 'Temel Gıda', icon: Icons.bakery_dining_rounded),
    _Product(id: '9', name: 'Süt 1L', price: 35, category: 'Temel Gıda', icon: Icons.egg_rounded),
    _Product(id: '10', name: 'Yumurta 15\'li', price: 80, category: 'Temel Gıda', icon: Icons.egg_rounded),
    _Product(id: '11', name: 'Peynir 400g', price: 95, category: 'Temel Gıda', icon: Icons.egg_rounded),
    _Product(id: '12', name: 'Deterjan 3L', price: 120, category: 'Temizlik', icon: Icons.cleaning_services_rounded),
    _Product(id: '13', name: 'Bulaşık Sıvısı', price: 45, category: 'Temizlik', icon: Icons.cleaning_services_rounded),
    _Product(id: '14', name: 'Şampuan', price: 70, category: 'Kişisel Bakım', icon: Icons.shower_rounded),
    _Product(id: '15', name: 'Diş Macunu', price: 40, category: 'Kişisel Bakım', icon: Icons.shower_rounded),
  ];

  List<_Product> get _filteredProducts {
    if (_selectedCategory == 'Tümü') return _products;
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  double get _cartTotal {
    double total = 0;
    for (final entry in _cart.entries) {
      final product = _products.firstWhere((p) => p.id == entry.key);
      total += product.price * entry.value;
    }
    return total;
  }

  int get _cartCount => _cart.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hızlı Market'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(color: AppTheme.accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.accentColor),
              const SizedBox(width: 4),
              Text('~15 dk', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.accentColor, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategories(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
              itemCount: _filteredProducts.length,
              itemBuilder: (_, i) => _buildProductCard(_filteredProducts[i]),
            ),
          ),
          if (_cartCount > 0) _buildCartBar(),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 46,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final isSelected = _selectedCategory == _categories[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[i]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppTheme.accentColor : Colors.grey.shade200),
              ),
              alignment: Alignment.center,
              child: Text(_categories[i], style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : AppTheme.textSecondary)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(_Product product) {
    final qty = _cart[product.id] ?? 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: AppTheme.accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(product.icon, color: AppTheme.accentColor, size: 26),
          ),
          Text(product.name, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
          Text('₺${product.price.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
          qty > 0
              ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _qtyBtn(Icons.remove, () => setState(() { if (qty == 1) { _cart.remove(product.id); } else { _cart[product.id] = qty - 1; } })),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('$qty', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                  _qtyBtn(Icons.add, () => setState(() => _cart[product.id] = qty + 1)),
                ])
              : GestureDetector(
                  onTap: () => setState(() => _cart[product.id] = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                    child: Text('Ekle', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 28, height: 28, decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 16, color: AppTheme.primaryColor)),
    );
  }

  Widget _buildCartBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -3))]),
      child: SafeArea(
        child: Row(children: [
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$_cartCount ürün', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
            Text('₺${_cartTotal.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Market siparişi oluşturuldu! ~15 dk\'da kapınızda'), backgroundColor: AppTheme.successColor));
              setState(() => _cart.clear());
              Navigator.pop(context);
            },
            child: const Text('Sipariş Ver'),
          ),
        ]),
      ),
    );
  }
}

class _Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final IconData icon;

  _Product({required this.id, required this.name, required this.price, required this.category, required this.icon});
}
