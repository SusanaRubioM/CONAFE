import 'package:fepi_local/constansts/app_buttons.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';

class CapacitationInitialPageECAR extends StatefulWidget {
  static const String routeName = '/screen_pantalla_cp002';
  const CapacitationInitialPageECAR({super.key});

  @override
  _CapacitationInitialPageECARState createState() => _CapacitationInitialPageECARState();
}

class _CapacitationInitialPageECARState extends State<CapacitationInitialPageECAR> {
  List<Map<String, dynamic>> ecs = [];
  List<Map<String, dynamic>> activities = [];
  int? selectedEcId;
  late int idEca;

  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await getSavedPreferences();
    idEca = prefs['id_Usuario'] ?? 0;

    // Cargar los ECs relacionados al ECA
    ecs = await DatabaseHelper().obtenerEcsPorEca(idEca);
    setState(() {});
  }

  Future<void> _loadActivitiesForEC(int ecId) async {
    final actividades = await DatabaseHelper().obtenerActividadesAsignado(ecId);
    setState(() {
      activities = actividades;
      selectedEcId = ecId;
    });
  }

  Future<void> _deleteActivity(int idActividad) async {
    await DatabaseHelper().eliminarActividadI(idActividad);
    if (selectedEcId != null) {
      await _loadActivitiesForEC(selectedEcId!);
    }
  }

  void _addActivity(int ecId) {
    _activityController.clear();
    _dateController.clear();
    _hoursController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Actividad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _activityController,
              decoration: const InputDecoration(labelText: 'Actividad'),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Fecha (AAAA-MM-DD)'),
            ),
            TextField(
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Horas'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await DatabaseHelper().insertarActividadCapI(
                ecId: ecId,
                actividad: _activityController.text,
                horas: int.tryParse(_hoursController.text) ?? 0,
                fechaInicio: _dateController.text,
                estatus: 'Pendiente',
                idResponsable: idEca,
              );
              Navigator.of(context).pop();
              _loadActivitiesForEC(ecId);
            },
            child: const Text('Agregar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        title:  Center(child: Text('Capacitación Inicial')),
        backgroundColor: AppColors.color3,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Columna de ECs
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: ecs.length,
                    itemBuilder: (context, index) {
                      final ec = ecs[index];
                      return ListTile(
                        title: Text(
                          ec['nombreCompleto'],
                          style: AppTextStyles.secondMedium(color: AppColors.color3),
                        ),
                        onTap: () => _loadActivitiesForEC(ec['ec_id']),
                        selected: selectedEcId == ec['ec_id'],
                      );
                    },
                  ),
                ),

                // Columna de actividades
                Expanded(
                  flex: 2,
                  child: selectedEcId != null
                      ? ListView.builder(
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            final actividad = activities[index];
                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(actividad['actividad'], style: AppTextStyles.secondBold(color: AppColors.color3),),
                                subtitle: Text(
                                  'Fecha: ${actividad['ifecha_inicio']} | Horas: ${actividad['horas']}| status: ${actividad['estatus']}',
                                  style: AppTextStyles.secondMedium(color: AppColors.color2),
                                ),
                                trailing: actividad['estatus'] != 'Completado'
                                    ? IconButton(
                                        icon: const Icon(Icons.delete, color: AppColors.color3),
                                        onPressed: () => _deleteActivity(actividad['id_ActCap']),
                                      )
                                    : null,
                              ),
                            );
                          },
                        )
                      :  Center(
                          child: Text('Selecciona un EC para ver sus actividades', style: AppTextStyles.secondMedium(),),
                        ),
                ),
              ],
            ),
          ),
          if (selectedEcId != null)
            ElevatedButton(
              style: AppButtons.btnFORM(),
              onPressed: () => _addActivity(selectedEcId!),
              child: const Text('Asignar Nueva Actividad'),
            ),
            SizedBox(height: 50,)
        ],
      ),
    );
  }
}
