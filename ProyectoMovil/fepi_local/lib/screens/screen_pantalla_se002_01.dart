import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:fepi_local/widgets/angenda_widget.dart';
import 'package:fepi_local/widgets/reportes_widget_01.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SreenPantallaSe002_01 extends StatefulWidget {
  static const String routeName = '/screen_pantalla_se002_01';

  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<SreenPantallaSe002_01> {
  @override
  void initState() {
    super.initState();
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: AppColors.color1,),onPressed:(){context.pop();}),
        title: const Text('PANEL DE PLANIFICACION PARA ECAR'),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.5, // Ajuste para medio espacio
              child: AgendaWidget(),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5, // Ajuste para medio espacio
              child: ActividadesPage(),
            ),
          ],
        ),
      ),
    );
  }
}
