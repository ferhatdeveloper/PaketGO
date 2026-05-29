import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/courier_model.dart';
import '../services/mock_data_service.dart';

class CourierScreen extends StatefulWidget {
  const CourierScreen({super.key});

  @override
  State<CourierScreen> createState() => _CourierScreenState();
}

class _CourierScreenState extends State<CourierScreen> {
  List<CourierModel> _couriers = [];
  String _selectedVehicle = 'all';
  bool _isRequestSent = false;

  @override
  void initState() {
    super.initState();
    _couriers = MockDataService.getCouriers();
  }

  List<CourierModel> get _filteredCouriers {
    if (_selectedVehicle == 'all') return _couriers;
    return _couriers.where((c) => c.vehicleType == _selectedVehicle).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurye Çağır'),
      ),
      body: _isRequestSent ? _buildRequestSent() : _buildCourierList(),
    );
  }

  Widget _buildRequestSent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.successColor,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Kurye Çağrıldı!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'En yakın kurye size yönlendirildi.\nTahmini varış: 5-10 dakika',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => setState(() => _isRequestSent = false),
              child: const Text('Tamam'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourierList() {
    return Column(
      children: [
        _buildVehicleFilter(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _filteredCouriers.length,
            itemBuilder: (context, index) {
              return _buildCourierCard(_filteredCouriers[index]);
            },
          ),
        ),
        _buildCallButton(),
      ],
    );
  }

  Widget _buildVehicleFilter() {
    final filters = [
      {'key': 'all', 'label': 'Tümü', 'icon': Icons.all_inclusive_rounded},
      {'key': 'motorcycle', 'label': 'Motor', 'icon': Icons.two_wheeler_rounded},
      {'key': 'bicycle', 'label': 'Bisiklet', 'icon': Icons.pedal_bike_rounded},
      {'key': 'car', 'label': 'Araba', 'icon': Icons.directions_car_rounded},
      {'key': 'van', 'label': 'Minivan', 'icon': Icons.airport_shuttle_rounded},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedVehicle == filter['key'];
          return GestureDetector(
            onTap: () => setState(() => _selectedVehicle = filter['key'] as String),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourierCard(CourierModel courier) {
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
          CircleAvatar(
            radius: 26,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
            child: Text(
              courier.name[0],
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
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
                      courier.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!courier.isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Meşgul',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${courier.rating}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.local_shipping_rounded, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${courier.deliveryCount} teslimat',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(
                _getVehicleIcon(courier.vehicleType),
                color: AppTheme.primaryColor,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                courier.vehicleTypeText,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => setState(() => _isRequestSent = true),
          icon: const Icon(Icons.delivery_dining_rounded),
          label: const Text('Kurye Çağır'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type) {
      case 'motorcycle':
        return Icons.two_wheeler_rounded;
      case 'bicycle':
        return Icons.pedal_bike_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'van':
        return Icons.airport_shuttle_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }
}
