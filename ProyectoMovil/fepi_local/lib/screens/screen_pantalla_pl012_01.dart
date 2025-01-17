import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:go_router/go_router.dart';

class DynamicCardsWidget2 extends StatefulWidget {
  static const String routeName = '/screen_pantalla_pl012_01';

  @override
  _DynamicCardsWidgetState createState() => _DynamicCardsWidgetState();
}

class _DynamicCardsWidgetState extends State<DynamicCardsWidget2> {
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper();
    final prefs = await getSavedPreferences();
    final alumnos = await db.cargarAlumnosDeResponsables(prefs['id_Usuario'] ?? 0);
    setState(() {
      // Filtrar solo los elementos con estado 'pendiente'
      _data = alumnos.where((item) => item['state'] == 'pendiente').toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.color1,
          ),
          onPressed: () {
            context.pop();
          },
        ),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        centerTitle: true,
        title: Column(
          children: [
            SizedBox(height: 40),
            const Text("Validación de Alumnos"),
            SizedBox(height: 40),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _data.length,
              itemBuilder: (context, index) {
                final item = _data[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'CURP: ${item['curp'] ?? 'Sin CURP'}',
                          style: AppTextStyles.secondMedium(fontSize: 17),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.cancel,
                                color: AppColors.color3,
                                size: 20,
                              ),
                              onPressed: () =>
                                  _showRejectionDialog(context, item['id_Alumno']),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: AppColors.color2,
                                size: 20,
                              ),
                              onPressed: () =>
                                  _showConfirmationDialog(context, item['id_Alumno']),
                            ),
                          ],
                        ),
                      ),
                      _buildDetailsSection(context, item), // Detalles del alumno
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showRejectionDialog(BuildContext context, int idAlumno) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motivo de Rechazo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Escribe el motivo del rechazo:'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Motivo',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final db = DatabaseHelper();

              // Actualizar el motivo del rechazo en la base de datos
              await db.actualizarParametroAlumnoPorid(
                  idAlumno, 'nota', reasonController.text);

              // Cambiar el estado a 'rechazado'
              await db.actualizarParametroAlumnoPorid(idAlumno, 'state', 'rechazado');

              setState(() {
                _data.removeWhere((item) => item['id_Alumno'] == idAlumno);
              });

              Navigator.pop(context);
            },
            child: const Text('Enviar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, int idAlumno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Aceptación'),
        content: const Text('¿Está seguro de que desea aceptar esta solicitud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final db = DatabaseHelper();

              // Cambiar el estado a 'aprobado'
              await db.actualizarParametroAlumnoPorid(idAlumno, 'state', 'aprobado');

              setState(() {
                _data.removeWhere((item) => item['id_Alumno'] == idAlumno);
              });

              Navigator.pop(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, Map<String, dynamic> item) {
    final actaNacimiento = item['actaNacimiento']; // Documento PDF (Uint8List)
    final certificadoEstudios = item['certificadoEstudios']; // Documento PDF (Uint8List)
    final fotoVacunacion = item['fotoVacunacion']; // Imagen (Uint8List)

    return ExpansionTile(
      title: const Text('Ver datos', style: TextStyle(color: AppColors.color3)),
      children: [
        ListTile(title: Text('Estado: ${item['state'] ?? 'Desconocido'}')),
        ListTile(title: Text('Fecha de Nacimiento: ${item['fechaNacimiento'] ?? 'Desconocida'}')),
        ListTile(title: Text('Lugar de Nacimiento: ${item['lugarNacimiento'] ?? 'Desconocido'}')),
        ListTile(title: Text('Nivel Educativo: ${item['Nivel'] ?? 'N/A'}')),
        ListTile(title: Text('Grado Escolar: ${item['Grado'] ?? 'N/A'}')),

        ListTile(title: Text('Domicilio: ${item['domicilio'] ?? 'No disponible'}')),
        ListTile(title: Text('Municipio: ${item['municipio'] ?? 'Desconocido'}')),
        ListTile(title: Text('Estado: ${item['estado'] ?? 'Desconocido'}')),

        ListTile(title: Text('Nombre del Padre: ${item['nombrePadre'] ?? 'No disponible'}')),
        ListTile(title: Text('Ocupación del Padre: ${item['ocupacionPadre'] ?? 'Desconocida'}')),
        ListTile(title: Text('Teléfono del Padre: ${item['telefonoPadre'] ?? 'No disponible'}')),

        if (actaNacimiento != null)
          ListTile(
            title: const Text('Acta de Nacimiento:'),
            subtitle: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFView(
                      pdfData: actaNacimiento,
                    ),
                  ),
                );
              },
              child: const Text('Ver Acta de Nacimiento', style: TextStyle(color: Colors.blue)),
            ),
          ),

        if (certificadoEstudios != null)
          ListTile(
            title: const Text('Certificado de Estudios:'),
            subtitle: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFView(
                      pdfData: certificadoEstudios,
                    ),
                  ),
                );
              },
              child: const Text('Ver Certificado de Estudios', style: TextStyle(color: Colors.blue)),
            ),
          ),

        if (fotoVacunacion != null)
          ListTile(
            title: const Text('Foto de Vacunación:'),
            subtitle: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoViewGallery(
                      pageOptions: [
                        PhotoViewGalleryPageOptions(
                          imageProvider: MemoryImage(fotoVacunacion),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Text('Ver Foto de Vacunación', style: AppTextStyles.secondMedium()),
            ),
          ),
      ],
    );
  }
}
