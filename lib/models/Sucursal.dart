import 'package:app_freemarket/models/ResponseGeneric.dart';

class Sucursal extends ResponseGeneric {
  String direccion = '';
  double latitud = 0.0;
  double longitud = 0.0;
  String nombre = '';
  void add(ResponseGeneric rg) {
    code = rg.code;
    message = rg.message;
    datos = rg.datos;
  }
}
