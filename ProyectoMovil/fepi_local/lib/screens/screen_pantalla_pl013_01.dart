import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:fepi_local/widgets/form_registro_alumno.dart';
import 'package:fepi_local/widgets/lista_alumnos_Alta.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class ScreenPantallaPl013_01 extends StatefulWidget {
  static const String routeName = '/screen_pantalla_pl013_01';

  @override
  _ScreenPantallaPl013_01State createState() => _ScreenPantallaPl013_01State();
}

class _ScreenPantallaPl013_01State extends State<ScreenPantallaPl013_01>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    // Escucha los cambios de pestaña
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _loadData(); // Recarga los datos al cambiar a la pestaña "Alumnos"
      }
    });

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Método para cargar datos de la base de datos
  Future<void> _loadData() async {
    final prefs = await getSavedPreferences();
    final db = DatabaseHelper();
    final alumnos = await db.cargarAlumnosPorMaestro(prefs['id_Usuario'] ?? 0);
    setState(() {
      _data = alumnos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: AppColors.color1,),onPressed:(){context.pop();}),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        centerTitle: true,
        title: Column(
          children: [
            SizedBox(height: 30,),
            const Text("Registro de Alumnos"),
          ],
        ),
        bottom: TabBar(
          labelStyle: AppTextStyles.secondRegular(color: AppColors.color1, fontSize: 14),
                              unselectedLabelStyle: AppTextStyles.secondRegular(color: AppColors.color2, fontSize: 14),
                              indicatorColor: AppColors.color1,
          controller: _tabController, // Asignamos el TabController al TabBar
          tabs: const [
            Tab(text: "Alumnos",),
            Tab(text: "Registro"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController, // Asignamos el TabController al TabBarView
        children: [
          // Pestaña "Alumnos"
          Center(
            child: _data.isEmpty
                ? CircularProgressIndicator() // Muestra un indicador de carga si no hay datos
                : DynamicCardsWidget(data: _data),
          ),
          // Pestaña "Registro"
          FormRegistroAlumno(),
        ],
      ),
    );
  }
}
