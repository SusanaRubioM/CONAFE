import 'package:fepi_local/JsonModels/users.dart';
import 'package:fepi_local/database/database_helper.dart';
import 'package:fepi_local/routes/go_rute.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';


extension on DatabaseHelper {
  // Definimos insertTestUser como async
  Future<void> insertTestUser() async {
    final Database db = await initDB();
    try {
      await db.insert(
        'userTable', // Asegúrate de que 'userTable' esté definido correctamente
        {'usrName': 'santi', '12345678': 'testPassword'},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      print('Usuario de prueba insertado correctamente.');
    } catch (e) {
      print('Error al insertar el usuario de prueba: $e');
    }
  }
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper dbHelper = DatabaseHelper();

  bool dbExists = await dbHelper.databaseExists();
  print("¿Base de datos creada? $dbExists");

  // Insertar usuario de prueba
  await dbHelper.insertTestUser(); // Cambiado a await para esperar la inserción

  // Verificar si el usuario de prueba se pudo agregar
  bool loginSuccess = await dbHelper.login(Users(usrName: 'testUser', usrPassword: 'testPassword'));
  print("¿Inicio de sesión exitoso con usuario de prueba? $loginSuccess");

  runApp(MainApp()); // Aquí es donde finalmente se llama a runApp
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
     return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
