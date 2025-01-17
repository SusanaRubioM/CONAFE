import 'package:fepi_local/database/database_gestor.dart'; 
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:table_calendar/table_calendar.dart';

class ScreenPantallaBe002 extends StatefulWidget {
  static const String routeName = '/screen_pantalla_be002';
  const ScreenPantallaBe002({super.key});

  @override
  _ScreenPantallaBe002State createState() => _ScreenPantallaBe002State();
}

class _ScreenPantallaBe002State extends State<ScreenPantallaBe002> {
  Map<String, List<Map<String, dynamic>>> paymentData = {};

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    final db = DatabaseHelper();
    final prefs = await getSavedPreferences();
    Map<String, List<Map<String, dynamic>>> pagos = await db.obtenerPagosPorUsuario(prefs['id_Usuario'] ?? 0);
    setState(() {
      paymentData = pagos;
    });
  }

  void _confirmarPago(String fecha, Map<String, dynamic> pago) async {
    final db = DatabaseHelper();
    final prefs = await getSavedPreferences();
    final int idUsuario = prefs['id_Usuario'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Pago', style: AppTextStyles.secondBold()),
        content: Text(
          '¿Deseas confirmar el pago de tipo "${pago['tipopago']}" por \$${pago['monto']} en la fecha $fecha?',
          style: AppTextStyles.secondRegular(color: AppColors.color2, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar', style: TextStyle(color: AppColors.color3)),
          ),
          TextButton(
            onPressed: () async {
              await db.actualizarStatusPago(idUsuario, fecha, 'Confirmado');
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago confirmado exitosamente.')),
              );
              _loadPaymentData(); // Recargar datos después de confirmar
            },
            child: Text('Confirmar', style: TextStyle(color: AppColors.color2)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.color1),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Calendario de Pagos'),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: DateTime.now(),
            eventLoader: (day) {
              final dayString = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
              return paymentData[dayString] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              final selectedDayString = '${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}';
              final selectedPayments = paymentData[selectedDayString];
              if (selectedPayments != null && selectedPayments.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Pago del $selectedDayString', style: AppTextStyles.secondBold()),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: selectedPayments.map((payment) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tipo de pago: ${payment['tipopago']}', style: AppTextStyles.secondRegular(color: AppColors.color2)),
                            Text('Monto: \$${payment['monto']}', style: AppTextStyles.secondRegular(color: AppColors.color2)),
                            const SizedBox(height: 8),
                          ],
                        );
                      }).toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: paymentData.entries
                    .where((entry) {
                      final entryDate = DateTime.parse(entry.key);
                      return entryDate.isBefore(DateTime.now());
                    })
                    .map((entry) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        'Pago del ${entry.key}',
                        style: AppTextStyles.secondBold(color: AppColors.color3),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: entry.value.map((payment) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tipo: ${payment['tipopago']} - Monto: \$${payment['monto']}',
                                style: AppTextStyles.secondMedium(color: AppColors.color2),
                              ),
                              const SizedBox(height: 8),
                              if (payment['status'] != 'Confirmado') // Mostrar botón solo si no está confirmado
                                ElevatedButton(
                                  onPressed: () => _confirmarPago(entry.key, payment),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.color2),
                                  child: Text('Confirmar Pago', style: AppTextStyles.secondRegular(color: AppColors.color1)),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
