import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class CalificacionesScreen extends StatefulWidget {
  static const String routeName = '/screen_pantalla_se00401';

  @override
  _CalificacionesScreenState createState() => _CalificacionesScreenState();
}

class _CalificacionesScreenState extends State<CalificacionesScreen> {
  Database? db;
  List<Map<String, dynamic>> grupos = [];
  List<Map<String, dynamic>> alumnos = [];
  List<Map<String, dynamic>> materias = [];
  Map<int, Map<int, TextEditingController>> calificaciones = {};
  int? selectedGrupo;
  int selectedPeriodo = 1;

  @override
  void initState() {
    super.initState();
    _initializeDB();
  }

  Future<void> _initializeDB() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'Conafe.db');

    db = await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );

    _loadGrupos();
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS PromocionesAlumnos (
        id_PromocionAlumno INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Alumno INTEGER,
        calfFinal INTEGER,
        tipoPromocion TEXT,
        FOREIGN KEY (id_Alumno) REFERENCES Alumnos(id_Alumno)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Calificaciones (
        id_Calf INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Alumno INTEGER,
        id_Materia INTEGER,
        calificacion INTEGER,
        Periodo INTEGER,
        FOREIGN KEY (id_Alumno) REFERENCES Alumnos(id_Alumno),
        FOREIGN KEY (id_Materia) REFERENCES Materias(id_Materia)
      );
    ''');
  }

  Future<void> _loadGrupos() async {
    final gruposData = await db!.query('Grupos');
    setState(() {
      grupos = gruposData;
    });
  }

  Future<bool> _checkPreviousPeriods(int alumnoId) async {
    for (int periodo = 1; periodo < 5; periodo++) {
      final result = await db!.rawQuery('''
        SELECT COUNT(*) as count
        FROM Calificaciones
        WHERE id_Alumno = ? AND Periodo = ?
      ''', [alumnoId, periodo]);

      if (result.isNotEmpty && result.first['count'] == 0) {
        return false;
      }
    }
    return true;
  }

  Future<void> _loadAlumnos(int grupoId) async {
    final alumnosData = await db!.rawQuery('''
      SELECT * FROM Alumnos WHERE id_Alumno IN (
        SELECT id_Alumno FROM AsignacionGrupos WHERE id_Grupo = ?
      )
    ''', [grupoId]);

    final grupo = await db!.query(
      'Grupos',
      where: 'id_Grupo = ?',
      whereArgs: [grupoId],
    );

    if (grupo.isNotEmpty) {
      final gradoCompleto = grupo.first['Grado']?.toString() ?? '';
      final grado = RegExp(r'\d+').firstMatch(gradoCompleto)?.group(0) ?? '0';

      final materiasData = await db!.rawQuery(
        '''
        SELECT * FROM Materias
        WHERE Grado = ?
        LIMIT 5
        ''',
        [grado],
      );

      setState(() {
        alumnos = alumnosData;
        materias = materiasData;

        for (var alumno in alumnos) {
          calificaciones[alumno['id_Alumno']] = {};
          for (var materia in materias) {
            calificaciones[alumno['id_Alumno']]![materia['id_Materia']] =
                TextEditingController();
          }
        }
      });
    }
  }

  Future<void> _guardarCalificaciones() async {
    for (var alumno in alumnos) {
      for (var materia in materias) {
        final calificacion = int.tryParse(
              calificaciones[alumno['id_Alumno']]![materia['id_Materia']]!.text,
            ) ??
            -1;

        if (calificacion < 0 || calificacion > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Calificación inválida para el alumno ${alumno['curp']} en ${materia['Nombre']}.'),
            ),
          );
          return;
        }

        await db!.insert('Calificaciones', {
          'id_Alumno': alumno['id_Alumno'],
          'id_Materia': materia['id_Materia'],
          'calificacion': calificacion,
          'Periodo': selectedPeriodo,
        });

        print('Insertando calificación: Alumno=${alumno['id_Alumno']}, '
            'Materia=${materia['id_Materia']}, '
            'Calificación=$calificacion, '
            'Periodo=$selectedPeriodo');
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calificaciones guardadas correctamente.')),
    );
  }

  Future<void> _generateCertificate(int alumnoId) async {
    final previousPeriodsValid = await _checkPreviousPeriods(alumnoId);

    if (!previousPeriodsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe tener calificaciones en todos los periodos anteriores.'),
        ),
      );
      return;
    }

    final pdf = pw.Document();
    final alumno = alumnos.firstWhere((a) => a['id_Alumno'] == alumnoId);
    double promedio = 0;

    for (var materia in materias) {
      final result = await db!.rawQuery('''
        SELECT AVG(calificacion) as promedio
        FROM Calificaciones
        WHERE id_Alumno = ? AND id_Materia = ?
      ''', [alumnoId, materia['id_Materia']]);

      promedio += (result.first['promedio'] as num?)?.toDouble() ?? 0.0;
    }

    promedio /= materias.length;

    final tipoPromocion = promedio >= 60 ? 'Ordinario' : 'Regularización';
    await db!.insert('PromocionesAlumnos', {
      'id_Alumno': alumnoId,
      'calfFinal': promedio.round(),
      'tipoPromocion': tipoPromocion,
    });

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: [
                pw.Text('Certificado de Calificaciones', style: pw.TextStyle(fontSize: 24)),
                pw.Text('Alumno: ${alumno['curp']}'),
                pw.Text('Promedio: ${promedio.toStringAsFixed(2)}'),
                pw.Text('Estatus: $tipoPromocion'),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/${alumno['curp']}_certificado.pdf');
    await file.writeAsBytes(await pdf.save());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(filePath: file.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calificaciones')),
      body: Column(
        children: [
          DropdownButton<int>(
            value: selectedGrupo,
            hint: const Text('Seleccione un grupo'),
            onChanged: (value) {
              setState(() {
                selectedGrupo = value;
              });
              _loadAlumnos(value!);
            },
            items: grupos.map((grupo) {
              return DropdownMenuItem<int>(
                value: grupo['id_Grupo'],
                child: Text('Grupo: ${grupo['Grado']}'),
              );
            }).toList(),
          ),
          DropdownButton<int>(
            value: selectedPeriodo,
            hint: const Text('Seleccione un período'),
            onChanged: (value) {
              setState(() {
                selectedPeriodo = value!;
              });
            },
            items: List.generate(5, (index) => index + 1).map((periodo) {
              return DropdownMenuItem<int>(
                value: periodo,
                child: Text('Periodo: $periodo'),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: alumnos.length,
              itemBuilder: (context, index) {
                final alumno = alumnos[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CURP: ${alumno['curp']}'),
                        ...materias.map((materia) {
                          return Row(
                            children: [
                              Expanded(child: Text(materia['Nombre'])),
                              Expanded(
                                child: TextField(
                                  controller: calificaciones[alumno['id_Alumno']]![materia['id_Materia']]!,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Calificación (0-100)',
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _guardarCalificaciones,
            child: const Text('Guardar Calificaciones'),
          ),
          if (selectedPeriodo == 5)
            ElevatedButton(
              onPressed: () => _generateCertificate(alumnos.first['id_Alumno']),
              child: const Text('Generar Certificado'),
            ),
        ],
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String filePath;

  const PDFViewerScreen({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Certificado')),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
