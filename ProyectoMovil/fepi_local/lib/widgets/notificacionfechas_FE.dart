import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para manejar y formatear fechas

class ActividadesTable extends StatefulWidget {
  @override
  _ActividadesTableState createState() => _ActividadesTableState();
}

class _ActividadesTableState extends State<ActividadesTable> {
  // Mapa de actividades vacío, se llenará con la función de carga
  Map<String, Map<String, String>> actividades = {};

  // Llamar la función que obtiene las actividades por nombreEC (por ejemplo, 'nombreEC')
  @override
  void initState() {
    super.initState();
    _cargarActividades();
  }

  // Función para cargar las actividades desde la base de datos
  Future<void> _cargarActividades() async {
    final db= await DatabaseHelper();
    final prefs = await getSavedPreferences();
    Map<String, Map<String, String>> actividadesCargadas = await db.obtenerActividadesPorNombreEC(prefs['id_Usuario'] ?? 0); // Cambiar el valor según lo que necesites
    setState(() {
      actividades = actividadesCargadas;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Convertir el mapa en una lista de mapas para poder ordenarlo por fecha
    List<MapEntry<String, Map<String, String>>> listaActividades = actividades.entries.toList();

    // Ordenar la lista de actividades por la fecha más próxima
    listaActividades.sort((a, b) {
      DateTime fechaA = DateFormat('yyyy-MM-dd').parse(a.value['Fecha']!);
      DateTime fechaB = DateFormat('yyyy-MM-dd').parse(b.value['Fecha']!);
      return fechaA.compareTo(fechaB);
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: listaActividades.where((actividad) => actividad.value['Estado'] == 'activo').map((actividad) {
            DateTime fechaActividad = DateFormat('yyyy-MM-dd').parse(actividad.value['Fecha']!);
            bool fechaPasada = fechaActividad.isBefore(DateTime.now());
            return Card(
              color: fechaPasada ? AppColors.color4 : AppColors.color1, // Cambiar color si la fecha ya pasó
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      actividad.key,
                      style: AppTextStyles.secondBold(color: AppColors.color2),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Fecha: ${actividad.value['Fecha']!}',
                      style: AppTextStyles.secondRegular(fontSize: 15),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      actividad.value['Descripcion']!,
                      style: AppTextStyles.secondRegular(color: AppColors.color2),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}



