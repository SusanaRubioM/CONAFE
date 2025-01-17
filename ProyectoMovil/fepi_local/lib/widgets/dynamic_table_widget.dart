import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:flutter/material.dart';

class DynamicTableWidget extends StatefulWidget {
  final List<Map<String, String>> data;

  const DynamicTableWidget({Key? key, required this.data}) : super(key: key);

  @override
  _DynamicTableWidgetState createState() => _DynamicTableWidgetState();
}

class _DynamicTableWidgetState extends State<DynamicTableWidget> {
  final List<bool> _isExpanded = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.data.map((item) {
        final index = widget.data.indexOf(item);
        final estatus = item['Estatus'] ?? 'Activo';
        final isInactive = estatus == 'Inactivo';

        return GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded[index] = !_isExpanded[index];
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: isInactive ? Colors.grey[300] : AppColors.color1,
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información principal
                    Row(
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
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                        Icon(
                          isInactive ? Icons.no_accounts : Icons.check_circle,
                          color: isInactive ? Colors.red : Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
            
                    // Información expandible
                    if (_isExpanded[index])
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 10),
                          _buildInfoCard('Rol', item['Rol'] ?? '', Icons.person),
                          _buildInfoCard('Ubicación', item['Ubicacion'] ?? '', Icons.map),
                          _buildInfoCard('Situación Educativa', item['Situacion'] ?? '', Icons.school),
                          _buildInfoCard('Tipo de Servicio', item['TipoServicio'] ?? '', Icons.work),
                          _buildInfoCard('Nivel', item['Nivel'] ?? '', Icons.book),
                          _buildInfoCard('Contexto', item['Contexto'] ?? '', Icons.agriculture_sharp),
                          const SizedBox(height: 15),
                          const Divider(color: Colors.grey),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
