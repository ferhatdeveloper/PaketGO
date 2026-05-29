class PackageModel {
  final String id;
  final String trackingNumber;
  final String senderName;
  final String receiverName;
  final String senderAddress;
  final String receiverAddress;
  final String status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final double weight;
  final String description;
  final List<TrackingEvent> events;

  PackageModel({
    required this.id,
    required this.trackingNumber,
    required this.senderName,
    required this.receiverName,
    required this.senderAddress,
    required this.receiverAddress,
    required this.status,
    required this.createdAt,
    this.estimatedDelivery,
    required this.weight,
    required this.description,
    this.events = const [],
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] ?? '',
      trackingNumber: json['tracking_number'] ?? '',
      senderName: json['sender_name'] ?? '',
      receiverName: json['receiver_name'] ?? '',
      senderAddress: json['sender_address'] ?? '',
      receiverAddress: json['receiver_address'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.parse(json['estimated_delivery'])
          : null,
      weight: (json['weight'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => TrackingEvent.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'tracking_number': trackingNumber,
        'sender_name': senderName,
        'receiver_name': receiverName,
        'sender_address': senderAddress,
        'receiver_address': receiverAddress,
        'status': status,
        'weight': weight,
        'description': description,
      };

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Hazırlanıyor';
      case 'picked_up':
        return 'Teslim Alındı';
      case 'in_transit':
        return 'Yolda';
      case 'out_for_delivery':
        return 'Dağıtımda';
      case 'delivered':
        return 'Teslim Edildi';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return 'Bilinmiyor';
    }
  }
}

class TrackingEvent {
  final String id;
  final String description;
  final String location;
  final DateTime timestamp;
  final String status;

  TrackingEvent({
    required this.id,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.status,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
    );
  }
}
