import 'package:app_freemarket/models/ResponseGeneric.dart';

class Session extends ResponseGeneric {
  String token = '';
  String user = '';
  String external_id = '';
  void add(ResponseGeneric rg) {
    code = rg.code;
    message = rg.message;
    datos = rg.datos;
  }
}
