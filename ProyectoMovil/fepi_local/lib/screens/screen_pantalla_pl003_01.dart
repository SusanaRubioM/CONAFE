import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:fepi_local/widgets/card_info.dart';
import 'package:fepi_local/widgets/search_filter_widget.dart';
import 'package:go_router/go_router.dart';
// Importar la clase de la base de datos

class ScreenPantallaPl003_01 extends StatefulWidget {
  static const String routeName = '/screen_pantalla_pl003_01';

  const ScreenPantallaPl003_01({super.key});

  @override
  _ScreenPantallaPl003_01State createState() => _ScreenPantallaPl003_01State();
}

class _ScreenPantallaPl003_01State extends State<ScreenPantallaPl003_01> {
  List<Map<String, String>> _data = [];
  bool _isLoading = true;
  Map<String, String> result = {};  // Cambiar 'result' para que sea un mapa

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.database;
    final prefs = await getSavedPreferences();
    var resultFromDb = await dbHelper.getMicrorregionPorUsuario(prefs['id_Usuario'] ?? 0);
    print('>>>>>$resultFromDb');
    var personal = await dbHelper.getDATAdependientesECA(prefs['id_Usuario'] ?? 0);
    
    setState(() {
      // Almacenar el resultado como un mapa
      result = resultFromDb!;  // Asignar directamente el mapa
      _data = personal.map((item) {
        return item.map((key, value) => MapEntry(key, value.toString()));
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si result es un mapa, puedes extraer un valor específico de él
    String extractedValue = result.isNotEmpty ? result['nombreMicrorregion'] ?? 'Valor no encontrado' : 'Cargando...';
    print('DATA:$_data');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: AppColors.color1,),onPressed:(){context.pop();}),
        title: const Text('Microregión asignada ECA'),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Pasar el valor extraído del mapa al widget CardInfo
          SizedBox(child: CardInfo(text: extractedValue)),
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SearchFilterWidget(
                    data: _data,
                  ),
          ),
        ],
      ),
    );
  }
}
