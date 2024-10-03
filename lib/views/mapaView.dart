import 'package:app_freemarket/controller/Services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Importa flutter_secure_storage

class MapaView extends StatefulWidget {
  const MapaView({super.key});

  @override
  _MapaViewState createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  LatLng? _currentPosition;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); // Crea una instancia de FlutterSecureStorage
  List<Map<String, dynamic>> _lugares = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getSecureStorageData();
    cargarLugares(); // Llama a la función para obtener los datos del secure storage
  }

  void cargarLugares() async {
    try {
      Services lugar = Services();
      final value = await lugar.getTipo();
      if (value.code == '200' && value.datos != null) {
        List<dynamic> lugares = value.datos;
        print(value.datos);
        setState(() {
          _lugares = lugares
              .where((element) =>
                  element != null && element is Map<String, dynamic>)
              .map((element) {
            var lugares = element as Map<String, dynamic>;
            return {
              'nombre': lugares['nombre'],
              'tipo': lugares['tipo'],
              'latitud': lugares['latitud'],
              'longitud': lugares['longitud'],
            };
          }).toList();
        });
      } else {
        print("Error en la respuesta de la API: ${value.code}");
      }
    } catch (e) {
      print("Error al cargar lugares: $e");
    }
  }

  Future<void> _getSecureStorageData() async {
    // Obtén las opciones almacenadas en el secure storage
    String? selectedOptions = await _secureStorage.read(key: 'selectedOptions');
    
    if (selectedOptions != null) {
      print('Selected options from secure storage: $selectedOptions');
    } else {
      print('No options found in secure storage.');
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                center: _currentPosition,
                zoom: 13.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentPosition!,
                      child: Container(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ),
                    ),
                    ..._lugares.map((lugar) {
                      return Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(lugar['latitud'], lugar['longitud']),
                        child: Container(
                          child: Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 40.0,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}