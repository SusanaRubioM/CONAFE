import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AlumnosDB {
  static final AlumnosDB _instance = AlumnosDB._();
  Database? _database;

  AlumnosDB._();

  factory AlumnosDB() => _instance;

  // Método para inicializar o obtener la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicialización de la base de datos
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'alumnos.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE AlumnosAlta (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            actaNacimiento BLOB, -- Archivo PDF
            curp TEXT,
            fechaNacimiento TEXT,
            lugarNacimiento TEXT,
            domicilio TEXT,
            municipio TEXT,
            estado TEXT,
            nivelEducativo TEXT,
            gradoEscolar TEXT,
            certificadoEstudios BLOB, -- Archivo PDF
            nombrePadre TEXT,
            ocupacionPadre TEXT,
            telefonoPadre TEXT,
            fotoVacunacion BLOB, -- Imagen
            state TEXT,
            nota TEXT
          )
        ''');
      },
      version: 1,
    );
  }
  

  // Método para actualizar un solo parámetro en la tabla AlumnosAlta según su CURP
Future<int> actualizarParametroAlumnoPorCURP(String curp, String parametro, dynamic valor) async {
  final db = await AlumnosDB().database;
  return await db.update(
    'AlumnosAlta',
    {parametro: valor},
    where: 'curp = ?',
    whereArgs: [curp],
  );
}


  // Método para insertar un registro en la tabla AlumnosAlta
  Future<int> insertAlumno(Map<String, dynamic> alumno) async {
    final db = await database;
    return await db.insert('AlumnosAlta', alumno);
  }

  // Método para leer todos los registros de la tabla AlumnosAlta
  Future<List<Map<String, dynamic>>> getAlumnos() async {
    final db = await database;
    return await db.query('AlumnosAlta');
  }

  // Método para borrar todos los registros de la tabla (opcional, para pruebas)
  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('AlumnosAlta');
  }
}

// Función para insertar datos desde un Map con archivos binarios
Future<void> insertarAlumnoConArchivos(Map<String, dynamic> alumno) async {
  final db = AlumnosDB();

  Uint8List? actaNacimientoBytes;
  if (alumno['actaNacimiento'] != null) {
    final file = alumno['actaNacimiento'] as File; // Conversión explícita
    actaNacimientoBytes = await file.readAsBytes();
  }

  Uint8List? certificadoEstudiosBytes;
  if (alumno['certificadoEstudios'] != null) {
    final file = alumno['certificadoEstudios'] as File; // Conversión explícita
    certificadoEstudiosBytes = await file.readAsBytes();
  }

  Uint8List? fotoVacunacionBytes;
  if (alumno['fotoVacunacion'] != null) {
    final file = alumno['fotoVacunacion'] as File; // Conversión explícita
    fotoVacunacionBytes = await file.readAsBytes();
  }

  await db.insertAlumno({
    'actaNacimiento': actaNacimientoBytes,
    'curp': alumno['curp'] ?? '',
    'fechaNacimiento': alumno['fechaNacimiento'] ?? '',
    'lugarNacimiento': alumno['lugarNacimiento'] ?? '',
    'domicilio': alumno['domicilio'] ?? '',
    'municipio': alumno['municipio'] ?? '',
    'estado': alumno['estado'] ?? '',
    'nivelEducativo': alumno['nivelEducativo'] ?? '',
    'gradoEscolar': alumno['gradoEscolar'] ?? '',
    'certificadoEstudios': certificadoEstudiosBytes,
    'nombrePadre': alumno['nombrePadre'] ?? '',
    'ocupacionPadre': alumno['ocupacionPadre'] ?? '',
    'telefonoPadre': alumno['telefonoPadre'] ?? '',
    'fotoVacunacion': fotoVacunacionBytes,
    'state': alumno['state'],
    'nota': alumno['nota'],
    'id_Maestro': alumno['id_Maestro']
  });
}

// Función para recuperar un archivo y guardarlo en el sistema de archivos
Future<void> recuperarArchivo(Map<String, dynamic> alumno, String destinoPath, String tipoArchivo) async {
  if (alumno[tipoArchivo] != null) {
    try {
      final bytes = alumno[tipoArchivo] as Uint8List;
      final file = File(destinoPath);
      await file.writeAsBytes(bytes);
    } catch (e) {
      print('Error al recuperar el archivo $tipoArchivo: $e');
    }
  }
}
