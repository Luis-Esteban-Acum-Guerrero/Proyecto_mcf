import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bluetooth_service.dart';

class MonitorPage extends StatelessWidget {
  const MonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Monitor de sensores"),
        actions: [
          if (ble.connected)
            IconButton(icon: const Icon(Icons.bluetooth_disabled), tooltip: "Desconectar", onPressed: ble.disconnect),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ble.connected ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ble.connected ? Colors.green.shade200 : Colors.grey.shade300),
              ),
              child: Row(children: [
                Icon(ble.connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                    color: ble.connected ? Colors.green : Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(ble.status, style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                children: [
                  _SensorCard(icon: Icons.thermostat, label: "Temperatura",
                      value: ble.sensorData != null ? "${ble.sensorData!.temp.toStringAsFixed(1)} °C" : "--", color: Colors.orange),
                  _SensorCard(icon: Icons.water_drop, label: "Humedad Aire",
                      value: ble.sensorData != null ? "${ble.sensorData!.humAmb.toStringAsFixed(1)} %" : "--", color: Colors.blue),
                  _SensorCard(icon: Icons.wb_sunny, label: "Luz (ADC)",
                      value: ble.sensorData != null ? "${ble.sensorData!.luz}" : "--", color: Colors.amber),
                  _SensorCard(icon: Icons.grass, label: "Humedad Suelo",
                      value: ble.sensorData != null ? "${ble.sensorData!.suelo} %" : "--", color: Colors.green),
                ],
              ),
            ),
            if (!ble.connected)
              ElevatedButton.icon(
                onPressed: ble.scanning ? null : ble.scanAndConnect,
                icon: const Icon(Icons.bluetooth_searching),
                label: Text(ble.scanning ? "Buscando..." : "Conectar al ESP32"),
              ),
          ],
        ),
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  final IconData icon; final String label; final String value; final Color color;
  const _SensorCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
