import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:fepi_local/widgets/fecha.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fepi_local/constansts/app_buttons.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';

class FormRegistroAlumno extends StatefulWidget {
  @override
  _FormRegistroAlumnoState createState() => _FormRegistroAlumnoState();
}

class _FormRegistroAlumnoState extends State<FormRegistroAlumno> {
  int? idmaestro;
  // Controladores de texto
  TextEditingController fechaNacimientoController = TextEditingController();
  TextEditingController lugarNacimientoController = TextEditingController();
  TextEditingController domicilioController = TextEditingController();
  TextEditingController municipioController = TextEditingController();
  TextEditingController estadoController = TextEditingController();
  TextEditingController nombrePadreController = TextEditingController();
  TextEditingController curpController = TextEditingController();
  TextEditingController ocupacionPadreController = TextEditingController();
  TextEditingController telefonoPadreController = TextEditingController();

  // Variables para los documentos
  File? actaNacimiento;
  File? certificadoEstudios;
  File? cartillaVacunacion;

  // Variables para las fotos
  File? fotoVacunacion;

  // Variables para los selectores
  String? nivelEducativo;
  String? gradoEscolar;

  // Función para obtener el nivel educativo
  Future<void> _fetchNivelEducativo() async {
    final prefs = await getSavedPreferences();
    final dbHelper = DatabaseHelper(); // Instancia de la base de datos
    final tipoServicio = await dbHelper.getTipoServicioCCT(prefs['id_Usuario'] ?? 0);

    setState(() {
      idmaestro=prefs['id_Usuario'] ?? 0;
      nivelEducativo = tipoServicio; // Asigna el valor obtenido a nivelEducativo
      print('>>>>$nivelEducativo');
    });
  }

  // Validación de CURP
  bool validarCURP() {
    final curpRegex = RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[A-Z\d]{2}$');
    if (curpController.text.isEmpty) {
      _mostrarError('El CURP es obligatorio.');
      return false;
    }
    if (!curpRegex.hasMatch(curpController.text)) {
      _mostrarError('Formato de CURP inválido.');
      return false;
    }
    return true;
  }

  // Validación de campos requeridos
  bool validarCampos() {
    if (fechaNacimientoController.text.isEmpty) {
      _mostrarError('La fecha de nacimiento es obligatoria.');
      return false;
    }
    if (lugarNacimientoController.text.isEmpty) {
      _mostrarError('El lugar de nacimiento es obligatorio.');
      return false;
    }
    if (domicilioController.text.isEmpty) {
      _mostrarError('El domicilio es obligatorio.');
      return false;
    }
    if (municipioController.text.isEmpty) {
      _mostrarError('El municipio es obligatorio.');
      return false;
    }
    if (estadoController.text.isEmpty) {
      _mostrarError('El estado es obligatorio.');
      return false;
    }
    if (nombrePadreController.text.isEmpty) {
      _mostrarError('El nombre del padre o tutor es obligatorio.');
      return false;
    }
    if (ocupacionPadreController.text.isEmpty) {
      _mostrarError('La ocupación del padre o tutor es obligatoria.');
      return false;
    }
    return true;
  }

  // Mostrar mensaje de error
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: AppTextStyles.secondRegular(color: AppColors.color1),
        ),
      ),
    );
  }

  Future<void> _pickActaNacimiento() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      if (await file.exists()) {
        setState(() {
          actaNacimiento = file;
        });
        print("Archivo seleccionado: ${file.path}");
      } else {
        print("El archivo no existe en la ruta seleccionada.");
      }
    } else {
      print("No se seleccionó ningún archivo.");
    }
  }

  // Método para seleccionar un archivo específico para PDFs
  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: type == 'pdf' ? ['pdf'] : ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        if (type == 'pdf') {
          certificadoEstudios = File(result.files.single.path!);
        } else if (type == 'vacunacion') {
          fotoVacunacion = File(result.files.single.path!);
        }
      });
    }
  }

  // Función para crear el mapa con la información
  Map<String, dynamic> obtenerDatosFormulario() {
    return {
      'actaNacimiento': actaNacimiento,
      'curp': curpController.text, // CURP como texto
      'fechaNacimiento': fechaNacimientoController.text,
      'lugarNacimiento': lugarNacimientoController.text,
      'domicilio': domicilioController.text,
      'municipio': municipioController.text,
      'estado': estadoController.text,
      'nivelEducativo': nivelEducativo,
      'gradoEscolar': gradoEscolar,
      'certificadoEstudios': certificadoEstudios,
      'nombrePadre': nombrePadreController.text,
      'ocupacionPadre': ocupacionPadreController.text,
      'telefonoPadre': telefonoPadreController.text,
      'fotoVacunacion': fotoVacunacion,
      'state': 'pendiente',
      'nota': ' ',
      'id_Maestro': idmaestro,
    };
  }

  @override
  void initState() {
    super.initState();
    _fetchNivelEducativo();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de carga de documentos
            Container(
                foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 2, color: AppColors.color2)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text("Documentos de Identidad",
                          style: AppTextStyles.secondBold(
                              color: AppColors.color2)),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: ElevatedButton.icon(
                          icon: Icon(actaNacimiento == null
                              ? Icons.note_add_sharp
                              : Icons.file_copy),
                          onPressed: _pickActaNacimiento,
                          style: AppButtons.btnFORM(
                              backgroundColor: actaNacimiento == null
                                  ? AppColors.color3
                                  : AppColors.color2),
                          label: Text(actaNacimiento == null
                              ? 'Cargar Acta de Nacimiento'
                              : 'Acta de Nacimiento Cargada'),
                        ),
                      ),
                    ],
                  ),
                )),
            SizedBox(
              height: 20,
            ),
            Container(
              foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 2, color: AppColors.color2)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "Datos Personales",
                      style: AppTextStyles.secondBold(color: AppColors.color2),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: curpController,
                      decoration: AppButtons.textFieldStyle(
                        hintText: 'Escribe tu CURP',
                        labelText: 'CURP',
                        prefixIcon: Icon(Icons.assignment_ind_outlined),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    DateTextField(
                      controller: fechaNacimientoController,
                      decoration: AppButtons.textFieldStyle(
                        hintText: 'DD/MM/AAAA',
                        labelText: 'Fecha de Nacimiento',
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: lugarNacimientoController,
                      decoration: AppButtons.textFieldStyle(
                        hintText: 'Escribe el lugar de Nacimiento',
                        labelText: 'Lugar de Nacimiento',
                        prefixIcon: Icon(Icons.add_location_rounded),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: domicilioController,
                      decoration: AppButtons.textFieldStyle(
                        hintText: 'Escribe tu Domicilio',
                        labelText: 'Domicilio',
                        prefixIcon: Icon(Icons.house),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: municipioController,
                      decoration: AppButtons.textFieldStyle(
                        hintText: 'Escribe tu Municipio',
                        labelText: 'Municipio',
                        prefixIcon: Icon(Icons.map),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: estadoController,
                      decoration: AppButtons.textFieldStyle(
                        hintText: 'Escribe tu Estado',
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 20,
            ),
            // Sección de datos académicos
            Container(
              foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 2, color: AppColors.color2)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "Datos Académicos",
                      style: AppTextStyles.secondBold(color: AppColors.color2),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    
                    DropdownButtonFormField<String>(
                      value: gradoEscolar,
                      decoration: AppButtons.dropdownButtonStyle(
                        hintText:
                            'Grado Escolar', // Personaliza el texto de hint
                        labelText:
                            'Grado Escolar', // Personaliza el texto de label
                      ),
                      items: ['Grado 1', 'Grado 2', 'Grado 3', 'Grado 4', 'Grado 5', 'Grado 6']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          gradoEscolar = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton.icon(
                      icon: Icon(certificadoEstudios == null
                          ? Icons.file_present_sharp
                          : Icons.file_copy),
                      style: AppButtons.btnFORM(
                          backgroundColor: certificadoEstudios == null
                              ? AppColors.color3
                              : AppColors.color2),
                      onPressed: () => _pickFile('pdf'),
                      label: Text(certificadoEstudios == null
                          ? 'Cargar Certificado'
                          : 'Certificado Cargado'),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
            // Sección de identidad de los padres
            Container(
              foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 2, color: AppColors.color2)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Identidad de los Padres/Tutores",
                      style: AppTextStyles.secondBold(color: AppColors.color2),
                    ),
                    TextField(
                      controller: nombrePadreController,
                      decoration: AppButtons.textFieldStyle(
                        hintText: 'Escribe el nombre',
                        labelText: 'Nombre del Padre/Tutor',
                        prefixIcon: Icon(Icons.supervised_user_circle),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: ocupacionPadreController,
                      decoration: AppButtons.textFieldStyle(
                        hintText: 'Escribe la ocupación',
                        labelText: 'Ocupación del Padre/Tutor',
                        prefixIcon: Icon(Icons.business_center),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: telefonoPadreController,
                      keyboardType: TextInputType.phone,
                      decoration: AppButtons.textFieldStyle(
                        hintText: 'Escribe el telefono',
                        labelText: 'Teléfono del Padre/Tutor',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: () => _pickFile('vacunacion'),
              icon: Icon(fotoVacunacion == null
                  ? Icons.add_photo_alternate_rounded
                  : Icons.file_copy),
              style: AppButtons.btnFORM(
                  backgroundColor: fotoVacunacion == null
                      ? AppColors.color3
                      : AppColors.color2),
              label: Text(fotoVacunacion == null
                  ? 'Cargar cartilla de vacunación'
                  : 'Cartilla Cargada'),
            ),
            fotoVacunacion != null ? SizedBox.shrink() : SizedBox.shrink(),

            // Botón para finalizar el formulario
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  style: AppButtons.btnFORM(backgroundColor: AppColors.color2),
                  onPressed: () async {
                if (validarCURP() && validarCampos()) {
                  final data = obtenerDatosFormulario();
                  print (data);
                  final db = DatabaseHelper();

                  try {
                    await db.insertarAlumno(data);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Registro guardado exitosamente.',
                          style: AppTextStyles.secondRegular(color: AppColors.color1),
                        ),
                      ),
                    );
                  } catch (e) {
                    _mostrarError('Error al guardar el registro: $e');
                  }
                }
              },
                  child: Text('Enviar Registro'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
