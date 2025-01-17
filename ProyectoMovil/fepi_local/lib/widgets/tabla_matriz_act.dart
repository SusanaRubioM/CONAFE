import 'dart:ffi';

import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class TablaMatrizAct extends StatefulWidget {
  const TablaMatrizAct({Key? key}) : super(key: key);

  @override
  _TablaMatrizActState createState() => _TablaMatrizActState();
}

class _TablaMatrizActState extends State<TablaMatrizAct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numeroCapacitacionController =
      TextEditingController();
  final TextEditingController _temaController = TextEditingController();

  DateTime? _fechaProgramada;
  List<Map<String, dynamic>> regiones = [];
  List<Map<String, dynamic>> microrregiones = [];
  List<Map<String, dynamic>> ccts = [];
  String? _selectedMicrorregionId;  // Cambiado para almacenar el ID
  String? _selectedCCTId;           // Cambiado para almacenar el ID

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final db = await DatabaseHelper();
    final prefs = await getSavedPreferences();
    final int idUsuario = prefs['id_Usuario'] ?? 0;

    final estructura = await db.obtenerEstructuraRegion(idUsuario);

    setState(() {
      regiones = estructura;
      print(regiones);
      if (regiones.isNotEmpty) {
        microrregiones = regiones[0]['Microrregiones']
            ?.map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
            .toList() ?? [];
        if (microrregiones.isNotEmpty) {
          ccts = microrregiones[0]['CCTs']
              ?.map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
              .toList() ?? [];
        }
      }
    });
  }

  Future<void> insertarDatosActCAP(Map<String, dynamic> datos) async {
    final db = await DatabaseHelper();
    final prefs = await getSavedPreferences();
    final Map<String, dynamic> dataToInsert = {
      'id_Usuario': prefs['id_Usuario'] ?? 0,
      'NumCapacitacion': datos['NumeroCapacitacion'],
      'TEMA': datos['Tema'],
      'id_Region': regiones.isNotEmpty ? regiones[0]['RegionId'] : null,
      'id_Microregion': datos['MicrorregionId'],  // Enviar el ID de la microrregión
      'id_CCT': datos['CCTId'],                   // Enviar el ID del CCT
      'FechaProgramada': datos['FechaProgramada'],
      'Estado': datos['Estado'],
      'Reporte': datos['Reporte'],
    };
    print(dataToInsert);
    await db.insertarDatosActCAP(dataToInsert);
  }

  void _asignar() {
    if (_formKey.currentState!.validate()) {
      String fechaProgramadaTexto = _fechaProgramada != null
          ? _fechaProgramada!.toLocal().toString().split(' ')[0]
          : '';

      final Map<String, dynamic> datos = {
        'NumeroCapacitacion': _numeroCapacitacionController.text,
        'Tema': _temaController.text,
        'MicrorregionId': _selectedMicrorregionId, // Usar el ID de la microrregión
        'CCTId': _selectedCCTId,                   // Usar el ID del CCT
        'FechaProgramada': fechaProgramadaTexto,
        'Estado': 'activo',
        'Reporte': '',
      };
      print(datos);
      insertarDatosActCAP(datos);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos asignados con éxito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario Matriz Act'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _numeroCapacitacionController,
                  decoration: const InputDecoration(
                      labelText: 'Número de Capacitación'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa un número';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _temaController,
                  decoration: const InputDecoration(labelText: 'Tema'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa un tema';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedMicrorregionId, // Usar el ID
                  decoration: const InputDecoration(labelText: 'Microrregión'),
                  items: microrregiones
                      .map((microregion) => DropdownMenuItem<String>(
                            value: microregion['MicrorregionId'].toString(), // Usar ID
                            child: Text(microregion['Microrregion']),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMicrorregionId = value;  // Asignar el ID de la microrregión
                      _selectedCCTId = null;
                      ccts = microrregiones
                          .firstWhere(
                              (micro) => micro['MicrorregionId'].toString() == value)['CCTs']
                          .map<Map<String, dynamic>>(
                              (e) => e as Map<String, dynamic>)
                          .toList();
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecciona una microrregión';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCCTId, // Usar el ID
                  decoration: const InputDecoration(labelText: 'CCT'),
                  items: ccts
                      .map((cct) => DropdownMenuItem<String>(
                            value: cct['CCTId'],  // Usar ID
                            child: Text('${cct['CCTId']} - ${cct['CCTNombre']}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCCTId = value;
                      print(_selectedCCTId);  // Asignar el ID del CCT
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecciona un CCT';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _fechaProgramada == null
                            ? 'Fecha Programada: No seleccionada'
                            : 'Fecha Programada: ${_fechaProgramada!.toLocal()}'.split(' ')[0],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _fechaProgramada = selectedDate;
                          });
                        }
                      },
                      child: const Text('Seleccionar Fecha'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _asignar,
                  child: const Text('Asignar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
