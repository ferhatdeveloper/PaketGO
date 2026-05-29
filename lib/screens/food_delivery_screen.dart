import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/food_order_model.dart';
import '../services/mock_data_service.dart';

class FoodDeliveryScreen extends StatefulWidget {
  const FoodDeliveryScreen({super.key});

  @override
  State<FoodDeliveryScreen> createState() => _FoodDeliveryScreenState();
}

class _FoodDeliveryScreenState extends State<FoodDeliveryScreen> {
  List<Restaurant> _restaurants = [];
  String _selectedCuisine = 'Tümü';
  final Map<String, int> _cart = {};
  Restaurant? _selectedRestaurant;

  @override
  void initState() {
    super.initState();
    _restaurants = MockDataService.getRestaurants();
  }

  List<Restaurant> get _filteredRestaurants {
    if (_selectedCuisine == 'Tümü') return _restaurants;
    return _restaurants.where((r) => r.cuisine == _selectedCuisine).toList();
  }

  double get _cartTotal {
    double total = 0;
    if (_selectedRestaurant == null) return total;
    for (final entry in _cart.entries) {
      final item = _selectedRestaurant!.menu.firstWhere((i) => i.id == entry.key);
      total += item.price * entry.value;
    }
    return total;
  }

  int get _cartItemCount => _cart.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedRestaurant?.name ?? 'Yemek Sipariş'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_selectedRestaurant != null) {
              setState(() {
                _selectedRestaurant = null;
                _cart.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _selectedRestaurant != null ? _buildMenu() : _buildRestaurantList(),
      bottomSheet: _cartItemCount > 0 ? _buildCartBar() : null,
    );
  }

  Widget _buildRestaurantList() {
    return Column(
      children: [
        _buildCuisineFilter(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _filteredRestaurants.length,
            itemBuilder: (context, index) {
              return _buildRestaurantCard(_filteredRestaurants[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCuisineFilter() {
    final cuisines = ['Tümü', 'Türk Mutfağı', 'İtalyan', 'Japon', 'Fast Food'];
    return Container(
      height: 46,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cuisines.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCuisine == cuisines[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedCuisine = cuisines[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.secondaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.secondaryColor : Colors.grey.shade200,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                cuisines[index],
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return GestureDetector(
      onTap: restaurant.isOpen
          ? () => setState(() => _selectedRestaurant = restaurant)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.restaurant_rounded,
                color: AppTheme.warningColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        restaurant.name,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: restaurant.isOpen
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                      ),
                      if (!restaurant.isOpen) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Kapalı',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.cuisine,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.rating}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.deliveryTime} dk',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Min: ₺${restaurant.minOrder.toInt()}',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return ListView.builder(
      padding: const EdgeInsets.all(20).copyWith(bottom: _cartItemCount > 0 ? 90 : 20),
      itemCount: _selectedRestaurant!.menu.length,
      itemBuilder: (context, index) {
        final item = _selectedRestaurant!.menu[index];
        final quantity = _cart[item.id] ?? 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fastfood_rounded, color: AppTheme.accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '₺${item.price.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (quantity > 0) ...[
                    _buildQuantityButton(
                      Icons.remove,
                      () => setState(() {
                        if (quantity == 1) {
                          _cart.remove(item.id);
                        } else {
                          _cart[item.id] = quantity - 1;
                        }
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '$quantity',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  _buildQuantityButton(
                    Icons.add,
                    () => setState(() {
                      _cart[item.id] = (quantity) + 1;
                    }),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 18),
      ),
    );
  }

  Widget _buildCartBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_cartItemCount ürün',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
                ),
                Text(
                  '₺${_cartTotal.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sipariş oluşturuldu! ₺${_cartTotal.toStringAsFixed(0)}'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                setState(() {
                  _cart.clear();
                  _selectedRestaurant = null;
                });
              },
              child: const Text('Sipariş Ver'),
            ),
          ],
        ),
      ),
    );
  }
}
