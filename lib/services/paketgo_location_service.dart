import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../config/paketgo_config.dart';

class PaketGoLocationService {
  PaketGoLocationService({
    required this.jwtToken,
    required this.courierId,
    this.config = const PaketGoConfig(postgrestBaseUrl: 'https://api.paketgo.com'),
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String jwtToken;
  final String courierId;
  final PaketGoConfig config;
  final http.Client _httpClient;
  StreamSubscription<Position>? _positionSubscription;

  Future<void> startLocationTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const PaketGoLocationException('Konum servisleri kapali.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const PaketGoLocationException('Konum izni reddedildi.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const PaketGoLocationException('Konum izni kalici olarak reddedildi.');
    }

    await _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      unawaited(
        sendLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          bearing: position.heading.isNaN ? 0 : position.heading,
        ),
      );
    });
  }

  Future<void> sendLocation({
    required double latitude,
    required double longitude,
    required double bearing,
  }) async {
    final response = await _httpClient.post(
      config.endpoint('/pg_live_locations', <String, String>{
        'on_conflict': 'courier_id',
      }),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
        'Prefer': 'resolution=merge-duplicates',
      },
      body: jsonEncode(<String, Object>{
        'courier_id': courierId,
        'coordinates': 'SRID=4326;POINT($longitude $latitude)',
        'bearing': bearing,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PaketGoLocationException(
        'Konum gonderme hatasi: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> stopLocationTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void dispose() {
    unawaited(stopLocationTracking());
    _httpClient.close();
  }
}

class PaketGoLocationException implements Exception {
  const PaketGoLocationException(this.message);

  final String message;

  @override
  String toString() => message;
}
