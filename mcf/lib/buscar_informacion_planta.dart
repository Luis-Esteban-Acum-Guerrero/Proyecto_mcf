import 'dart:convert';
import 'package:http/http.dart' as http;

class PlantbookService {
  static const String _baseUrl = 'https://open.plantbook.io/api/v1';
  final String clientId;
  final String clientSecret;

  String? _accessToken;

  PlantbookService({required this.clientId, required this.clientSecret});

  // PASO 1: Obtener token OAuth2
  Future<void> authenticate() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/token/'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('Error autenticando: ${response.body}');
    }
  }

  // PASO 2: Buscar planta por nombre → retorna su pid
  Future<String> searchPlant(String alias) async {
    if (_accessToken == null) await authenticate();

    final response = await http.get(
      Uri.parse('$_baseUrl/plant/search/?alias=${Uri.encodeComponent(alias)}&limit=5'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;
      if (results.isEmpty) throw Exception('Planta no encontrada');
      // Retorna el pid del primer resultado
      return results[0]['pid'];
    } else {
      throw Exception('Error en búsqueda: ${response.body}');
    }
  }

  // PASO 3: Obtener condiciones de la planta por pid
  Future<PlantConditions> getPlantConditions(String pid) async {
    if (_accessToken == null) await authenticate();

    // "include=*" trae TODOS los datos incluidos humedad, temp, luz
    final response = await http.get(
      Uri.parse('$_baseUrl/plant/detail/${Uri.encodeComponent(pid)}/?include=*'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      return PlantConditions.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error obteniendo detalle: ${response.body}');
    }
  }

  // Método conveniente: nombre → condiciones directamente
  Future<PlantConditions> getConditionsByName(String plantName) async {
    final pid = await searchPlant(plantName);
    return getPlantConditions(pid);
  }
}

// Modelo con los campos que te interesan
class PlantConditions {
  final String pid;
  final String displayPid;

  // Humedad de suelo (%)
  final int? soilMoistureMin;
  final int? soilMoistureMax;

  // Humedad ambiente (%)
  final int? envHumidityMin;
  final int? envHumidityMax;

  // Temperatura (°C)
  final double? temperatureMin;
  final double? temperatureMax;

  // Luminosidad (lux)
  final int? lightLuxMin;
  final int? lightLuxMax;

  PlantConditions({
    required this.pid,
    required this.displayPid,
    this.soilMoistureMin,
    this.soilMoistureMax,
    this.envHumidityMin,
    this.envHumidityMax,
    this.temperatureMin,
    this.temperatureMax,
    this.lightLuxMin,
    this.lightLuxMax,
  });

  factory PlantConditions.fromJson(Map<String, dynamic> json) {
    return PlantConditions(
      pid: json['pid'] ?? '',
      displayPid: json['display_pid'] ?? '',
      soilMoistureMin: json['min_soil_moist'],
      soilMoistureMax: json['max_soil_moist'],
      envHumidityMin:  json['min_env_humid'],
      envHumidityMax:  json['max_env_humid'],
      temperatureMin:  (json['min_temp'] as num?)?.toDouble(),
      temperatureMax:  (json['max_temp'] as num?)?.toDouble(),
      lightLuxMin:     json['min_light_lux'],
      lightLuxMax:     json['max_light_lux'],
    );
  }

  @override
  String toString() => '''
  Planta: $displayPid
  Humedad suelo: $soilMoistureMin% – $soilMoistureMax%
  Humedad ambiente: $envHumidityMin% – $envHumidityMax%
  Temperatura: $temperatureMin°C – $temperatureMax°C
  Luminosidad: $lightLuxMin – $lightLuxMax lux
  ''';
}