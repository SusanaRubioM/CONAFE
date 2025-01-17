import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:table_calendar/table_calendar.dart';


class ScreenPantallaSe00102 extends StatefulWidget {
  static const String routeName = '/screen_pantalla_se001_02';
  const ScreenPantallaSe00102({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<ScreenPantallaSe00102> {
  Map<int, dynamic> _attendanceData = {};
  int? _selectedProfessorId;
  List<Map<String, dynamic>> _selectedProfessorAttendance = [];

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    final dbHelper = DatabaseHelper();
    final prefs = await getSavedPreferences();
      int idUsuario = prefs['id_Usuario'] ?? 0;
    final attendanceData = await dbHelper.obtenerAsistenciaPorUsuario(idUsuario); // Cambia el ID de usuario según sea necesario
    setState(() {
      _attendanceData = attendanceData;
      print(_attendanceData);
    });
  }

  void _onProfessorSelected(int professorId) {
    setState(() {
      _selectedProfessorId = professorId;
      _selectedProfessorAttendance = List<Map<String, dynamic>>.from(
        _attendanceData[professorId]['asistencias'],
      );
    });
  }

  void _showAttendanceDetails(BuildContext context, Map<String, dynamic> attendance) {
    final String horaEntrada = attendance['horaEntrada'].toString() ?? 'No registrada'; 
    final String horaSalida = attendance['horaSalida'].toString() ?? 'No registrada';
    String duracion = 'No calculable';

    if (attendance['horaEntrada'] != null && attendance['horaSalida'] != null) {
      final entrada = TimeOfDay(
        hour: int.parse(horaEntrada.split(':')[0]),
        minute: int.parse(horaEntrada.split(':')[1]),
      );
      final salida = TimeOfDay(
        hour: int.parse(horaSalida.split(':')[0]),
        minute: int.parse(horaSalida.split(':')[1]),
      );

      final durationInMinutes = (salida.hour * 60 + salida.minute) - (entrada.hour * 60 + entrada.minute);
      final hours = durationInMinutes ~/ 60;
      final minutes = durationInMinutes % 60;
      duracion = '${hours}h ${minutes}m';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalles de Asistencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hora de Entrada: $horaEntrada'),
              Text('Hora de Salida: $horaSalida'),
              Text('Duración de la Jornada: $duracion'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asistencia de Profesores'),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        centerTitle: true,
      ),
      body: _attendanceData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _attendanceData.length,
                    itemBuilder: (context, index) {
                      final professorId = _attendanceData.keys.elementAt(index);
                      final professorData = _attendanceData[professorId];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(professorData['nombre'], style: AppTextStyles.secondMedium()),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _onProfessorSelected(professorId),
                        ),
                      );
                    },
                  ),
                ),
                if (_selectedProfessorId != null)
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Asistencia de ${_attendanceData[_selectedProfessorId]['nombre']}',
                          style: AppTextStyles.secondMedium(fontSize: 18),
                        ),
                        Expanded(
                          child: TableCalendar(
                            focusedDay: DateTime.now(),
                            firstDay: DateTime(2000),
                            lastDay: DateTime(2100),
                            selectedDayPredicate: (day) {
                              return _selectedProfessorAttendance.any(
                                  (attendance) => DateTime.parse(attendance['fecha']).isAtSameMomentAs(day));
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              final attendance = _selectedProfessorAttendance.firstWhere(
                                (attendance) => DateTime.parse(attendance['fecha']).isAtSameMomentAs(selectedDay),
                              );
                              _showAttendanceDetails(context, attendance);
                            },
                            calendarStyle: const CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
