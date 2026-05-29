class CourierModel {
  final String id;
  final String name;
  final String phone;
  final double rating;
  final String vehicleType;
  final String photoUrl;
  final double latitude;
  final double longitude;
  final bool isAvailable;
  final int deliveryCount;

  CourierModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.vehicleType,
    required this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.isAvailable,
    required this.deliveryCount,
  });

  factory CourierModel.fromJson(Map<String, dynamic> json) {
    return CourierModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      vehicleType: json['vehicle_type'] ?? 'motorcycle',
      photoUrl: json['photo_url'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      isAvailable: json['is_available'] ?? false,
      deliveryCount: json['delivery_count'] ?? 0,
    );
  }

  String get vehicleTypeText {
    switch (vehicleType) {
      case 'motorcycle':
        return 'Motosiklet';
      case 'bicycle':
        return 'Bisiklet';
      case 'car':
        return 'Araba';
      case 'van':
        return 'Minivan';
      default:
        return 'Diğer';
    }
  }
}
