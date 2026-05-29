import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/package_model.dart';
import '../models/courier_model.dart';
import '../models/food_order_model.dart';
import '../services/mock_data_service.dart';

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', state);
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? userName;
  final String? email;
  final String? phone;
  final String? error;

  AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.userName,
    this.email,
    this.phone,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? userName,
    String? email,
    String? phone,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      state = AuthState(
        isLoggedIn: true,
        userName: prefs.getString('userName') ?? 'Kullanıcı',
        email: prefs.getString('email') ?? '',
        phone: prefs.getString('phone') ?? '',
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', email);
      await prefs.setString('userName', email.split('@').first);
      state = AuthState(
        isLoggedIn: true,
        userName: email.split('@').first,
        email: email,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Geçersiz email veya şifre',
      );
    }
  }

  Future<void> register(String name, String email, String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('email', email);
    await prefs.setString('userName', name);
    await prefs.setString('phone', phone);
    state = AuthState(
      isLoggedIn: true,
      userName: name,
      email: email,
      phone: phone,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    state = AuthState();
  }
}

// Packages provider
final packagesProvider = StateNotifierProvider<PackagesNotifier, List<PackageModel>>((ref) {
  return PackagesNotifier();
});

class PackagesNotifier extends StateNotifier<List<PackageModel>> {
  PackagesNotifier() : super(MockDataService.getPackages());

  void addPackage(PackageModel package) {
    state = [...state, package];
  }

  void updateStatus(String id, String status) {
    state = state.map((p) {
      if (p.id == id) {
        return PackageModel(
          id: p.id,
          trackingNumber: p.trackingNumber,
          senderName: p.senderName,
          receiverName: p.receiverName,
          senderAddress: p.senderAddress,
          receiverAddress: p.receiverAddress,
          status: status,
          createdAt: p.createdAt,
          estimatedDelivery: p.estimatedDelivery,
          weight: p.weight,
          description: p.description,
          events: p.events,
        );
      }
      return p;
    }).toList();
  }
}

// Couriers provider
final couriersProvider = Provider<List<CourierModel>>((ref) {
  return MockDataService.getCouriers();
});

// Restaurants provider
final restaurantsProvider = Provider<List<Restaurant>>((ref) {
  return MockDataService.getRestaurants();
});

// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, Map<String, int>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Map<String, int>> {
  CartNotifier() : super({});

  void addItem(String itemId) {
    final current = state[itemId] ?? 0;
    state = {...state, itemId: current + 1};
  }

  void removeItem(String itemId) {
    final current = state[itemId] ?? 0;
    if (current <= 1) {
      state = Map.from(state)..remove(itemId);
    } else {
      state = {...state, itemId: current - 1};
    }
  }

  void clear() {
    state = {};
  }
}

// Favorites provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];
    state = favs.toSet();
  }

  Future<void> toggleFavorite(String id) async {
    if (state.contains(id)) {
      state = Set.from(state)..remove(id);
    } else {
      state = Set.from(state)..add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', state.toList());
  }
}

// Addresses provider
final addressesProvider = StateNotifierProvider<AddressesNotifier, List<UserAddress>>((ref) {
  return AddressesNotifier();
});

class UserAddress {
  final String id;
  final String title;
  final String fullAddress;
  final String city;
  final String district;
  final bool isDefault;

  UserAddress({
    required this.id,
    required this.title,
    required this.fullAddress,
    required this.city,
    required this.district,
    this.isDefault = false,
  });
}

class AddressesNotifier extends StateNotifier<List<UserAddress>> {
  AddressesNotifier()
      : super([
          UserAddress(
            id: '1',
            title: 'Ev',
            fullAddress: 'Kadıköy Mah. Bağdat Cad. No:123 D:4',
            city: 'İstanbul',
            district: 'Kadıköy',
            isDefault: true,
          ),
          UserAddress(
            id: '2',
            title: 'İş',
            fullAddress: 'Levent Mah. Büyükdere Cad. No:45 K:12',
            city: 'İstanbul',
            district: 'Beşiktaş',
          ),
        ]);

  void addAddress(UserAddress address) {
    state = [...state, address];
  }

  void removeAddress(String id) {
    state = state.where((a) => a.id != id).toList();
  }

  void setDefault(String id) {
    state = state.map((a) {
      return UserAddress(
        id: a.id,
        title: a.title,
        fullAddress: a.fullAddress,
        city: a.city,
        district: a.district,
        isDefault: a.id == id,
      );
    }).toList();
  }
}

// Coupons provider
final couponsProvider = Provider<List<Coupon>>((ref) {
  return [
    Coupon(id: '1', code: 'HOSGELDIN', discount: 50, description: 'İlk siparişe %50 indirim', isPercentage: true, minOrder: 100, expiresAt: DateTime.now().add(const Duration(days: 30))),
    Coupon(id: '2', code: 'KARGO20', discount: 20, description: '₺20 kargo indirimi', isPercentage: false, minOrder: 50, expiresAt: DateTime.now().add(const Duration(days: 15))),
    Coupon(id: '3', code: 'YEMEK30', discount: 30, description: 'Yemek siparişinde %30', isPercentage: true, minOrder: 150, expiresAt: DateTime.now().add(const Duration(days: 7))),
  ];
});

class Coupon {
  final String id;
  final String code;
  final double discount;
  final String description;
  final bool isPercentage;
  final double minOrder;
  final DateTime expiresAt;

  Coupon({
    required this.id,
    required this.code,
    required this.discount,
    required this.description,
    required this.isPercentage,
    required this.minOrder,
    required this.expiresAt,
  });
}

// Loyalty points provider
final loyaltyPointsProvider = StateProvider<int>((ref) => 450);

// Notifications provider
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;
  final String type;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    this.type = 'general',
  });
}

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier()
      : super([
          AppNotification(id: '1', title: 'Siparişiniz yolda!', body: 'PGO-2024-001 numaralı kargonuz Ankara\'ya doğru yola çıktı.', time: DateTime.now().subtract(const Duration(hours: 2)), type: 'delivery'),
          AppNotification(id: '2', title: '%50 İndirim Fırsatı!', body: 'İlk kargo gönderiminizde geçerli özel kampanya.', time: DateTime.now().subtract(const Duration(hours: 5)), type: 'promo'),
          AppNotification(id: '3', title: 'Kurye yaklaşıyor', body: 'Siparişiniz 5 dakika içinde kapınızda olacak.', time: DateTime.now().subtract(const Duration(minutes: 20)), type: 'delivery'),
          AppNotification(id: '4', title: 'Teslim edildi ✓', body: 'PGO-2024-002 numaralı kargonuz teslim edildi.', time: DateTime.now().subtract(const Duration(days: 2)), isRead: true, type: 'delivery'),
        ]);

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return AppNotification(
          id: n.id, title: n.title, body: n.body,
          time: n.time, isRead: true, type: n.type,
        );
      }
      return n;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => AppNotification(
      id: n.id, title: n.title, body: n.body,
      time: n.time, isRead: true, type: n.type,
    )).toList();
  }
}
