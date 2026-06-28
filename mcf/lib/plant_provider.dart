import 'package:flutter/material.dart';

// Guarda la lista de plantas y notifica a la UI cuando cambia
class PlantProvider extends ChangeNotifier {
  final List<Map<String, String>> _plants = [];

  List<Map<String, String>> get plants => List.unmodifiable(_plants);

  void addPlant(Map<String, String> plant) {
    _plants.add(plant);
    notifyListeners();
  }

  void removePlant(int index) {
    _plants.removeAt(index);
    notifyListeners();
  }
}
