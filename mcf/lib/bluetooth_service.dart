import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

const String serviceUUID        = "12345678-1234-1234-1234-123456789abc";
const String characteristicUUID = "abcd1234-ab12-ab12-ab12-abcdef123456";
const String espDeviceName      = "ESP32-EcoGuard";

class SensorData {
  final double temp;
  final double humAmb;
  final int    luz;
  final int    suelo;
  SensorData({required this.temp, required this.humAmb, required this.luz, required this.suelo});
  factory SensorData.fromJson(Map<String, dynamic> json) => SensorData(
    temp:   (json['temp']   as num).toDouble(),
    humAmb: (json['humAmb'] as num).toDouble(),
    luz:    (json['luz']    as num).toInt(),
    suelo:  (json['suelo']  as num).toInt(),
  );
}

class BleController extends ChangeNotifier {
  BluetoothDevice?         _device;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription<List<int>>?                _valueSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;

  String      status    = "Desconectado";
  bool        scanning  = false;
  bool        connected = false;
  SensorData? sensorData;

  Future<void> scanAndConnect() async {
    scanning = true; status = "Buscando ESP32..."; notifyListeners();
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));
      final result = await FlutterBluePlus.scanResults
          .map((r) => r.where((x) => x.device.platformName == espDeviceName))
          .where((r) => r.isNotEmpty).map((r) => r.first).first
          .timeout(const Duration(seconds: 9), onTimeout: () => throw Exception("No encontrado"));
      await FlutterBluePlus.stopScan();
      await _connect(result.device);
    } catch (_) {
      await FlutterBluePlus.stopScan();
      status = "No se encontró el ESP32"; scanning = false; notifyListeners();
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    _device = device;
    _connSub = device.connectionState.listen((s) {
      if (s == BluetoothConnectionState.disconnected) {
        connected = false; sensorData = null; status = "Desconectado"; notifyListeners();
      }
    });
    await device.connect();
    status = "Conectado, leyendo servicios..."; notifyListeners();
    final services = await device.discoverServices();
    for (final svc in services) {
      if (svc.uuid.toString().toLowerCase() == serviceUUID) {
        for (final c in svc.characteristics) {
          if (c.uuid.toString().toLowerCase() == characteristicUUID) {
            _characteristic = c;
            await c.setNotifyValue(true);
            _valueSub = c.onValueReceived.listen(_parseData);
          }
        }
      }
    }
    connected = true; scanning = false; status = "Conectado a $espDeviceName"; notifyListeners();
  }

  void _parseData(List<int> value) {
    try { sensorData = SensorData.fromJson(jsonDecode(String.fromCharCodes(value))); notifyListeners(); } catch (_) {}
  }

  Future<void> disconnect() async {
    await _valueSub?.cancel(); await _connSub?.cancel(); await _device?.disconnect();
    _device = null; _characteristic = null; connected = false; sensorData = null;
    status = "Desconectado"; notifyListeners();
  }
}
