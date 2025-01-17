import 'package:flutter/material.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class InicioECAR extends StatelessWidget {
  static const String routeName = '/screen_Inicio_ECAR';
  const InicioECAR({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calcular el tamaño del botón ajustado a una cuadrícula de 2x3
    final buttonWidth = (screenWidth - 48) / 2; // Dos botones por fila con padding
    final buttonHeight = (screenHeight - 144) / 3; // Tres filas de botones con espacio para AppBar y paddings

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.color1),
          onPressed: () {
            context.go('/login');
          },
        ),
        title: const Text('Inicio ECAR'),
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
              label: 'Plan de Promoción',
              icon: Icons.calendar_month,
              route: '/screen_pantalla_pc003_01',
            ),
            _buildButton(
              context,
              label: 'Microrregión',
              icon: Icons.map,
              route: '/screen_pantalla_pl004_01',
            ),
            _buildButton(
              context,
              label: 'Gestión de Colegiados',
              icon: Icons.edit_calendar_rounded,
              route: '/screen_pantalla_cp003',
            ),
            _buildButton(
              context,
              label: 'Fechas Acompañamiento',
              icon: Icons.edit_calendar_rounded,
              route: '/screen_pantalla_se002_01',
            ),
            _buildButton(
              context,
              label: 'Visualizar Reportes ECA',
              icon: Icons.document_scanner,
              route: '/screen_pantalla_se002_03',
            ),
            _buildButton(
              context,
              label: 'Fechas de Pago',
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
