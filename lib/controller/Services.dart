import 'dart:developer'; // Add this line to import the 'dart:developer' package

import 'package:app_freemarket/controller/Connection.dart';
import 'package:app_freemarket/models/ResponseGeneric.dart';
import 'package:app_freemarket/models/Session.dart';
import 'package:app_freemarket/models/Sucursal.dart';
import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Services {
  final Connection _con = Connection();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String getMedia() {
    return Connection.URL_MEDIA;
  }

  Future<Session> session(Map<dynamic, dynamic> map) async {
    ResponseGeneric rg = await _con.post("sesion", map);
    Session s = Session();
    print(rg.code);
    s.add(rg);
    if (rg.code == '200') {
      s.token = s.datos["token"];
      s.user = s.datos["user"];
      s.external_id = s.datos["external_id"];
      await _secureStorage.write(key: 'token', value: s.token);
      await _secureStorage.write(key: 'user', value: s.user);
      await _secureStorage.write(key: 'external_id', value: s.external_id);
    }

    return s;
  }

  Future<ResponseGeneric> getSucursales() async {
    return _con.get("sucursal");
  }

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'token');
  }

  Future<String?> _getExternal() async {
    return await _secureStorage.read(key: 'external_id');
  }

  Future<ResponseGeneric> getProductos(String external_id) async {
    String? token = await _getToken();
    return _con.get("/productos/Sucursal/$external_id", token: token);
  }

  Future<ResponseGeneric> getProductosCaducados(String external_id) async {
    String? token = await _getToken();
    return _con.get("/producto/listar/caducados/$external_id", token: token);
  }

  Future<ResponseGeneric> getPersona() async {
    String? token = await _getToken();
    String? external_id = await _getExternal();
    return _con.get("persona/$external_id", token: token);
  }

  Future<ResponseGeneric> guardarPersona(
      String external_id, Map<dynamic, dynamic> map) async {
    String? token = await _getToken();
    return _con.post("modificar_cuenta/$external_id", map, token: token);
  }

  Future<ResponseGeneric> getProductosPorCaducar(String external_id) async {
    String? token = await _getToken();
    return _con.get("/productos/por_caducar/$external_id", token: token);
  }

  Future<ResponseGeneric> getProductosBueno(String external_id) async {
    String? token = await _getToken();
    return _con.get("/productos/buenos/$external_id", token: token);
  }

Future<ResponseGeneric> getTipo() async {
  String? tipo = await (_secureStorage.read(key: 'selectedOptions'));

  // Eliminar los corchetes y espacios en blanco
  tipo = tipo?.replaceAll('[', '').replaceAll(']', '').trim();
  print('Tipo leído del almacenamiento seguro: $tipo'); // Depuración

  switch (tipo) {
    case 'Hoteles':
      tipo = 'Hotel';
      break;
    case 'Parques':
      tipo = 'Parque';
      break;
    case 'Escuelas':
      tipo = 'Escuela';

      break;
    default:
      tipo =  null;
      break;
  }
  return _con.get("sucursal/tipo/$tipo");
}
}