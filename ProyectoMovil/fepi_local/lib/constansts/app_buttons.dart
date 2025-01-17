import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppButtons {
  static ButtonStyle btnFORM({Color? backgroundColor, double? elevation}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.color3,
      elevation: elevation ?? 5,
      foregroundColor: AppColors.color1,
      shadowColor: AppColors.color4,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      textStyle: AppTextStyles.secondMedium(color: AppColors.color1),
    );
  }

  static InputDecoration textFieldStyle({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      labelStyle: AppTextStyles.secondMedium(color: AppColors.color2),
      hintStyle: AppTextStyles.secondRegular(color: AppColors.color3),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.color3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.color2, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.color4, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.color2, width: 2),
      ),
    );
  }

  static InputDecoration dropdownButtonStyle({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText ?? 'Selecciona una opción',
      labelText: labelText ?? 'Opción',
      labelStyle: AppTextStyles.secondMedium(color: AppColors.color2),
      hintStyle: AppTextStyles.secondRegular(color: AppColors.color4),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: AppColors.color3.withOpacity(0.1),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.color3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.color2, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.color4, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.color2, width: 2),
      ),
    );
  }
}
