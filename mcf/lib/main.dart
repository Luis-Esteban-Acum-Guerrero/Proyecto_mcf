// Flutter Demo Home Page
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bluetooth_service.dart';
import 'crear_registro.dart';
import 'monitor_page.dart';
import 'plant_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BleController()),
        ChangeNotifierProvider(create: (_) => PlantProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoGuard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 27, 113, 44),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'EcoGuard'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final plants = context.watch<PlantProvider>().plants;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.sensors),
            tooltip: "Monitor de sensores",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MonitorPage()),
            ),
          ),
        ],
      ),
      body: plants.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Centro de plantas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    'Presiona + para agregar tu primera planta.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  final plant = plants[index];
                  return _PlantCard(plant: plant, index: index);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Map<String, String>>(
            context,
            MaterialPageRoute(builder: (_) => const CrearRegistroPage()),
          );
          if (result != null) {
            context.read<PlantProvider>().addPlant(result);
          }
        },
        tooltip: 'Agregar planta',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Map<String, String> plant;
  final int index;
  const _PlantCard({required this.plant, required this.index});

  // Color de fondo según el tipo de planta
  Color _cardColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'árbol':
      case 'arbol':   return const Color(0xFFE8F5E9);
      case 'hierba':  return const Color(0xFFF1F8E9);
      case 'flor':    return const Color(0xFFFCE4EC);
      case 'cactus':  return const Color(0xFFFFF8E1);
      default:        return const Color(0xFFE3F2FD);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre    = plant['nombre']    ?? 'Sin nombre';
    final tipo      = plant['tipo']      ?? 'Sin tipo';
    final bluetooth = plant['bluetooth'] ?? 'Sin dirección';

    return Card(
      elevation: 3,
      color: _cardColor(tipo),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono y botón eliminar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.eco, size: 36, color: Colors.green),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () => context.read<PlantProvider>().removePlant(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Nombre
            Text(
              nombre,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Tipo
            Row(children: [
              const Icon(Icons.local_florist, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(tipo, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ]),
            const SizedBox(height: 4),
            // Bluetooth
            Row(children: [
              const Icon(Icons.bluetooth, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  bluetooth,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
