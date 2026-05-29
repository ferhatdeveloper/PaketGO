import 'package:flutter/material.dart';

import 'config/paketgo_config.dart';
import 'screens/nfc_payment_screen.dart';
import 'services/paketgo_location_service.dart';

void main() {
  runApp(const PaketGoApp());
}

class PaketGoApp extends StatelessWidget {
  const PaketGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = PaketGoConfig.fromEnvironment();

    return MaterialApp(
      title: 'PaketGO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: PaketGoHomeScreen(config: config),
    );
  }
}

class PaketGoHomeScreen extends StatefulWidget {
  const PaketGoHomeScreen({
    super.key,
    required this.config,
  });

  final PaketGoConfig config;

  @override
  State<PaketGoHomeScreen> createState() => _PaketGoHomeScreenState();
}

class _PaketGoHomeScreenState extends State<PaketGoHomeScreen> {
  final _jwtController = TextEditingController();
  final _courierIdController = TextEditingController();
  final _orderIdController = TextEditingController();
  PaketGoLocationService? _locationService;
  String _locationStatus = 'Konum takibi baslatilmadi.';

  @override
  void dispose() {
    _jwtController.dispose();
    _courierIdController.dispose();
    _orderIdController.dispose();
    _locationService?.dispose();
    super.dispose();
  }

  Future<void> _startTracking() async {
    final jwtToken = _jwtController.text.trim();
    final courierId = _courierIdController.text.trim();

    if (jwtToken.isEmpty || courierId.isEmpty) {
      setState(() => _locationStatus = 'JWT ve kurye ID zorunludur.');
      return;
    }

    final service = PaketGoLocationService(
      jwtToken: jwtToken,
      courierId: courierId,
      config: widget.config,
    );

    try {
      await service.startLocationTracking();
      _locationService?.dispose();
      _locationService = service;
      setState(() => _locationStatus = 'Konum takibi aktif.');
    } on PaketGoLocationException catch (error) {
      service.dispose();
      setState(() => _locationStatus = error.message);
    } catch (_) {
      service.dispose();
      setState(() => _locationStatus = 'Konum takibi baslatilamadi.');
    }
  }

  Future<void> _stopTracking() async {
    await _locationService?.stopLocationTracking();
    _locationService = null;
    setState(() => _locationStatus = 'Konum takibi durduruldu.');
  }

  void _openNfcPayment() {
    final jwtToken = _jwtController.text.trim();
    final orderId = _orderIdController.text.trim();

    if (jwtToken.isEmpty || orderId.isEmpty) {
      setState(() => _locationStatus = 'NFC odeme icin JWT ve siparis ID zorunludur.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaketGoNfcPaymentScreen(
          orderId: orderId,
          jwtToken: jwtToken,
          config: widget.config,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PaketGO Kurye Paneli')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            'PostgREST: ${widget.config.postgrestBaseUrl}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _jwtController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'JWT Token',
            ),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _courierIdController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Kurye Profil ID',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _orderIdController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Siparis ID',
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              FilledButton.icon(
                onPressed: _startTracking,
                icon: const Icon(Icons.my_location),
                label: const Text('Konum Takibini Baslat'),
              ),
              OutlinedButton.icon(
                onPressed: _stopTracking,
                icon: const Icon(Icons.location_disabled),
                label: const Text('Takibi Durdur'),
              ),
              FilledButton.tonalIcon(
                onPressed: _openNfcPayment,
                icon: const Icon(Icons.nfc),
                label: const Text('NFC Odeme Ekrani'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_locationStatus),
            ),
          ),
        ],
      ),
    );
  }
}
