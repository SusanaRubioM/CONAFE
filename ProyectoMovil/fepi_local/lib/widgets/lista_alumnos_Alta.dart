import 'package:flutter/material.dart';

class DynamicCardsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data; // Datos enviados desde otra pantalla

  const DynamicCardsWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final curp = item['curp'] ?? 'Sin CURP';
        final status = _getStatus(item['state']); // Determinar el estado

        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 5,
          child: ListTile(
            leading: Icon(
              _getIcon(status),
              color: _getColor(status),
            ),
            title: Text('CURP: $curp'),
            subtitle: Text(status),
            onTap: () {
              _handleTap(context, item, status);
            },
          ),
        );
      },
    );
  }

  // Método para determinar el estado
  String _getStatus(String? state) {
    switch (state) {
      case 'aprobado':
        return 'Aprobado';
      case 'pendiente':
        return 'En revisión';
      case 'rechazado':
        return 'No aprobado';
      default:
        return 'Estado desconocido';
    }
  }

  // Método para obtener el ícono basado en el estado
  IconData _getIcon(String status) {
    switch (status) {
      case 'Aprobado':
        return Icons.check_circle;
      case 'En revisión':
        return Icons.hourglass_top;
      case 'No aprobado':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  // Método para obtener el color basado en el estado
  Color _getColor(String status) {
    switch (status) {
      case 'Aprobado':
        return Colors.green;
      case 'En revisión':
        return Colors.orange;
      case 'No aprobado':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Manejar la acción al dar clic
  void _handleTap(BuildContext context, Map<String, dynamic> item, String status) {
    if (status == 'No aprobado') {
      final reason = item['nota'] ?? 'No se proporcionó una razón específica.'; // Razón del rechazo desde 'nota'
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Motivo de Rechazo'),
          content: Text(reason),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } else if (status == 'Aprobado') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Información'),
          content: Text('CURP: ${item['curp']}\nNivel Educativo: ${item['nivelEducativo'] ?? "N/A"}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }
}