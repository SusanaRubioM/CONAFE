import 'dart:typed_data';
import 'dart:io';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:flutter/material.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart'; // Para el calendario
import 'package:path_provider/path_provider.dart'; // Para obtener el directorio temporal
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Paquete para visualizar PDFs
import 'package:go_router/go_router.dart';

class ScreenPantallaPc00301 extends StatefulWidget {
  static const String routeName = '/screen_pantalla_pc003_01';
  const ScreenPantallaPc00301({super.key});

  @override
  _PlantillaState createState() => _PlantillaState();
}

class _PlantillaState extends State<ScreenPantallaPc00301> {
  late Map<String, dynamic> promocionData;
  late List<String> fechas; // Lista de fechas como cadenas
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    int idPromoFechas = 1; // Aquí debes poner el ID que quieras consultar
    final db = await DatabaseHelper();
    promocionData = await db.getPromocionFechasById(idPromoFechas);

    // Extrae las fechas del campo "fechas" y las convierte en una lista de cadenas
    String fechasString = promocionData['fechas'];
    fechas = fechasString.split(',').map((e) => e.trim()).toList();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _showPdf() async {
    Uint8List pdfData = promocionData['promocionPDF'];

    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/promocion.pdf';
    final file = File(tempPath);

    await file.writeAsBytes(pdfData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(pdfFilePath: tempPath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: AppColors.color1,),onPressed:(){context.pop();}),
        title: Text('FECHAS PROMOCION'),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: TableCalendar(
                        focusedDay: DateTime.now(),
                        firstDay: DateTime(2000),
                        lastDay: DateTime(2100),
                        selectedDayPredicate: (day) {
                          String formattedDay = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                          return fechas.contains(formattedDay);
                        },
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, day, events) {
                            String formattedDay = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                            if (fechas.contains(formattedDay)) {
                              return Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppColors.color3,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    day.day.toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _showPdf,
                        child: Text('Ver Promoción PDF'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.color2, backgroundColor: AppColors.color1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final String pdfFilePath;

  const PDFViewerPage({super.key, required this.pdfFilePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promoción PDF'),
        backgroundColor: AppColors.color3,
      ),
      body: Center(
        child: PDFView(
          filePath: pdfFilePath,
        ),
      ),
    );
  }
}
