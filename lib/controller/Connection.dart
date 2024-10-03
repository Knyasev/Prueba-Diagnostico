import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_freemarket/models/ResponseGeneric.dart';

class Connection {
  final String urlBase = "http://localhost:5000/";
  static const String URL_MEDIA = "http://localhost:5000/media";

  Future<ResponseGeneric> get(String resource, {token = "NONE"}) async {
    final String url = urlBase + resource;
    Map<String, String> headers = {
      'Content-Type': "application/json",
      "Accept": "application/json",
    };

    if (token != "NONE") {
      headers["X-Access-Tokens"] = token;
    }

    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      return _response(body['code'].toString(), body['msg'], body['datos']);
    } else {
      throw Exception('Failed to load data');
    }
  }

  ResponseGeneric _response(String code, String msg, dynamic datos) {
    var response = ResponseGeneric();
    response.message = msg;
    response.code = code;
    response.datos = datos;
    return response;
  }

  Future<ResponseGeneric> post(String resource, Map<dynamic, dynamic> data,
      {token = "NONE"}) async {
    final String url = urlBase + resource;
    Map<String, String> headers = {
      'Content-Type': "application/json",
      "Accept": "application/json",
    };

    if (token != "NONE") {
      headers["X-Access-Tokens"] = token;
    }

    final uri = Uri.parse(url);
    final response =
        await http.post(uri, headers: headers, body: jsonEncode(data));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body == null ||
          !body.containsKey('code') ||
          !body.containsKey('msg') ||
          !body.containsKey('datos')) {
        throw Exception('Respuesta inesperada del servidor');
      }
      Map<String, dynamic> datos =
          body['datos'] != null ? Map<String, dynamic>.from(body['datos']) : {};
      return _response(body['code'].toString(), body['msg'], datos);
    } else {
      throw Exception('Failed to post data');
    }
  }
}
