import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:flutter/material.dart';

class ScreenPantallaPl003_01 extends StatelessWidget {
  static const String routeName = '/screen_pantalla_pl003_01';
  const ScreenPantallaPl003_01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('microrregión')),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        
      )
    );
  }
}