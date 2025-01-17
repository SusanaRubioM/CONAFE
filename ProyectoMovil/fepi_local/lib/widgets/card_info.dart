import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:flutter/material.dart';

class CardInfo extends StatelessWidget {
  final String text;

  const CardInfo({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: double.infinity, // Llena todo el ancho disponible
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.color2, AppColors.color3],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icono de ubicación
              Icon(
                Icons.location_on,
                color: AppColors.color1,
                size: 28,
              ),
              const SizedBox(width: 12), // Espaciado entre el ícono y el texto
              // Texto
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.secondBold(color: AppColors.color1),
                  overflow: TextOverflow.ellipsis, // Maneja textos largos
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
