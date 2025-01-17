import 'package:flutter/material.dart';
class CapacitationInitialPage extends StatelessWidget {
  const CapacitationInitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de la primera tabla
    List<Map<String, String>> data = [
      {
        'CvRegion': '001',
        'NombreECAR': 'ECAR A',
        'CvMicrorregion': '1001',
        'NombreECA': 'ECA A',
        'CvComunidad': '2001',
        'IDEC': 'ID001',
        'NombreEC': 'Juan Pérez',
        'CicloAsignado': '2024-2025',
        'Contexto': 'Rural',
        'TipoServicio': 'Educación Básica',
      },
      // Agrega más registros según sea necesario
    ];

    // Datos de la segunda tabla
    List<Map<String, dynamic>> activityData = [
      {
        'Actividad': 'Taller de habilidades',
        'Fecha': '2024-02-01',
        'Horas': 4,
      },
      {
        'Actividad': 'Capacitación práctica',
        'Fecha': '2024-02-05',
        'Horas': 6,
      },
      {
        'Actividad': 'Evaluación final',
        'Fecha': '2024-02-10',
        'Horas': 3,
      },
    ];

    // Cálculo del total de horas
    int totalHoras = activityData.fold(0, (sum, item) => sum + item['Horas'] as int);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capacitación Inicial'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primera tabla
            const Text(
              'Tabla de Capacitación Inicial',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('CV Región')),
                  const DataColumn(label: Text('Nombre del ECAR')),
                  const DataColumn(label: Text('CV Microrregión')),
                  const DataColumn(label: Text('Nombre del ECA')),
                  const DataColumn(label: Text('CV Comunidad')),
                  const DataColumn(label: Text('ID EC')),
                  const DataColumn(label: Text('Nombre del EC')),
                  const DataColumn(label: Text('Ciclo Asignado')),
                  const DataColumn(label: Text('Contexto')),
                  const DataColumn(label: Text('Tipo de Servicio')),
      
                ],
                rows: data.map((row) {
                  return DataRow(cells: [
                    DataCell(Text(row['CvRegion'] ?? '')),
                    DataCell(Text(row['NombreECAR'] ?? '')),
                    DataCell(Text(row['CvMicrorregion'] ?? '')),
                    DataCell(Text(row['NombreECA'] ?? '')),
                    DataCell(Text(row['CvComunidad'] ?? '')),
                    DataCell(Text(row['IDEC'] ?? '')),
                    DataCell(Text(row['NombreEC'] ?? '')),
                    DataCell(Text(row['CicloAsignado'] ?? '')),
                    DataCell(Text(row['Contexto'] ?? '')),
                    DataCell(Text(row['TipoServicio'] ?? '')),
                  
                  ]);
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Segunda tabla
            const Text(
              'Resumen de Actividades',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DataTable(
            columns: const [
              DataColumn(label: Text('Actividad')),
              DataColumn(label: Text('Fecha')),
              DataColumn(label: Text('Horas')),
            ],
            rows: [
              ...activityData.map((row) {
                return DataRow(cells: [
                  DataCell(Text(row['Actividad'] ?? '')),
                  DataCell(Text(row['Fecha'] ?? '')),
                  DataCell(Text('${row['Horas']}')),
                ]);
              }).toList(),
              // Fila para mostrar el total de horas
              DataRow(cells: [
                const DataCell(Text('Total:', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataCell(Text('')),
                DataCell(Text('$totalHoras', style: const TextStyle(fontWeight: FontWeight.bold))),
              ]),
            ],
          )

          ],
        ),
      ),
    );
  }
}
