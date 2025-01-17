import 'package:flutter/material.dart';

class CapacitationInitialPageECAR extends StatefulWidget {
  const CapacitationInitialPageECAR({super.key});

  @override
  _CapacitationInitialPageECARState createState() =>
      _CapacitationInitialPageECARState();
}

class _CapacitationInitialPageECARState
    extends State<CapacitationInitialPageECAR> {
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
    {
      'CvRegion': '002',
      'NombreECAR': 'ECAR B',
      'CvMicrorregion': '1002',
      'NombreECA': 'ECA B',
      'CvComunidad': '2002',
      'IDEC': 'ID002',
      'NombreEC': 'María López',
      'CicloAsignado': '2024-2025',
      'Contexto': 'Urbano',
      'TipoServicio': 'Educación Secundaria',
    },
  ];

  // Datos de actividades por EC
  Map<String, List<Map<String, dynamic>>> activitiesByEC = {
    'ID001': [
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
    ],
    'ID002': [
      {
        'Actividad': 'Evaluación inicial',
        'Fecha': '2024-02-03',
        'Horas': 5,
      },
      {
        'Actividad': 'Capacitación avanzada',
        'Fecha': '2024-02-10',
        'Horas': 7,
      },
    ],
  };

  // EC seleccionado
  String? selectedEC;

  // Controladores para los nuevos datos
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  // Función para agregar una nueva fila a la tabla de actividades
  void _addActivity() {
    if (selectedEC == null) return;

    _activityController.clear();
    _dateController.clear();
    _hoursController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Actividad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _activityController,
              decoration: const InputDecoration(labelText: 'Actividad'),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Fecha'),
            ),
            TextField(
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Horas'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                activitiesByEC[selectedEC]!.add({
                  'Actividad': _activityController.text,
                  'Fecha': _dateController.text,
                  'Horas': int.tryParse(_hoursController.text) ?? 0,
                });
              });
              Navigator.of(context).pop();
            },
            child: const Text('Agregar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  // Cálculo del total de horas para un EC específico
  int get totalHoras {
    if (selectedEC == null || activitiesByEC[selectedEC] == null) {
      return 0;
    }
    return activitiesByEC[selectedEC]!.fold(
      0,
      (sum, item) => sum + (item['Horas'] as int),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                columns: const [
                  DataColumn(label: Text('CV Región')),
                  DataColumn(label: Text('Nombre del ECAR')),
                  DataColumn(label: Text('CV Microrregión')),
                  DataColumn(label: Text('Nombre del ECA')),
                  DataColumn(label: Text('CV Comunidad')),
                  DataColumn(label: Text('ID EC')),
                  DataColumn(label: Text('Nombre del EC')),
                  DataColumn(label: Text('Ciclo Asignado')),
                  DataColumn(label: Text('Contexto')),
                  DataColumn(label: Text('Tipo de Servicio')),
                ],
                rows: data.map((row) {
                  return DataRow(
                    cells: [
                      DataCell(Text(row['CvRegion'] ?? '')),
                      DataCell(Text(row['NombreECAR'] ?? '')),
                      DataCell(Text(row['CvMicrorregion'] ?? '')),
                      DataCell(Text(row['NombreECA'] ?? '')),
                      DataCell(Text(row['CvComunidad'] ?? '')),
                      DataCell(
                        Text(row['IDEC'] ?? ''),
                        onTap: () {
                          setState(() {
                            selectedEC = row['IDEC'];
                          });
                        },
                      ),
                      DataCell(Text(row['NombreEC'] ?? '')),
                      DataCell(Text(row['CicloAsignado'] ?? '')),
                      DataCell(Text(row['Contexto'] ?? '')),
                      DataCell(Text(row['TipoServicio'] ?? '')),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Tabla de actividades específica para el EC seleccionado
            if (selectedEC != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actividades de ${data.firstWhere((row) => row['IDEC'] == selectedEC)['NombreEC']}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('Actividad')),
                      DataColumn(label: Text('Fecha')),
                      DataColumn(label: Text('Horas')),
                    ],
                    rows: activitiesByEC[selectedEC]!.map((row) {
                      return DataRow(cells: [
                        DataCell(Text(row['Actividad'])),
                        DataCell(Text(row['Fecha'])),
                        DataCell(Text('${row['Horas']}')),
                      ]);
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total de Horas: $totalHoras',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addActivity,
                    child: const Text('Agregar Actividad'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: CapacitationInitialPageECAR(),
  ));
}
