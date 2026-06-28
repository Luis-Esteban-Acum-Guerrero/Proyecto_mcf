import 'package:flutter/material.dart';

class CrearRegistroPage extends StatefulWidget {
  const CrearRegistroPage({super.key});

  @override
  State<CrearRegistroPage> createState() => _CrearRegistroPageState();
}

class _CrearRegistroPageState extends State<CrearRegistroPage> {
  String nombre    = '';
  String tipo      = '';
  String bluetooth = '';

  @override
  Widget build(BuildContext context) {
    // El botón Guardar solo se activa si nombre y tipo tienen texto
    final bool puedeGuardar = nombre.trim().isNotEmpty && tipo.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nombre de la planta:'),
            TextField(
              onChanged: (v) => setState(() => nombre = v),
              decoration: const InputDecoration(hintText: 'Ej: Pedro'),
            ),

            const SizedBox(height: 20),

            const Text('Tipo de planta:'),
            TextField(
              onChanged: (v) => setState(() => tipo = v),
              decoration: const InputDecoration(hintText: 'Ej: Hierba, Flor, Árbol...'),
            ),

            const SizedBox(height: 20),

            const Text('Dirección Bluetooth (opcional):'),
            TextField(
              onChanged: (v) => setState(() => bluetooth = v),
              decoration: const InputDecoration(hintText: 'Ej: AA:BB:CC:DD:EE:FF'),
            ),

            const SizedBox(height: 32),

            // Botón guardar — devuelve los datos a main.dart
            ElevatedButton.icon(
              onPressed: puedeGuardar
                  ? () {
                      Navigator.pop(context, {
                        'nombre':    nombre.trim(),
                        'tipo':      tipo.trim(),
                        'bluetooth': bluetooth.trim(),
                      });
                    }
                  : null,
              icon: const Icon(Icons.save),
              label: const Text('Guardar planta'),
            ),
          ],
        ),
      ),
    );
  }
}
