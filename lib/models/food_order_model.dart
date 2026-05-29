class FoodOrderModel {
  final String id;
  final String restaurantName;
  final String restaurantImage;
  final List<FoodItem> items;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final String deliveryAddress;
  final int estimatedMinutes;

  FoodOrderModel({
    required this.id,
    required this.restaurantName,
    required this.restaurantImage,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.deliveryAddress,
    required this.estimatedMinutes,
  });

  factory FoodOrderModel.fromJson(Map<String, dynamic> json) {
    return FoodOrderModel(
      id: json['id'] ?? '',
      restaurantName: json['restaurant_name'] ?? '',
      restaurantImage: json['restaurant_image'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => FoodItem.fromJson(e))
              .toList() ??
          [],
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      deliveryAddress: json['delivery_address'] ?? '',
      estimatedMinutes: json['estimated_minutes'] ?? 30,
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Onay Bekleniyor';
      case 'preparing':
        return 'Hazırlanıyor';
      case 'on_the_way':
        return 'Yolda';
      case 'delivered':
        return 'Teslim Edildi';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return 'Bilinmiyor';
    }
  }
}

class FoodItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      imageUrl: json['image_url'],
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final String cuisine;
  final int deliveryTime;
  final double deliveryFee;
  final double minOrder;
  final bool isOpen;
  final List<FoodItem> menu;

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.cuisine,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.minOrder,
    required this.isOpen,
    this.menu = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      cuisine: json['cuisine'] ?? '',
      deliveryTime: json['delivery_time'] ?? 30,
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      minOrder: (json['min_order'] ?? 0).toDouble(),
      isOpen: json['is_open'] ?? true,
      menu: (json['menu'] as List<dynamic>?)
              ?.map((e) => FoodItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}
