import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AgendaWidget extends StatefulWidget {
  const AgendaWidget({Key? key}) : super(key: key);

  @override
  _AgendaWidgetState createState() => _AgendaWidgetState();
}

class _AgendaWidgetState extends State<AgendaWidget> {
  late Future<Map<String, List<Map<String, dynamic>>>> _eventos;
  late Future<Map<int, dynamic>> _dependientes;

  @override
  void initState() {
    super.initState();
    _recargarDatos();
  }

  void _recargarDatos() {
    _eventos = _cargarEventos();
    _dependientes = _cargarDependientes();
  }

  Future<Map<String, List<Map<String, dynamic>>>> _cargarEventos() async {
    final db = DatabaseHelper();
    final prefs = await getSavedPreferences();
    return await db.obtenerActividadesPorUsuario(prefs['id_Usuario'] ?? 0);
  }

  Future<Map<int, dynamic>> _cargarDependientes() async {
    final db = DatabaseHelper();
    final prefs = await getSavedPreferences();
    return await db
        .obtenerDependientesYSubdependientes(prefs['id_Usuario'] ?? 0);
  }

  void _crearActividad() async {
    final TextEditingController fechaController = TextEditingController();
    final TextEditingController horaController = TextEditingController();
    final TextEditingController descripcionController = TextEditingController();
    final dependientes = await _dependientes;
    int? figuraSeleccionada;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Actividad'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Nombre de la Figura'),
                items: dependientes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value['nombre']),
                  );
                }).toList(),
                onChanged: (value) {
                  figuraSeleccionada = value;
                },
              ),
              TextField(
                controller: fechaController,
                decoration:
                    const InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
              ),
              TextField(
                controller: horaController,
                decoration: const InputDecoration(labelText: 'Hora (HH:MM)'),
              ),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (figuraSeleccionada == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Seleccione un nombre válido.')),
                );
                return;
              }

              final prefs = await getSavedPreferences();
              final nuevaActividad = {
                'id_Usuario': prefs['id_Usuario'] ?? 0,
                'id_Figura': figuraSeleccionada,
                'fecha': fechaController.text.trim(),
                'hora': horaController.text.trim(),
                'descripcion': descripcionController.text.trim(),
                'estado': 'activo',
              };

              final db = DatabaseHelper();
              await db.insertarActividad(nuevaActividad);

              setState(() {
                _recargarDatos();
              });

              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _eliminarActividad(Map<String, dynamic> actividad) async {
    final db = DatabaseHelper();
    await db.eliminarActividad(actividad['id_ActividadAcomp']);

    setState(() {
      _recargarDatos();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Actividad eliminada correctamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Actividades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _crearActividad,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _eventos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final eventos = snapshot.data ?? {};
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: DateTime.now(),
                eventLoader: (day) {
                  final fecha =
                      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                  return eventos[fecha] ?? [];
                },
                onDaySelected: (selectedDay, focusedDay) async {
                  final fecha =
                      '${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}';
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Actividades para $fecha'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (var actividad in eventos[fecha] ?? [])
                              ListTile(
                                title: Text(actividad['descripcion'] ?? 'Sin descripción'),
                                subtitle: Text('${actividad['hora']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _eliminarActividad(actividad);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
