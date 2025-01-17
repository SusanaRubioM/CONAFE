import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PersonalECDB {
  static final PersonalECDB _instance = PersonalECDB._();
  Database? _database;

  PersonalECDB._();

  factory PersonalECDB() => _instance;

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
      join(dbPath, 'personal_EC.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE PersonalEC (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            NombreCompleto TEXT,
            Rol TEXT,
            Ubicacion TEXT,
            Situacion TEXT,
            TipoServicio TEXT,
            Contexto TEXT,
            Estatus TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  // Método para insertar un registro en la tabla PersonalEC
  Future<int> insertPersonal(Map<String, dynamic> personal) async {
    final db = await database;
    return await db.insert('PersonalEC', personal);
  }

  // Método para leer todos los registros de la tabla PersonalEC
  Future<List<Map<String, dynamic>>> getPersonal() async {
    final db = await database;
    return await db.query('PersonalEC');
  }

  // Método para borrar todos los registros de la tabla PersonalEC (opcional, para pruebas)
  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('PersonalEC');
  }

  // Método para inyectar datos de prueba en la tabla PersonalEC
  Future<void> inyectarDatosDePrueba() async {
    final db = await database;
    await db.insert('PersonalEC', {
      'NombreCompleto': 'Juan',
      'Rol': 'EC',
      'Ubicacion': 'Aún no asignado',
      'Situacion': 'Colaborador',
      'TipoServicio': 'Secundaria',
      'Contexto': 'Indigena',
      'Estatus': 'Activo'
    });
    // Puedes añadir más registros de prueba aquí
  }
}

