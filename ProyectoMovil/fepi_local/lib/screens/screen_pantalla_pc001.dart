import 'package:flutter/material.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';

class ScreenPantallaPc001 extends StatefulWidget {
  static const String routeName = '/screen_pantalla_pc001';

  const ScreenPantallaPc001({super.key});

  @override
  State<ScreenPantallaPc001> createState() => _PantallaSolicitudesState();
}

class _PantallaSolicitudesState extends State<ScreenPantallaPc001> {
  final List<Map<String, dynamic>> solicitudes = [];

  /// Cargar solicitudes llamando a la función de la base de datos
  Future<void> _cargarSolicitudes() async {
    final prefs = await getSavedPreferences();
    final idUsuario = prefs['id_Usuario'] ?? 0;

    final resultado = await DatabaseHelper()
        .obtenerSolicitudesEducadores(idUsuario: idUsuario);
    setState(() {
      solicitudes.clear();
      solicitudes.addAll(resultado);
    });
  }

  /// Crear solicitud llamando a la función de inserción
  Future<void> _crearSolicitud(Map<String, dynamic> datosSolicitud) async {
    final prefs = await getSavedPreferences();
    final idUsuario = prefs['id_Usuario'] ?? 0;

    await DatabaseHelper().insertarSolicitudEducadores(
        idUsuario: idUsuario, datosSolicitud: datosSolicitud);
    await _cargarSolicitudes();
  }

  /// Mostrar formulario para crear una nueva solicitud
  void _mostrarFormulario() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SolicitudFormulario(onGuardar: (datosSolicitud) async {
            final confirmado = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirmación'),
                  content: const Text('¿Estás seguro de crear esta solicitud?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Confirmar'),
                    ),
                  ],
                );
              },
            );

            if (confirmado == true) {
              await _crearSolicitud(datosSolicitud);
              Navigator.pop(context);
            }
          }),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes'),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: solicitudes.length,
              itemBuilder: (context, index) {
                final solicitud = solicitudes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  child: ListTile(
                    leading: Icon(Icons.school, color: AppColors.color2),
                    title: Text(
                      solicitud['nombreEscuela'] ?? 'Escuela desconocida',
                      style: AppTextStyles.primaryRegular(
                        color: AppColors.color3,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          
                          child: Text(
                            'Estado: [${solicitud['estado']}]',
                            style: AppTextStyles.secondRegular(
                              color: AppColors.color2,
                            ),
                          ),
                        ),
                        Text(
                          'Descripción:',
                          style: AppTextStyles.secondRegular(
                            color: AppColors.color2,
                          ),
                        ),
                        Text(
                          'Requeridos: ${solicitud['numEducadores']}',
                          style: AppTextStyles.secondRegular(
                            color: AppColors.color2,
                          ),
                        ),
                        Text(
                          'Aprobados: ${solicitud['educadoresAsignados']}',
                          style: AppTextStyles.secondRegular(
                            color: AppColors.color2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.color3,
              ),
              onPressed: _mostrarFormulario,
              child: const Text('Crear Nueva Solicitud'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para el formulario de solicitud
class SolicitudFormulario extends StatefulWidget {
  final void Function(Map<String, dynamic> datosSolicitud) onGuardar;

  const SolicitudFormulario({required this.onGuardar, super.key});

  @override
  State<SolicitudFormulario> createState() => _SolicitudFormularioState();
}

class _SolicitudFormularioState extends State<SolicitudFormulario> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _periodoController = TextEditingController();
  final TextEditingController _numEducadoresController =
      TextEditingController();
  final TextEditingController _justificacionController =
      TextEditingController();
  final TextEditingController _contextoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _periodoController,
              decoration: const InputDecoration(
                labelText: 'Periodo',
                hintText: 'Ejemplo: 2024-2025',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _numEducadoresController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de Educadores',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _justificacionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Justificación',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _contextoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Contexto',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.color3),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onGuardar({
                    'periodo': _periodoController.text,
                    'numEducadores': int.tryParse(
                          _numEducadoresController.text,
                        ) ??
                        0,
                    'justificacion': _justificacionController.text,
                    'contexto': _contextoController.text,
                    'estado': 'en revision',
                    'educadoresAsignados': 0,
                  });
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
