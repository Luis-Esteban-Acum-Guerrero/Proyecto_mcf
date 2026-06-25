
import 'main.dart';
import 'package:flutter/material.dart';




class CrearRegistroPage extends StatefulWidget {
  const CrearRegistroPage({super.key});

  @override
  State<CrearRegistroPage> createState() => _CrearRegistroPageState();
}

class _CrearRegistroPageState extends State<CrearRegistroPage> {
  String nombre = '';
  String tipo = '';
  String bluetooth = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Ingrese el nombre de la planta:'),

            TextField(
              onChanged: (texto) {
                setState(() {
                  nombre = texto;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Ej: pedro',
              ),
            ),

            const SizedBox(height: 20),

            Text('Nombre ingresado: $nombre'),

            const Text('Ingrese el tipo de planta:'),

            TextField(
              onChanged: (texto) {
                setState(() {
                  tipo = texto;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Ej: hierba',
              ),
            ),

            const SizedBox(height: 20),

            Text('Tipo ingresado: $tipo'),

            const Text('Ingrese la dirección Bluetooth:'),

            TextField(
              onChanged: (texto) {
                setState(() {
                  bluetooth = texto;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Ej: AA:BB:CC:DD:EE:FF',
              ),
            ),

            const SizedBox(height: 20),

            Text('Bluetooth ingresado: $bluetooth'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyApp(),
            ),
          );
        },
        tooltip: 'Finalizar Registro',
        child: const Icon(Icons.check),
      ),
    );
  }
}