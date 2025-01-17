import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:flutter/material.dart';

class DynamicTableWidget2 extends StatefulWidget {
  final List<Map<String, String>> data;

  const DynamicTableWidget2({Key? key, required this.data}) : super(key: key);

  @override
  _DynamicTableWidget2State createState() => _DynamicTableWidget2State();
}

class _DynamicTableWidget2State extends State<DynamicTableWidget2> {
  final List<bool> _isExpanded = []; // Lista para manejar el estado de cada tarjeta

  @override
  void initState() {
    super.initState();
    // Inicializa el estado de expansión de cada tarjeta
    _isExpanded.addAll(List<bool>.filled(widget.data.length, false));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.data.map((item) {
        final index = widget.data.indexOf(item);
        final estatus = item['Estatus'] ?? 'Activo';
        final isInactive = estatus == 'Inactivo';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded[index] = !_isExpanded[index];
              });
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: isInactive ? Colors.grey[300] : AppColors.color1,
              elevation: 8,
              child: Column(
                children: [
                  // Información principal
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: AppColors.color2,
                              child: Icon(Icons.person, color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              item['Nombre'] ?? '',
                              style: AppTextStyles.secondBold(color: AppColors.color2, fontSize: 18),
                            ),
                          ],
                        ),
                        Icon(
                          isInactive ? Icons.no_accounts : Icons.check_circle,
                          color: isInactive ? Colors.red : Colors.green,
                        ),
                      ],
                    ),
                  ),

                  // TabBar y TabBarView solo si está expandido
                  if (_isExpanded[index])
                    DefaultTabController(
                      length: 3, // Tres pestañas
                      child: Column(
                        children: [
                          Container(
                            color: AppColors.color3,
                            
                          ),
                           Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildDatosTab(item),
                            )),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Construcción de la pestaña "DATOS"
  Widget _buildDatosTab(Map<String, String> item) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Rol', item['Rol'] ?? '', Icons.person),
          _buildInfoCard('Ubicación', item['Ubicacion'] ?? '', Icons.map),
          _buildInfoCard('Situación Educativa', item['Situacion'] ?? '', Icons.school),
        ],
      ),
    );
  }

  // Método para crear tarjetas de información
  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        clipBehavior: Clip.none, // Permite que las etiquetas sobresalgan
        children: [
          // Tarjeta negra
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.color2,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16), // Más espacio arriba
            child: Text(
              content,
              style: AppTextStyles.secondMedium(color: AppColors.color1, fontSize: 16),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),

          // Etiqueta roja
          Positioned(
            top: -14, // Solapa ligeramente la tarjeta negra
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.color3,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 16), // Icono a la izquierda
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: AppTextStyles.secondBold(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
