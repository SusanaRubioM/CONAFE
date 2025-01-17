import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:fepi_local/widgets/calendario.dart';
import 'package:fepi_local/widgets/cards_actividadesP.dart';
import 'package:fepi_local/widgets/reportes.dart';
import 'package:fepi_local/widgets/tabla_matriz_act.dart';
import 'package:flutter/material.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class ScreenPantallaCp003 extends StatelessWidget {
  static const String routeName = '/screen_pantalla_cp003';

  ScreenPantallaCp003({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getSavedPreferences(), // Llama a tu función para obtener las preferencias
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error al cargar preferencias'),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            body: Center(
              child: Text('No se encontraron preferencias guardadas'),
            ),
          );
        } else {
          final prefs = snapshot.data!;

          return DefaultTabController(
            length: 2, // Número de pestañas
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.color1,
                  ),
                  onPressed: () {
                    context.pop();
                  },
                ),
                title: Text('GESTION COLEGIADOS ECAR'),
                titleTextStyle:
                    AppTextStyles.primaryRegular(color: AppColors.color1),
                backgroundColor: AppColors.color3,
                centerTitle: true,
                bottom: TabBar(
                  labelColor: AppColors.color1,
                  unselectedLabelColor: AppColors.color2,
                  labelStyle: AppTextStyles.secondRegular(fontSize: 15),
                  tabs: [
                    Tab(text: 'Matriz de Actividades'),
                    Tab(text: 'Actividades'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  // Primer contenido de la pestaña
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(children: [Expanded(child: TablaMatrizAct()),Expanded(child: ActividadesScreen(idUsuario:  prefs['id_Usuario'] ?? 0))]),
                     // Tu widget de matriz de actividades
                  ),
                  // Segundo contenido de la pestaña
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      // Llamas a la función que obtendrá los datos desde la base de datos
                      future: DatabaseHelper().obtenerActividadesCAPPorUsuario(
                        prefs['id_Usuario'] ?? 0, // Pasa el idUsuario adecuado
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error al cargar datos'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child: Text('No hay actividades disponibles'));
                        } else {
                          return ActividadCardWidget(
                            actividades: snapshot.data!, // Usas los datos obtenidos
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
