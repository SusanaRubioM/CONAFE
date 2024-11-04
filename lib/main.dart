import 'package:flutter/material.dart';
import 'package:app_conafe/screens/home_aspirante.dart';
import 'package:app_conafe/screens/login_screen.dart';
import 'package:app_conafe/Database/database_helper.dart';
import 'package:app_conafe/JsonModels/users.dart'; // Importa la clase Users
import 'package:sqflite/sqflite.dart';

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

  runApp(MyApp()); // Aquí es donde finalmente se llama a runApp
}

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Conafe App Movil',
      routes: {
        'login': (_) => LoginScreen(),
        'home_aspirante': (_) => HomeScreenAsp(),
      },
      initialRoute: 'login',
    );
  }
}




