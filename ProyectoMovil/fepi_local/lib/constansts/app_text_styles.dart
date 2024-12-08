// app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  
  static TextStyle secondRegular({
    double fontSize = 16,
    Color color = AppColors.color3, 
  }) {
    if (![AppColors.color1, AppColors.color2, AppColors.color3].contains(color)) {
      color = AppColors.color3; 
    }
    return TextStyle(
      fontFamily: 'LexendDeca',
      fontWeight: FontWeight.normal,
      fontSize: fontSize,
      color: color,
    );
  }

  // DM Sans - Medium
  static TextStyle secondMedium({
    double fontSize = 18,
    Color color = AppColors.color3, 
  }) {
    if (![AppColors.color1, AppColors.color2, AppColors.color3].contains(color)) {
      color = AppColors.color3;
    }
    return TextStyle(
      fontFamily: 'LexendDeca',
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle secondBold({
    double fontSize = 20,
    Color color = AppColors.color3,
  }) {
    if (![AppColors.color1, AppColors.color2, AppColors.color3].contains(color)) {
      color = AppColors.color3;
    }
    return TextStyle(
      fontFamily: 'LexendDeca',
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
      color: color,
    );
  }

  // Dongle - Regular
  static TextStyle primaryRegular({
    double fontSize = 24,
    Color color = AppColors.color3,
  }) {
    if (![AppColors.color1, AppColors.color2, AppColors.color3].contains(color)) {
      color = AppColors.color3;
    }
    return TextStyle(
      fontFamily: 'Staatliches',
      fontWeight: FontWeight.normal,
      fontSize: fontSize,
      color: color,
    );
  }
  
}
