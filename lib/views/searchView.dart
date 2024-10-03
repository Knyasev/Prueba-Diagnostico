import 'package:app_freemarket/views/mapaView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SearchView extends StatefulWidget {
  const SearchView({ Key? key }) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Lista de opciones y su estado de selección
  final Map<String, bool> _options = {
    'Hoteles' : false,
    'Parques': false,
    'Escuelas': false,
  };

  // Función para manejar el cambio de estado de los checkboxes
  void _onOptionChanged(String key, bool? value) {
    setState(() {
      _options[key] = value ?? false;
    });
  }

  // Función para manejar la acción del botón de búsqueda
  void _onSearch() {
    final selectedOptions = _options.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    _secureStorage.write(key: 'selectedOptions', value: selectedOptions.toString());
    
    // Aquí puedes manejar las opciones seleccionadas, por ejemplo, imprimirlas
    print('Opciones seleccionadas: $selectedOptions');

    // Redirigir a la pantalla de MapaView
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapaView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Búsqueda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Crear checkboxes para cada opción
            ..._options.keys.map((key) {
              return CheckboxListTile(
                title: Text(key),
                value: _options[key],
                onChanged: (value) => _onOptionChanged(key, value),
              );
            }).toList(),
            SizedBox(height: 20),
            // Botón de búsqueda
            ElevatedButton(
              onPressed: _onSearch,
              child: Text('Buscar'),
            ),
          ],
        ),
      ),
    );
  }
}