import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:fepi_local/constansts/app_buttons.dart';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Paquete para la vista del PDF
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:go_router/go_router.dart';

class ScreenPantallaSe006_01 extends StatefulWidget {
  static const String routeName = '/screen_pantalla_se006_01';

  const ScreenPantallaSe006_01({super.key});

  @override
  State<ScreenPantallaSe006_01> createState() => _ReportesPantallaSe006_01();
}

class _ReportesPantallaSe006_01 extends State<ScreenPantallaSe006_01> {
  final List<Map<String, dynamic>> historialEnvios = [];
  Map<String, String> datosEC = {
    'NOMBRE_EC': 'Cargando...',
    'CLAVECOMUNIDAD': 'Cargando...',
  };

  /// Función para obtener el nombre y clave CCT
  Future<void> _cargarDatosEC() async {
    final prefs = await getSavedPreferences();
    final idUsuario = prefs['id_Usuario'] ?? 0;

    try {
      final datos = await DatabaseHelper().obtenerNombreUsuarioYClaveCCT(idUsuario);
      setState(() {
        datosEC = {
          'NOMBRE_EC': datos['nombreUsuario'] ?? 'Sin Nombre',
          'CLAVECOMUNIDAD': datos['claveCCT'] ?? 'Sin CCT',
        };
      });
    } catch (e) {
      print('Error al cargar datos EC: $e');
      setState(() {
        datosEC = {
          'NOMBRE_EC': 'Error al cargar',
          'CLAVECOMUNIDAD': 'Error al cargar',
        };
      });
    }
  }

  void _abrirFormulario() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: FormularioReporte(
            datosEC: datosEC,
            onGuardar: (String periodo, String reportePath) {
              setState(() {
                historialEnvios.add({
                  'Estado': 'pendiente',
                  'Periodo': periodo,
                  'Reporte': reportePath,
                });
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Future<String> _convertBlobToPdf(Uint8List blobData, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$fileName.pdf');
  await file.writeAsBytes(blobData);
  return file.path;
}


  void _verReporte(Uint8List blobData) async {
  try {
    final filePath = await _convertBlobToPdf(blobData, 'reporte_temporal');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReporteViewerScreen(reportePath: filePath),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Error al abrir el reporte. Datos no válidos."),
    ));
  }
}



  Future<void> _cargarHistorialEnvios() async {
    final prefs = await getSavedPreferences();
    final db = await DatabaseHelper();
    final reportes = await db
        .obtenerHistorialEnviosPorUsuario(prefs['id_Usuario'] ?? 0); // Cambia el ID si es necesario

    setState(() {
      print ('+++++++++++++++++++++++++$reportes');
      historialEnvios.clear();
      historialEnvios.addAll(
        reportes
            .where((reporte) =>
                reporte['Periodo'] != null &&
                reporte['Reporte'] != null &&
                reporte['Estado'] != null)
            .map((reporte) => {
                  'Periodo': reporte['Periodo'] as String,
                  'Reporte': reporte['Reporte'],
                  'Estado': reporte['Estado'] as String,
                }),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarDatosEC();
    _cargarHistorialEnvios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Reportes'),
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: AppColors.color1,),onPressed:(){context.pop();}),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: historialEnvios.length,
              itemBuilder: (context, index) {
                final envio = historialEnvios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  child: ListTile(
                    leading: Icon(Icons.file_copy, color: AppColors.color2),
                    title: Text(
                      'Periodo: ${envio['Periodo']}',
                      style:
                          AppTextStyles.primaryRegular(color: AppColors.color3),
                    ),
                    subtitle: Text(
                      'Estado: ${envio['Estado']}',
                      style:
                          AppTextStyles.secondRegular(color: AppColors.color2),
                    ),
                    onTap: () => _verReporte(envio['Reporte']!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: AppButtons.btnFORM(),
              onPressed: _abrirFormulario,
              child: const Text('Crear Nuevo Reporte'),
            ),
          ),
        ],
      ),
    );
  }
}

class FormularioReporte extends StatefulWidget {
  final Map<String, String> datosEC;
  final void Function(String periodo, String reportePath) onGuardar;

  const FormularioReporte({
    required this.datosEC,
    required this.onGuardar,
    super.key,
  });

  @override
  State<FormularioReporte> createState() => _FormularioReporteState();
}

class _FormularioReporteState extends State<FormularioReporte> {
  final TextEditingController _periodoController = TextEditingController();
  final TextEditingController _reporteController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Clave para el formulario
  String? _archivoSubido;
  bool _escribirReporte = false;

  Future<Map<String, dynamic>> convertirArchivoABlobYDevolverMapa({
    required String periodo,
    required String estado,
    required String reportePath,
    required int idUsuario,
  }) async {
    final file = File(reportePath);
    final fileBytes = await file.readAsBytes(); // Leer como Uint8List

    return {
      'Periodo': periodo,
      'Estado': estado,
      'Reporte': fileBytes, // Almacenar como Uint8List
      'id_usuario': idUsuario,
    };
  }

  Future<void> _guardarComoPDF() async {
    final pdf = pw.Document();

    // Primera página (con detalles de EC y el periodo)
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Reporte'),
            pw.Text('Nombre EC: ${widget.datosEC['NOMBRE_EC']}'),
            pw.Text('Clave Comunidad: ${widget.datosEC['CLAVECOMUNIDAD']}'),
            pw.Text('Período: ${_periodoController.text}'),
          ],
        ),
      ),
    );

    // Segunda página (con el contenido del reporte)
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(_reporteController.text),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/reporte_${_periodoController.text}.pdf');
    await file.writeAsBytes(await pdf.save());
    widget.onGuardar(_periodoController.text, file.path);
  }

  Future<void> _subirArchivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _archivoSubido = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey, // Clave del formulario para validaciones
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: AppButtons.textFieldStyle(
                labelText: 'Periodo',
                hintText: 'DD_MM_AAAA-DD_MM_AAAA',
              ),
              controller: _periodoController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El período es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              activeColor: AppColors.color3,
              checkColor: AppColors.color1,
              hoverColor: AppColors.color2,
              title: Text(
                'Redactar Reporte',
                style: AppTextStyles.secondMedium(),
              ),
              value: _escribirReporte,
              onChanged: (value) {
                setState(() {
                  _escribirReporte = value!;
                });
              },
            ),
            if (_escribirReporte)
              TextFormField(
                controller: _reporteController,
                maxLines: 5,
                decoration:
                    AppButtons.textFieldStyle(labelText: 'Escribe tu reporte'),
                validator: (value) {
                  if (_escribirReporte && (value == null || value.isEmpty)) {
                    return 'El contenido del reporte es obligatorio';
                  }
                  return null;
                },
              ),
            if (!_escribirReporte)
              ElevatedButton(
                style: AppButtons.btnFORM(
                  backgroundColor: _archivoSubido == null
                      ? AppColors.color2
                      : AppColors.color3,
                ),
                onPressed: _subirArchivo,
                child: Text(
                  _archivoSubido == null
                      ? 'Seleccionar Archivo'
                      : 'Archivo Seleccionado',
                ),
              ),
            const SizedBox(height: 20),
            if (_archivoSubido != null || _escribirReporte)
              ElevatedButton(
                style: AppButtons.btnFORM(backgroundColor: AppColors.color2),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final prefs = await getSavedPreferences();
                    int idUsuario = prefs['id_Usuario'] ?? 0;
                    String? reportePath;

                    if (_escribirReporte) {
                      await _guardarComoPDF();
                      final dir = await getApplicationDocumentsDirectory();
                      reportePath =
                          '${dir.path}/reporte_${_periodoController.text}.pdf';
                    } else if (_archivoSubido != null) {
                      reportePath = _archivoSubido;
                    }

                    if (reportePath != null) {
                      final mapa = await convertirArchivoABlobYDevolverMapa(
                        periodo: _periodoController.text,
                        estado: 'pendiente',
                        reportePath: reportePath,
                        idUsuario: idUsuario,
                      );
                      final db = await DatabaseHelper();
                      db.insertarReporte(mapa);
                      print("Mapa generado: $mapa");
                    } else {
                      print('No se seleccionó o generó un archivo válido.');
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
          ],
        ),
      ),
    );
  }
}




class ReporteViewerScreen extends StatefulWidget {
  final String reportePath;

  const ReporteViewerScreen({required this.reportePath, super.key});

  @override
  State<ReporteViewerScreen> createState() => _ReporteViewerScreenState();
}

class _ReporteViewerScreenState extends State<ReporteViewerScreen> {
  late PDFViewController _pdfViewController;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte'),
      ),
      body: PDFView(
        filePath: widget.reportePath,
        onViewCreated: (PDFViewController pdfViewController) {
          _pdfViewController = pdfViewController;
          _pdfViewController.getPageCount().then((count) {
            setState(() {
              _totalPages = count ?? 0;
            });
          });
        },
        onPageChanged: (int? page, int? total) {
          setState(() {
            _currentPage = page ?? 0; // Si page es null, asigna 0
          });
        },
        autoSpacing: true,
        pageSnap: true,
        enableSwipe: true, // Habilita el swipe para navegar por las páginas
        swipeHorizontal: false,
        onError: (error) {
          print('Error en el visor de PDF: $error');
        },
      ),
    );
  }
}
