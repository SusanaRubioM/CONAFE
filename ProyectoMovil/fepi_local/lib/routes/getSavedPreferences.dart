import 'package:shared_preferences/shared_preferences.dart';

/// Function to retrieve saved values from SharedPreferences.
Future<Map<String, dynamic>> getSavedPreferences() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve values using their keys
  final int? idUsuario = prefs.getInt('id_Usuario');
  final String? rol = prefs.getString('rol');

  // Return the values in a Map
  return {
    'id_Usuario': idUsuario,
    'rol': rol,
  };
}
