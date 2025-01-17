import 'dart:typed_data';

import 'package:fepi_local/database/database_gestor.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ActividadCardWidget extends StatefulWidget {
  final List<Map<String, dynamic>> actividades;

  const ActividadCardWidget({Key? key, required this.actividades})
      : super(key: key);

  @override
  _ActividadCardWidgetState createState() => _ActividadCardWidgetState();
}

class _ActividadCardWidgetState extends State<ActividadCardWidget> {
  // Función para generar el mapa con los datos del reporte
  Map<String, dynamic> _crearReporte(Map<String, dynamic> actividad, Uint8List reporte) {
    return {
      'id_ActCAP': actividad['id_ActCAP'],
      'Reporte': reporte,  // Almacenamos el PDF como Uint8List
      'Estado': 'inactivo',
    };
  }

  // Función para crear un PDF con el reporte
  Future<Uint8List> _crearPdf(Map<String, dynamic> actividad, String reporte) async {
  final pdf = pw.Document();

  // Agregamos márgenes y mejoramos el formato
  final pdfDir = await getApplicationDocumentsDirectory();
  final file = File('${pdfDir.path}/reporte_${actividad['id_ActCAP']}.pdf');

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Padding(
          padding: pw.EdgeInsets.all(20), // Añadimos márgenes
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start, // Alineación a la izquierda
            children: [
              // Título principal con mayor tamaño y negrita
              pw.Text(
                'Reporte de la Actividad',
                style: pw.TextStyle(
                  fontSize: 20, 
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Información de la actividad
              pw.Text(
                'Número de Capacitación: ${actividad['NumCapacitacion']}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
              pw.SizedBox(height: 10),  // Espaciado entre líneas
              pw.Text(
                'Tema: ${actividad['TEMA']}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Fecha Programada: ${actividad['FechaProgramada']}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
              pw.SizedBox(height: 10),
              
              // Reporte en sí, con un espaciado y formato adecuado
              pw.Text(
                'Reporte:',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                reporte,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.normal,
                ),
                textAlign: pw.TextAlign.justify,  // Alineación justificada
              ),
            ],
          ),
        );
      },
    ),
  );

  // Guardamos el archivo PDF
  final pdfBytes = await pdf.save();
  await file.writeAsBytes(pdfBytes);  // Guardamos el archivo
  print('PDF guardado en: ${file.path}');
  return pdfBytes;  // Retornamos el PDF como Uint8List
}


  // Llamamos a la función de editar la actividad (pasamos el mapa con los datos)
  Future<void> _editarActividad(Map<String, dynamic> reporte) async {
    final db = DatabaseHelper();
    await db.editarActividad(reporte);
  }

  void _finalizarActividad(Map<String, dynamic> actividad) {
    TextEditingController reporteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Finalizar Actividad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Por favor, redacta el reporte para finalizar.'),
              const SizedBox(height: 10),
              TextField(
                controller: reporteController,
                decoration: const InputDecoration(
                  labelText: 'Reporte',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Crear el reporte y convertir el PDF a Uint8List
                final reporte = await _crearPdf(actividad, reporteController.text);

                // Llamamos a la función para actualizar la actividad en la base de datos
                final reporteMap = _crearReporte(actividad, reporte);
                await _editarActividad(reporteMap);

                // Mostrar el PDF generado
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Actividad finalizada.')),
                );
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDetallesActividad(Map<String, dynamic> actividad) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalles de la Actividad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Número de Capacitación: ${actividad['NumCapacitacion']}'),
              Text('Tema: ${actividad['TEMA']}'),
              Text('Microregión: ${actividad['Microrregion']}'),
              Text('Centro de trabajo: ${actividad['CCT']}'),
              Text('Fecha Programada: ${actividad['FechaProgramada']}'),
              Text('Estado: ${actividad['Estado']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _finalizarActividad(actividad);
              },
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades Activas'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: widget.actividades
                  .where((actividad) => actividad['Estado'] == 'activo')
                  .map((actividad) {
                return Card(
                  child: ListTile(
                    title: Text('Fecha: ${actividad['FechaProgramada']}'),
                    subtitle: Text('Tema: ${actividad['TEMA']}'),
                    onTap: () => _mostrarDetallesActividad(actividad),
                  ),
                );
              }).toList(),
            ),
          ),
        
          Text('Finalizados'),
        
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: widget.actividades
                  .where((actividad) => actividad['Estado'] == 'inactivo')
                  .map((actividad) {
                return Card(
                  child: ListTile(
                    title: Text('Fecha: ${actividad['FechaProgramada']}'),
                    subtitle: Text('Tema: ${actividad['TEMA']}'),
                    onTap: () async {
                      // Recuperamos el PDF (en formato Uint8List) desde la base de datos
                      final pdfBytes = actividad['Reporte'];

                      if (pdfBytes != null) {
                        final tempDir = await getTemporaryDirectory();
                        final tempFile = File('${tempDir.path}/reporte_${actividad['id_ActCAP']}.pdf');
                        await tempFile.writeAsBytes(pdfBytes);

                        // Abrimos el PDF con flutter_pdfview
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerPage(pdfPath: tempFile.path),
                          ),
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class PdfViewerPage extends StatelessWidget {
  final String pdfPath;

  const PdfViewerPage({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Reporte PDF'),
      ),
      body: PDFView(
        filePath: pdfPath, // Usamos la ruta del archivo PDF aquí
      ),
    );
  }
}
