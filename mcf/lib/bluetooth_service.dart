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
  final int luz;
  final int suelo;

  SensorData({
    required this.temp,
    required this.humAmb,
    required this.luz,
    required this.suelo,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temp: (json["temp"] as num).toDouble(),
      humAmb: (json["humAmb"] as num).toDouble(),
      luz: json["luz"] as int,
      suelo: json["suelo"] as int,
    );
  }
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
  if (connected || scanning) return;
  scanning = true;
  status = "Buscando ESP32...";
  notifyListeners();
  try {
    await FlutterBluePlus.stopScan();
    FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        print("--------------------------------\n");
        print("Nombre anuncio : ${r.advertisementData.advName}\n");
        print("Platform Name  : ${r.device.platformName}\n");
        print("ID             : ${r.device.remoteId}\n");

      }
    });
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 8),
    );
    final result = await FlutterBluePlus.scanResults
        .map((results) => results.where((r) =>
            r.advertisementData.advName == espDeviceName ||
            r.device.platformName == espDeviceName))
        .where((results) => results.isNotEmpty)
        .map((results) => results.first)
        .first
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw Exception("ESP32 no encontrado"),
        );
    await FlutterBluePlus.stopScan();
    await _connect(result.device);
  } catch (e) {
    await FlutterBluePlus.stopScan();
    connected = false;
    scanning = false;
    status = "ESP32 no encontrado";
    print(e);
    notifyListeners();
  }
}
  Future<void> _connect(BluetoothDevice device) async {
  _device = device;
  status = "Conectando...";
  notifyListeners();
  try {
    await device.connect(
      timeout: const Duration(seconds: 15),
    );
    print("Conectado al ESP32");
    _connSub?.cancel();
    _connSub = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        connected = false;
        sensorData = null;
        status = "Desconectado";
        notifyListeners();
      }
    });
    status = "Descubriendo servicios...";
    notifyListeners();
    final services = await device.discoverServices();
    BluetoothCharacteristic? caracteristica;
    for (final service in services) {
      print("Servicio: ${service.uuid}");
      if (service.uuid.toString().toLowerCase() ==
          serviceUUID.toLowerCase()) {
        for (final c in service.characteristics) {
          print("Característica: ${c.uuid}");
          if (c.uuid.toString().toLowerCase() ==
              characteristicUUID.toLowerCase()) {
            caracteristica = c;
          }
        }
      }
    }
    if (caracteristica == null) {
      throw Exception("Característica BLE no encontrada");
    }
    _characteristic = caracteristica;
    await _characteristic!.setNotifyValue(true);
    _valueSub?.cancel();
    _valueSub = _characteristic!.onValueReceived.listen(_parseData);
    connected = true;
    scanning = false;
    status = "Conectado a $espDeviceName";
    notifyListeners();
  } catch (e) {
    print(e);
    connected = false;
    scanning = false;
    status = "Error de conexión";
    notifyListeners();
  }
}
  void _parseData(List<int> value) {
  try {
    final texto = String.fromCharCodes(value);
    print("--------------------------------");
    print("JSON recibido:");
    print(texto);
    final json = jsonDecode(texto);
    sensorData = SensorData.fromJson(json);
    notifyListeners();
  } catch (e) {
    print("Error leyendo JSON ");
    print(e);
  }
}

  Future<void> disconnect() async {

  try {
    await _valueSub?.cancel();
    await _connSub?.cancel();
    if (_device != null) {
      await _device!.disconnect();
    }
  } catch (_) {}
  _device = null;
  _characteristic = null;
  sensorData = null;
  connected = false;
  scanning = false;
  status = "Desconectado";
  notifyListeners();
}
}
