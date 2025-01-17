import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:fepi_local/widgets/cards_actividadesP.dart';
import 'package:flutter/material.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';

class ScreenPantallaCp0042 extends StatefulWidget {
  static const String routeName = '/screen_pantalla_cp004_2';
  
  ScreenPantallaCp0042({super.key});

  @override
  _ScreenPantallaCp0042State createState() => _ScreenPantallaCp0042State();
}

class _ScreenPantallaCp0042State extends State<ScreenPantallaCp0042> {
  int idUsuario = 0;

  @override
  void initState() {
    super.initState();
    _getUserPreferences();
  }

  // Método asincrónico para obtener las preferencias del usuario
  Future<void> _getUserPreferences() async {
    final prefs = await getSavedPreferences();
    setState(() {
      idUsuario = prefs['id_Usuario'] ?? 0;  // Asigna el id del usuario
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('COLEGIADOS ASIGNADOS'),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        centerTitle: true,
      ),
      body: idUsuario == 0  // Verifica si se obtuvo el id del usuario
          ? Center(child: CircularProgressIndicator())  // Muestra un cargando mientras se obtiene el id
          : Stack(
              children: [
                ActividadesScreen(idUsuario: idUsuario),
              ],
            ),
    );
  }
}
