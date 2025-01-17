import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ActividadesPage extends StatefulWidget {
  @override
  _ActividadesPageState createState() => _ActividadesPageState();
}

class _ActividadesPageState extends State<ActividadesPage> {
  int? idUsuario;
  late Future<Map<String, List<Map<String, dynamic>>>> actividadesFuture;
  final TextEditingController reporteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    actividadesFuture = _obtenerActividades();
  }

  @override
  void dispose() {
    reporteController.dispose();
    super.dispose();
  }

  Future<Uint8List> _generarPDF(String descripcion, String reporte) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Descripción de la Actividad:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text(descripcion, style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.Text("Reporte:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text(reporte, style: pw.TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  Future<void> _showReporteDialog(Map<String, dynamic> actividad) async {
    reporteController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Reporte: ${actividad["Actividad"]}'),
          content: TextField(
            controller: reporteController,
            decoration: const InputDecoration(
              labelText: "Escribe tu reporte aquí",
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reporteController.text.isNotEmpty) {
                  final pdfData = await _generarPDF(
                    actividad["Actividad"]!,
                    reporteController.text,
                  );

                  final db = await DatabaseHelper();
                  await db.cambiarEstadoYRegistrarReporte(
                    int.parse(actividad["id_ActividadAcomp"]!),
                    idUsuario!,
                    pdfData,
                  );

                  setState(() {
                    actividadesFuture = _obtenerActividades();
                    actividad["Estado"] = "terminado";
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text("Enviar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _visualizarPDF(int idReporteAcomp) async {
    final db = await DatabaseHelper();
    final reporte = await db.getReporteByActividadId(idReporteAcomp);

    if (reporte != null && reporte['reporte'] != null) {
      final Uint8List pdfData = reporte['reporte'];

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/reporte_${idReporteAcomp}.pdf';
      final file = File(tempPath);
      await file.writeAsBytes(pdfData);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFView(
            filePath: tempPath,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar el PDF asociado.')),
      );
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _obtenerActividades() async {
    final db = await DatabaseHelper();
    final prefs = await SharedPreferences.getInstance();
    idUsuario = prefs.getInt('id_Usuario') ?? 0;

    if (idUsuario == null || idUsuario == 0) {
      throw Exception("No se encontró el idUsuario en SharedPreferences");
    }

    return await db.obtenerActividadesPorUsuario(idUsuario!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Actividades'),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: actividadesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay actividades disponibles.'));
          }

          var actividades = snapshot.data!.values.expand((e) => e).toList();

          // Ordenar las actividades por fecha (más recientes primero)
          actividades.sort((a, b) {
            final fechaA = DateTime.parse(a["fecha"] ?? "1970-01-01");
            final fechaB = DateTime.parse(b["fecha"] ?? "1970-01-01");
            return fechaB.compareTo(fechaA); // Más recientes primero
          });

          return ListView(
            children: actividades.map((actividad) {
              final estado = actividad["estado"];
              final idReporteAcomp = actividad["id_ActividadAcomp"];

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                color: estado == "terminado" ? Colors.green[100] : null,
                child: ListTile(
                  title: Text(actividad["figuraNombre"] ?? "Sin nombre"),
                  subtitle: Text("Fecha: ${actividad["fecha"]} | Hora: ${actividad["hora"]}"),
                  trailing: estado == "activo"
                      ? ElevatedButton(
                          onPressed: () => _showReporteDialog({
                            "Actividad": actividad["descripcion"]!,
                            "id_ActividadAcomp": actividad["id_ActividadAcomp"].toString(),
                            "Fecha": actividad["fecha"]!,
                          }),
                          child: const Text("Reportar"),
                        )
                      : ElevatedButton(
                          onPressed: () => _visualizarPDF(idReporteAcomp!),
                          child: const Text("Ver PDF"),
                        ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
