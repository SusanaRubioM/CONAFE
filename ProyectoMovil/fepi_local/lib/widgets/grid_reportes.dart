import 'dart:io';
import 'dart:typed_data';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Librería para manejo de archivos y rutas
import 'package:sqflite/sqflite.dart';

class CuadriculaDeCards extends StatefulWidget {
  CuadriculaDeCards();

  @override
  _CuadriculaDeCardsState createState() => _CuadriculaDeCardsState();
}

class _CuadriculaDeCardsState extends State<CuadriculaDeCards> {
  Map<String, Map<String, dynamic>> datos = {};
  String filtroFe = 'Todos';
  bool ordenAscendente = true;
  DateTime? fechaInicio;
  DateTime? fechaFin;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final prefs = await getSavedPreferences();
    final db = await DatabaseHelper();
    datos = await db.obtenerReportesPorUsuario(prefs['id_Usuario'] ?? 0);
    setState(() {});
  }

  Future<String> convertirAReporteLocal(Uint8List reporte, String nombre) async {
    // Obtener el directorio temporal
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$nombre.pdf';

    // Crear y escribir el archivo
    final file = File(filePath);
    await file.writeAsBytes(reporte);

    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, Map<String, dynamic>>> listaDatos =
        datos.entries.toList();

    // Filtrar por 'Fe'
    if (filtroFe != 'Todos') {
      listaDatos = listaDatos
          .where((entrada) => entrada.value['Fe'] == filtroFe)
          .toList();
    }

    // Filtrar por rango de fechas
    if (fechaInicio != null && fechaFin != null) {
      listaDatos = listaDatos.where((entrada) {
        DateTime fecha = DateTime.parse(entrada.value['Fecha']!);
        return fecha.isAfter(fechaInicio!) && fecha.isBefore(fechaFin!);
      }).toList();
    }

    // Ordenar por fecha
    listaDatos.sort((a, b) {
      DateTime fechaA = DateTime.parse(a.value['Fecha']!);
      DateTime fechaB = DateTime.parse(b.value['Fecha']!);
      return ordenAscendente
          ? fechaA.compareTo(fechaB)
          : fechaB.compareTo(fechaA);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('REPORTES'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                filtroFe = value;
              });
            },
            itemBuilder: (context) {
              List<String> opciones = datos.values
                  .map((mapa) => mapa['Fe'] as String)
                  .toSet()
                  .toList();
              opciones.insert(0, 'Todos');

              return opciones.map((opcion) {
                return PopupMenuItem(
                  value: opcion,
                  child: Text(opcion == 'Todos' ? 'Todos' : opcion),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: Icon(
                ordenAscendente ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                ordenAscendente = !ordenAscendente;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () async {
              DateTimeRange? rango = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (rango != null) {
                setState(() {
                  fechaInicio = rango.start;
                  fechaFin = rango.end;
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 3 / 4,
          ),
          itemCount: listaDatos.length,
          itemBuilder: (context, index) {
            final entrada = listaDatos[index];
            final actividad = entrada.value['Actividad'];
            final fecha = entrada.value['Fecha'];
            final reporte = entrada.value['Reporte'] as Uint8List;

            return GestureDetector(
              onTap: () async {
                final rutaPDF = await convertirAReporteLocal(
                    reporte, 'Reporte_${entrada.key}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VistaPDF(rutaPDF: rutaPDF),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_present, size: 48, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      actividad!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      fecha!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class VistaPDF extends StatelessWidget {
  final String rutaPDF;

  VistaPDF({required this.rutaPDF});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vista PDF')),
      body: PDFView(
        filePath: rutaPDF,
      ),
    );
  }
}
