import 'dart:io';

import 'package:fepi_local/database/database_gestor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class ActividadesScreen extends StatefulWidget {
  final int idUsuario;

  const ActividadesScreen({Key? key, required this.idUsuario}) : super(key: key);

  @override
  _ActividadesScreenState createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> {
  List<Map<String, dynamic>> _actividades = [];

  @override
  void initState() {
    super.initState();
    _loadActividades();
  }

  // Llamamos a la función para cargar las actividades desde la base de datos
  Future<void> _loadActividades() async {
    final db= DatabaseHelper();
    final actividades = await db.obtenerColegiadosPorUsuario(widget.idUsuario);
    print('>>>>>$actividades');
    setState(() {
      _actividades = actividades;
    });
  }

  // Función para abrir el reporte PDF
  Future<void> _verReportePdf(Uint8List pdfBytes) async {
    // Guardamos los bytes del PDF en un archivo temporal
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/reporte.pdf');
    await tempFile.writeAsBytes(pdfBytes);

    // Abrimos el PDF con flutter_pdfview
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(pdfPath: tempFile.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades Programadas por otra figura educativa'),
      ),
      body: _actividades.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _actividades.length,
              itemBuilder: (context, index) {
                final actividad = _actividades[index];
                final estado = actividad['Estado'];

                return Card(
                  child: ListTile(
                    title: Text('Tema: ${actividad['TEMA']}'),
                    subtitle: Text('Fecha: ${actividad['FechaProgramada']} |  Microrregion: ${actividad['Microrregion']}'),

                    trailing: estado == 'inactivo'
                        ? Icon(Icons.visibility) // Indicador de que puede visualizar el reporte
                        : null,
                    onTap: () {
                      if (estado == 'inactivo') {
                        // Obtener el reporte de la actividad en formato PDF
                        final pdfBytes = actividad['Reporte'];

                        if (pdfBytes != null) {
                          _verReportePdf(pdfBytes); // Ver el reporte en PDF
                        }
                      }
                    },
                  ),
                );
              },
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
