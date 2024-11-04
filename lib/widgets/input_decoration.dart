import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration inputDecoration({
    required String hintext,
    required String labeltext,
    required Icon icon
  }){
    return  InputDecoration(
        enabledBorder: UnderlineInputBorder(
        borderSide:
        BorderSide(color: const Color.fromRGBO(144, 12, 63, 1))),
        focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
        color: const Color.fromRGBO(144, 12, 63, 5),
        width: 2)),
        hintText: hintext,
        labelText: labeltext,
        labelStyle: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
        prefixIcon: icon
    );
  }
}
