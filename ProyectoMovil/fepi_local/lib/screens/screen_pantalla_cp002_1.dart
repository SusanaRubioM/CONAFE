import 'package:fepi_local/constansts/app_buttons.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:flutter/material.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/database/database_helper.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:go_router/go_router.dart';

class CapacitationInitialPageEC extends StatefulWidget {
  static const String routeName = '/screen_pantalla_cp0021';
  const CapacitationInitialPageEC({super.key});

  @override
  _CapacitationInitialPageECState createState() =>
      _CapacitationInitialPageECState();
}

class _CapacitationInitialPageECState
    extends State<CapacitationInitialPageEC> {
  List<Map<String, dynamic>> activities = [];
  late int ecId; // ID del usuario EC
  int coveredHours = 0;
  final int totalHours = 240;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await getSavedPreferences();
    ecId = prefs['id_Usuario'] ?? 0;

    await _loadActivities();
    await _loadCoveredHours();
  }

  Future<void> _loadActivities() async {
    final activitiesResult = await DatabaseHelper().obtenerActividadesAsignado(ecId);
    setState(() {
      activities = activitiesResult;
    });
  }

  Future<void> _loadCoveredHours() async {
    final hours = await DatabaseHelper().obtenerHorasCubiertas(ecId);
    setState(() {
      coveredHours = hours;
    });
  }

  void _finalizeActivity(int activityId) async {
    final now = DateTime.now().toIso8601String().split('T')[0];

    await DatabaseHelper().actualizarActividad(
      ecId,
      activityId,
      {'estatus': 'Completado', 'fecha_fin': now},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Actividad finalizada correctamente.')),
    );

    await _loadActivities();
    await _loadCoveredHours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.color1),
          onPressed: () {
            context.go('/login');
          },
        ),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        title:  Center(child: Text('Capacitación Inicial - EC')),
        backgroundColor: AppColors.color3,
      ),
      body: Column(
        children: [
          // Barra de progreso de horas cubiertas
          Card(
            color: AppColors.color2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Progreso de Capacitación',
                      style: AppTextStyles.secondBold(color: AppColors.color1),
                    ),
                  ),
                  const SizedBox(height: 40),
                  LinearProgressIndicator(
                    value: coveredHours / totalHours,
                    backgroundColor: Colors.grey[300],
                    color: AppColors.color3,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '$coveredHours / $totalHours horas cubiertas',
                      style: AppTextStyles.secondMedium(color: AppColors.color1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de actividades asignadas
          Expanded(
            child: ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      activity['actividad'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Fecha: ${activity['ifecha_inicio']} | Horas: ${activity['horas']}',
                    ),
                    trailing: activity['estatus'] != 'Completado'
                        ? ElevatedButton(
                          
                            onPressed: () => _finalizeActivity(activity['id_ActCap']),
                            style: AppButtons.btnFORM(),
                            child:  Text('Finalizar'),
                          )
                        :  Text(
                            'Completado',
                            style: AppTextStyles.secondMedium(color: AppColors.color3),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


