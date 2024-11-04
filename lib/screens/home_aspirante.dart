import 'package:flutter/material.dart';

// Pantalla de inicio para el formulario de aspirantes
// Esta pantalla mostrará el formulario principal de los aspirantes en la aplicación
// Puedes personalizar esta pantalla para incluir campos de datos relevantes

class HomeScreenAsp extends StatelessWidget {
  const HomeScreenAsp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Home formulario de aspirantes',
          style: TextStyle(fontSize: 20), // Puedes ajustar el tamaño de la fuente
        ),
      ),
      // Puedes agregar widgets dentro de este contenedor para darle estructura
    );
  }
}

