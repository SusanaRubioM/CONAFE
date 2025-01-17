import 'package:flutter/material.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class InicioECA extends StatelessWidget {
  static const String routeName = '/screen_Inicio_ECA';
  const InicioECA({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calcular el tamaño del botón ajustado a una cuadrícula
    final buttonWidth = (screenWidth - 48) / 2; // Dos botones por fila con padding
    final buttonHeight = (screenHeight - 144) / 5; // Cinco filas de botones con espacio para AppBar y paddings

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.color1),
          onPressed: () {
            context.go('/login');
          },
        ),
        title: const Text('Inicio ECA'),
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
              label: 'Microrregion',
              icon: Icons.map,
              route: '/screen_pantalla_pl003_01',
            ),
            _buildButton(
              context,
              label: 'Plan de promocion',
              icon: Icons.calendar_month,
              route: '/screen_pantalla_pc003_01',
            ),
            _buildButton(
              context,
              label: 'Capacitacion de formacion',
              icon: Icons.book,
              route: '/screen_pantalla_cp002',
            ),
            _buildButton(
              context,
              label: 'Gestion de Colegiados',
              icon: Icons.edit_calendar_rounded,
              route: '/screen_pantalla_cp004',
            ),
            _buildButton(
              context,
              label: 'Actividades Programadas ECAR',
              icon: Icons.list_alt,
              route: '/screen_pantalla_se002_02',
            ),
            _buildButton(
              context,
              label: 'Fechas acompañamiento',
              icon: Icons.edit_calendar_rounded,
              route: '/screen_pantalla_se003_01',
            ),
            _buildButton(
              context,
              label: 'Reportes EC',
              icon: Icons.document_scanner,
              route: '/screen_pantalla_se006_02',
            ),
            _buildButton(
              context,
              label: 'Asistencias EC',
              icon: Icons.list,
              route: '/screen_pantalla_se001_02',
            ),
            _buildButton(
              context,
              label: 'Fechas de pago',
              icon: Icons.money,
              route: '/screen_pantalla_be002',
            ),
            _buildButton(
              context,
              label: 'Capacitacion Inicial',
              icon: Icons.school,
              route: '/screen_pantalla_cp002',
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
