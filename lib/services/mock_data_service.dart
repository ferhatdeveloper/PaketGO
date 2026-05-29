import '../models/package_model.dart';
import '../models/courier_model.dart';
import '../models/food_order_model.dart';

class MockDataService {
  static List<PackageModel> getPackages() {
    return [
      PackageModel(
        id: '1',
        trackingNumber: 'PGO-2024-001',
        senderName: 'Ahmet Yılmaz',
        receiverName: 'Mehmet Kaya',
        senderAddress: 'Kadıköy, İstanbul',
        receiverAddress: 'Çankaya, Ankara',
        status: 'in_transit',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        estimatedDelivery: DateTime.now().add(const Duration(days: 1)),
        weight: 2.5,
        description: 'Elektronik cihaz',
        events: [
          TrackingEvent(
            id: '1',
            description: 'Paket teslim alındı',
            location: 'Kadıköy Şube',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            status: 'picked_up',
          ),
          TrackingEvent(
            id: '2',
            description: 'Transfer merkezine ulaştı',
            location: 'İstanbul Dağıtım Merkezi',
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
            status: 'in_transit',
          ),
          TrackingEvent(
            id: '3',
            description: 'Ankara\'ya yola çıktı',
            location: 'İstanbul Dağıtım Merkezi',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            status: 'in_transit',
          ),
        ],
      ),
      PackageModel(
        id: '2',
        trackingNumber: 'PGO-2024-002',
        senderName: 'Ayşe Demir',
        receiverName: 'Fatma Şahin',
        senderAddress: 'Beşiktaş, İstanbul',
        receiverAddress: 'Bornova, İzmir',
        status: 'delivered',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        estimatedDelivery: DateTime.now().subtract(const Duration(days: 2)),
        weight: 1.2,
        description: 'Kıyafet paketi',
        events: [
          TrackingEvent(
            id: '4',
            description: 'Paket teslim alındı',
            location: 'Beşiktaş Şube',
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
            status: 'picked_up',
          ),
          TrackingEvent(
            id: '5',
            description: 'Teslim edildi',
            location: 'Bornova, İzmir',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            status: 'delivered',
          ),
        ],
      ),
      PackageModel(
        id: '3',
        trackingNumber: 'PGO-2024-003',
        senderName: 'Can Öztürk',
        receiverName: 'Ali Vural',
        senderAddress: 'Nilüfer, Bursa',
        receiverAddress: 'Keçiören, Ankara',
        status: 'pending',
        createdAt: DateTime.now(),
        weight: 5.0,
        description: 'Kitap kolisi',
        events: [],
      ),
    ];
  }

  static List<CourierModel> getCouriers() {
    return [
      CourierModel(
        id: '1',
        name: 'Emre Aydın',
        phone: '+90 532 111 2233',
        rating: 4.8,
        vehicleType: 'motorcycle',
        photoUrl: '',
        latitude: 41.0082,
        longitude: 28.9784,
        isAvailable: true,
        deliveryCount: 342,
      ),
      CourierModel(
        id: '2',
        name: 'Burak Çelik',
        phone: '+90 533 444 5566',
        rating: 4.6,
        vehicleType: 'bicycle',
        photoUrl: '',
        latitude: 41.0122,
        longitude: 28.9760,
        isAvailable: true,
        deliveryCount: 156,
      ),
      CourierModel(
        id: '3',
        name: 'Deniz Kara',
        phone: '+90 535 777 8899',
        rating: 4.9,
        vehicleType: 'car',
        photoUrl: '',
        latitude: 41.0052,
        longitude: 28.9820,
        isAvailable: false,
        deliveryCount: 521,
      ),
      CourierModel(
        id: '4',
        name: 'Serkan Yıldız',
        phone: '+90 536 222 3344',
        rating: 4.7,
        vehicleType: 'van',
        photoUrl: '',
        latitude: 41.0150,
        longitude: 28.9700,
        isAvailable: true,
        deliveryCount: 89,
      ),
    ];
  }

  static List<Restaurant> getRestaurants() {
    return [
      Restaurant(
        id: '1',
        name: 'Kebapçı Mehmet Usta',
        imageUrl: '',
        rating: 4.7,
        cuisine: 'Türk Mutfağı',
        deliveryTime: 25,
        deliveryFee: 15.0,
        minOrder: 80.0,
        isOpen: true,
        menu: [
          FoodItem(id: '1', name: 'Adana Kebap', price: 180.0, quantity: 1),
          FoodItem(id: '2', name: 'Urfa Kebap', price: 170.0, quantity: 1),
          FoodItem(id: '3', name: 'Pide', price: 120.0, quantity: 1),
          FoodItem(id: '4', name: 'Lahmacun', price: 60.0, quantity: 1),
          FoodItem(id: '5', name: 'Ayran', price: 20.0, quantity: 1),
        ],
      ),
      Restaurant(
        id: '2',
        name: 'Pizza House',
        imageUrl: '',
        rating: 4.5,
        cuisine: 'İtalyan',
        deliveryTime: 30,
        deliveryFee: 10.0,
        minOrder: 100.0,
        isOpen: true,
        menu: [
          FoodItem(id: '6', name: 'Margarita Pizza', price: 150.0, quantity: 1),
          FoodItem(id: '7', name: 'Pepperoni Pizza', price: 180.0, quantity: 1),
          FoodItem(id: '8', name: 'Karışık Pizza', price: 200.0, quantity: 1),
          FoodItem(id: '9', name: 'Cola', price: 30.0, quantity: 1),
        ],
      ),
      Restaurant(
        id: '3',
        name: 'Sushi Master',
        imageUrl: '',
        rating: 4.8,
        cuisine: 'Japon',
        deliveryTime: 40,
        deliveryFee: 20.0,
        minOrder: 150.0,
        isOpen: true,
        menu: [
          FoodItem(id: '10', name: 'Salmon Sushi Set', price: 280.0, quantity: 1),
          FoodItem(id: '11', name: 'California Roll', price: 200.0, quantity: 1),
          FoodItem(id: '12', name: 'Miso Çorba', price: 60.0, quantity: 1),
        ],
      ),
      Restaurant(
        id: '4',
        name: 'Burger King',
        imageUrl: '',
        rating: 4.3,
        cuisine: 'Fast Food',
        deliveryTime: 20,
        deliveryFee: 5.0,
        minOrder: 50.0,
        isOpen: true,
        menu: [
          FoodItem(id: '13', name: 'Whopper Menü', price: 160.0, quantity: 1),
          FoodItem(id: '14', name: 'Chicken Burger', price: 130.0, quantity: 1),
          FoodItem(id: '15', name: 'Patates Kızartması', price: 50.0, quantity: 1),
        ],
      ),
      Restaurant(
        id: '5',
        name: 'Çiğ Köfteci Ali',
        imageUrl: '',
        rating: 4.6,
        cuisine: 'Türk Mutfağı',
        deliveryTime: 15,
        deliveryFee: 8.0,
        minOrder: 40.0,
        isOpen: false,
        menu: [
          FoodItem(id: '16', name: 'Çiğ Köfte Dürüm', price: 55.0, quantity: 1),
          FoodItem(id: '17', name: 'Çiğ Köfte Porsiyon', price: 70.0, quantity: 1),
          FoodItem(id: '18', name: 'Şalgam', price: 15.0, quantity: 1),
        ],
      ),
    ];
  }

  static List<FoodOrderModel> getFoodOrders() {
    return [
      FoodOrderModel(
        id: '1',
        restaurantName: 'Kebapçı Mehmet Usta',
        restaurantImage: '',
        items: [
          FoodItem(id: '1', name: 'Adana Kebap', price: 180.0, quantity: 2),
          FoodItem(id: '5', name: 'Ayran', price: 20.0, quantity: 2),
        ],
        totalPrice: 415.0,
        status: 'on_the_way',
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        deliveryAddress: 'Kadıköy, İstanbul',
        estimatedMinutes: 10,
      ),
    ];
  }
}
