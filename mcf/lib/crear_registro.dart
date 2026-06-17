import 'package:flutter/material.dart';

class CrearRegistroPage extends StatelessWidget {
  const CrearRegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Registro'),
      ),
      body: const Center(
        child: Text('Pantalla para crear registros'),
      ),
    );
  }
}