import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../config/paketgo_config.dart';
import '../services/paketgo_api_client.dart';

class PaketGoNfcPaymentScreen extends StatefulWidget {
  const PaketGoNfcPaymentScreen({
    super.key,
    required this.orderId,
    required this.jwtToken,
    this.config = const PaketGoConfig(postgrestBaseUrl: 'https://api.paketgo.com'),
  });

  final String orderId;
  final String jwtToken;
  final PaketGoConfig config;

  @override
  State<PaketGoNfcPaymentScreen> createState() => _PaketGoNfcPaymentScreenState();
}

class _PaketGoNfcPaymentScreenState extends State<PaketGoNfcPaymentScreen> {
  late final PaketGoApiClient _apiClient;
  bool _isProcessing = false;
  String _statusMessage = 'Odeme almak icin butona basip karti cihaza yaklastirin.';

  @override
  void initState() {
    super.initState();
    _apiClient = PaketGoApiClient(
      jwtToken: widget.jwtToken,
      config: widget.config,
    );
  }

  @override
  void dispose() {
    _apiClient.close();
    unawaited(NfcManager.instance.stopSession());
    super.dispose();
  }

  Future<void> _initiateNfcPayment() async {
    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      _setStatus('Cihazda NFC destegi bulunmuyor.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Kart okunuyor... Lutfen sabitleyin.';
    });

    await NfcManager.instance.startSession(
      pollingOptions: const <NfcPollingOption>{
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      onDiscovered: (tag) async {
        try {
          final cardToken = jsonEncode(tag.data);
          await NfcManager.instance.stopSession();
          await _completePaymentOnBackend(cardToken);
        } catch (_) {
          await NfcManager.instance.stopSession(errorMessageIos: 'Okuma hatasi.');
          if (mounted) {
            setState(() {
              _isProcessing = false;
              _statusMessage = 'Kart okunamadi, tekrar deneyin.';
            });
          }
        }
      },
    );
  }

  Future<void> _completePaymentOnBackend(String token) async {
    try {
      final result = await _apiClient.processNfcPayment(
        orderId: widget.orderId,
        transactionToken: token,
      );

      if (!mounted) return;
      _setStatus(
        result.isSuccess ? 'Odeme alindi! Siparis kapatildi.' : 'Hata: ${result.message}',
      );
    } on PaketGoApiException catch (error) {
      if (!mounted) return;
      _setStatus('Hata: ${error.message}');
    } catch (_) {
      if (!mounted) return;
      _setStatus('Baglanti hatasi olustu.');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _setStatus(String message) {
    if (!mounted) return;
    setState(() => _statusMessage = message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PaketGO - Kapida NFC Odeme')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.nfc,
                size: 100,
                color: _isProcessing ? Colors.orange : Colors.blue,
              ),
              const SizedBox(height: 30),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isProcessing ? null : _initiateNfcPayment,
                child: const Text('NFC Odemeyi Baslat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
