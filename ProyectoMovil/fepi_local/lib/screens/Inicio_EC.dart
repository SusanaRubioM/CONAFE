import 'package:flutter/material.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class InicioEC extends StatelessWidget {
  static const String routeName = '/screen_Inicio_EC';
  const InicioEC({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Ajustamos el tamaño de los botones para que se ajusten a la pantalla
    final buttonWidth = (screenWidth - 48) / 2; // Dos botones por fila con padding
    final buttonHeight = (screenHeight - 144) / 4; // Tres filas de botones (más espacio para el AppBar y paddings)

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.color1),
          onPressed: () {
            context.go('/login');
          },
        ),
        title: const Text('Inicio EC'),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(), // Deshabilitar scroll
          crossAxisCount: 2, // Dos columnas
          crossAxisSpacing: 16.0, // Espaciado horizontal
          mainAxisSpacing: 16.0, // Espaciado vertical
          childAspectRatio: buttonWidth / buttonHeight, // Ajuste del tamaño de los botones
          children: [
            _buildButton(
              context,
              label: 'Actividades asignadadas ECA',
              icon: Icons.list_alt,
              route: '/screen_pantalla_se003_02',
            ),
            _buildButton(
              context,
              label: 'Enviar Reporte',
              icon: Icons.list_alt,
              route: '/screen_pantalla_se006_01',
            ),
            _buildButton(
              context,
              label: 'Alumnos',
              icon: Icons.app_registration,
              route: '/screen_pantalla_se00401',
            ),
            _buildButton(
              context,
              label: 'Registrar Alumnos',
              icon: Icons.app_registration,
              route: '/screen_pantalla_pl013_01',
            ),
            _buildButton(
              context,
              label: 'Colegiales',
              icon: Icons.notification_important,
              route: '/screen_pantalla_cp004_2',
            ),
            _buildButton(
              context,
              label: 'Restro de moviliario',
              icon: Icons.table_bar,
              route: '/screen_pantalla_eq00301',
            ),
            _buildButton(
              context,
              label: 'Fechas de pago',
              icon: Icons.money,
              route: '/screen_pantalla_be002',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.color2,
        padding: const EdgeInsets.all(16.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Sin redondeo
        ),
      ),
      onPressed: () {
        context.push(route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.color1, size: 32),
          const SizedBox(height: 8.0),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.secondRegular(color: AppColors.color1),
          ),
        ],
      ),
    );
  }
}
