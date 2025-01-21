// Archivo: lib/Database/database_helper.dart

import 'package:fepi_local/JsonModels/user_model.dart';
import 'package:fepi_local/JsonModels/users.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseHelper {
  static const _databaseName = "notes.db";
  static const _databaseVersion = 1;

  static const userTable = "users";
  static const noteTable = "notes";

  // Comando SQL para crear la tabla de usuarios
  final String _createUserTable = '''
    CREATE TABLE $userTable (
      usrId INTEGER PRIMARY KEY AUTOINCREMENT,
      usrName TEXT UNIQUE,
      usrPassword TEXT
    );
  ''';

  // Comando SQL para crear la tabla de notas
  final String _createNoteTable = '''
    CREATE TABLE $noteTable (
      noteId INTEGER PRIMARY KEY AUTOINCREMENT,
      noteTitle TEXT NOT NULL,
      noteContent TEXT NOT NULL,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP
    );
  ''';

  // Inicializar la base de datos
  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute(_createUserTable);
        await db.execute(_createNoteTable);
      },
    );
  }

  // Método para iniciar sesión
  Future<bool> login(Users user) async {
    final Database db = await initDB();

    try {
      final result = await db.query(
        userTable,
        where: "usrName = ? AND usrPassword = ?",
        whereArgs: [user.usrName, user.usrPassword],
      );
      return result.isNotEmpty;
    } catch (e) {
      print("Error al intentar iniciar sesión: $e");
      return false;
    }
  }

  // Método para registrar un usuario
  Future<int> signup(Users user) async {
    final Database db = await initDB();

    try {
      return await db.insert(userTable, user.toMap());
    } catch (e) {
      print("Error al intentar registrar usuario: $e");
      return -1; // Retornar un valor que indique error en la inserción
    }
  }


  Future<void> insertTestUser() async {
    final Database db = await initDB();
    try {
      await db.insert(
          userTable,
          {'usrName': 'emmanuel', 'usrPassword': '1234567890'},
          conflictAlgorithm: ConflictAlgorithm.ignore
      );
      print('Usuario de prueba insertado correctamente.');
    } catch (e) {
      print('Error al insertar el usuario de prueba: $e');
    }
  }



  // Método para buscar notas por palabra clave
  Future<List<NoteModel>> searchNotes(String keyword) async {
    final Database db = await initDB();
    final searchResult = await db.rawQuery(
      "SELECT * FROM $noteTable WHERE noteTitle LIKE ?",
      ["%$keyword%"],
    );
    return searchResult.map((e) => NoteModel.fromMap(e)).toList();
  }

  // Método para crear una nueva nota
  Future<int> createNote(NoteModel note) async {
    final Database db = await initDB();
    return await db.insert(noteTable, note.toMap());
  }

  // Método para obtener todas las notas
  Future<List<NoteModel>> getNotes() async {
    final Database db = await initDB();
    final result = await db.query(noteTable);
    return result.map((e) => NoteModel.fromMap(e)).toList();
  }

  // Método para eliminar una nota
  Future<int> deleteNote(int id) async {
    final Database db = await initDB();
    return await db.delete(noteTable, where: 'noteId = ?', whereArgs: [id]);
  }

  Future<bool> databaseExists() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    return await databaseFactory.databaseExists(path);
  }

  // Método para actualizar una nota
  Future<int> updateNote(String title, String content, int noteId) async {
    final Database db = await initDB();
    return await db.update(
      noteTable,
      {'noteTitle': title, 'noteContent': content},
      where: 'noteId = ?',
      whereArgs: [noteId],
    );
  }
}





