import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DateTextField extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;

  DateTextField({
    required this.controller,
    required this.decoration,
  });

  // Función para formatear la fecha en formato DD/MM/AAAA
  void _onDateChanged(String text) {
    // Quitamos cualquier caracter no numérico
    String newText = text.replaceAll(RegExp(r'[^0-9]'), '');

    // Formateamos el texto en el formato DD/MM/AAAA
    if (newText.length >= 2) {
      newText = newText.substring(0, 2) + '/' + newText.substring(2);
    }
    if (newText.length >= 5) {
      newText = newText.substring(0, 5) + '/' + newText.substring(5);
    }

    // Validamos que el día esté entre 01 y 31 y el mes entre 01 y 12
    if (newText.length >= 2 && int.tryParse(newText.substring(0, 2)) != null) {
      int day = int.parse(newText.substring(0, 2));
      if (day < 1 || day > 31) {
        newText = newText.substring(0, 2); // Limita el día a 31
      }
    }
    if (newText.length >= 5 && int.tryParse(newText.substring(3, 5)) != null) {
      int month = int.parse(newText.substring(3, 5));
      if (month < 1 || month > 12) {
        newText = newText.substring(0, 5); // Limita el mes a 12
      }
    }

    // Actualizamos el controller con el nuevo texto formateado
    controller.text = newText;
    controller.selection = TextSelection.collapsed(offset: newText.length); // Mantenemos el cursor al final
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number, // Solo números
      decoration: decoration.copyWith( // Usamos la decoración proporcionada
        prefixIcon: Icon(Icons.calendar_today), // Añadimos el icono de calendario
      ),
      onChanged: _onDateChanged, // Llamamos a la función cuando cambia el texto
      inputFormatters: [
        // Esto asegura que solo se ingresen números y barras
        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}/?\d{0,2}/?\d{0,4}$')),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Fecha Formateada'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DateTextField(
          controller: TextEditingController(),
          decoration: InputDecoration(
            hintText: 'Introduce la fecha',
            labelText: 'Fecha',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    ),
  ));
}
