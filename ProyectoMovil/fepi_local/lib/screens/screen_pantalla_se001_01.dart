import 'package:fepi_local/constansts/app_buttons.dart';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class ScreenPantallaSe001 extends StatefulWidget {
  static const String routeName = '/screen_pantalla_se001';
  const ScreenPantallaSe001({super.key});

  @override
  _ScreenPantallaSe001State createState() => _ScreenPantallaSe001State();
}

class _ScreenPantallaSe001State extends State<ScreenPantallaSe001> {
  DateTime? _selectedDate;
  Map<String, Map<String, dynamic>> _asistenciaProfesores = {};

  @override
  void initState() {
    super.initState();
    _cargarDependientes();
  }

  void _cargarDependientes() async {
    final prefs = await getSavedPreferences();
    int idUsuario = prefs['id_Usuario'] ?? 0; // Cambia esto por el id_Usuario que necesites.
    Map<String, Map<String, dynamic>> dependientes = await DatabaseHelper().obtenerDependientesPorUsuario(idUsuario);
    setState(() {
      _asistenciaProfesores = dependientes;
    });
  }

  void _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _registrarAsistencia() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una fecha antes de registrar la asistencia.')),
      );
      return;
    }

    // Crear un listado con los datos de asistencia, incluyendo la fecha seleccionada
    List<Map<String, dynamic>> registroAsistencia = _asistenciaProfesores.entries.map((entry) {
      return {
        'id_Profesor': entry.value['id_Maestro'],
        'asistencia': entry.value['asistencia'],
        'entrada': entry.value['entrada'],
        'salida': entry.value['salida'],
        'fecha': _selectedDate!.toIso8601String().split('T')[0], // Fecha en formato YYYY-MM-DD
      };
    }).toList();

    final bd = await DatabaseHelper();
     final prefs = await getSavedPreferences();
      int idUsuario = prefs['id_Usuario'] ?? 0;
      await bd.insertarAsistencia(registroAsistencia, idUsuario); // Método para insertar registro en la BD
    

    // Opcional: Mostrar el resultado en la consola para verificar
    print('Registro de asistencia: $registroAsistencia');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro de asistencia enviado correctamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: AppColors.color1,),onPressed:(){context.pop();}),
        title: const Text('Monitoreo del desempeño de EC'),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    style: AppButtons.btnFORM(),
                    onPressed: () => _seleccionarFecha(context),
                    child: Text('Seleccionar Fecha', style: AppTextStyles.secondMedium(color: AppColors.color1)),
                  ),
                  const SizedBox(width: 16),
                  const SizedBox(height: 20),
                  Text(
                    _selectedDate == null
                        ? 'No se ha seleccionado fecha'
                        : 'Fecha seleccionada: ${_selectedDate!.toLocal()}'.split(' ')[0],
                    style: AppTextStyles.secondMedium(color: AppColors.color2, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _asistenciaProfesores.entries.map((entry) {
                  final String nombre = entry.key;
                  final Map<String, dynamic> datos = entry.value;

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nombre, style: AppTextStyles.secondMedium(color: AppColors.color3)),
                          const SizedBox(height: 10),
                          CheckboxListTile(
                            checkColor: AppColors.color1,
                            activeColor: AppColors.color3,
                            title: Text('Asistencia', style: AppTextStyles.secondRegular(color: AppColors.color2)),
                            value: datos['asistencia'],
                            onChanged: _selectedDate == null
                                ? null
                                : (bool? value) {
                                    setState(() {
                                      datos['asistencia'] = value ?? false;
                                      if (!datos['asistencia']) {
                                        datos['entrada'] = null;
                                        datos['salida'] = null;
                                      }
                                    });
                                  },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            decoration: AppButtons.textFieldStyle(labelText: 'Horario de entrada'),
                            keyboardType: TextInputType.datetime,
                            enabled: datos['asistencia'],
                            initialValue: datos['entrada'] ?? '',
                            onChanged: (value) {
                              setState(() {
                                datos['entrada'] = value;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            decoration: AppButtons.textFieldStyle(labelText: 'Horario de salida'),
                            keyboardType: TextInputType.datetime,
                            enabled: datos['asistencia'],
                            initialValue: datos['salida'] ?? '',
                            onChanged: (value) {
                              setState(() {
                                datos['salida'] = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _registrarAsistencia,
                style: AppButtons.btnFORM(backgroundColor: AppColors.color3),
                child: Text('Enviar Registro', style: AppTextStyles.secondMedium(color: AppColors.color1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
