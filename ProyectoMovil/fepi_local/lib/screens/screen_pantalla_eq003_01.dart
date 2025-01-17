import 'package:fepi_local/constansts/app_buttons.dart';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:fepi_local/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class ScreenPantallaEq00301 extends StatefulWidget {
  static const String routeName = '/screen_pantalla_eq00301';
  const ScreenPantallaEq00301({super.key});

  @override
  _ScreenPantallaEq00301State createState() => _ScreenPantallaEq00301State();
}

class _ScreenPantallaEq00301State extends State<ScreenPantallaEq00301> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _formulariosMobiliario = [];
  Map<String, String> _periodoEscolar = {'Inicio': 'Cargando...', 'Fin': 'Cargando...'}; // Map con periodo escolar
  bool _registroExitoso = false;

  // Lista para almacenar los datos del mobiliario
  List<Map<String, dynamic>> _datosMobiliarioGuardados = [];

  String? _fechaRM1;
  String? _fechaRM2;

  @override
  void initState() {
    super.initState();
    // Llamamos a la función para obtener las fechas de inicio y fin del ciclo escolar
    _obtenerFechasCicloEscolar();
    // Llamamos a la función para obtener las fechas RM1 y RM2
    _obtenerFechasRM();
  }

  // Función para obtener las fechas de inicio y fin del ciclo escolar
  Future<void> _obtenerFechasCicloEscolar() async {
    final inicioCiclo = await DatabaseHelper().obtenerFechaEventoPorNombre('InicioCiclo');
    final finCiclo = await DatabaseHelper().obtenerFechaEventoPorNombre('FinCiclo');
    
    setState(() {
      _periodoEscolar = {
        'Inicio': inicioCiclo.isNotEmpty ? inicioCiclo['fecha']! : 'No disponible',
        'Fin': finCiclo.isNotEmpty ? finCiclo['fecha']! : 'No disponible'
      };
    });
  }

  // Función para obtener las fechas RM1 y RM2
  Future<void> _obtenerFechasRM() async {
    final fechaRM1 = await DatabaseHelper().obtenerFechaEventoPorNombre('registro_moviliario');
    final fechaRM2 = await DatabaseHelper().obtenerFechaEventoPorNombre('fin_registro_moviliario');

    setState(() {
      _fechaRM1 = fechaRM1.isNotEmpty ? fechaRM1['fecha']! : null;
      _fechaRM2 = fechaRM2.isNotEmpty ? fechaRM2['fecha']! : null;
    });
  }

  // Función para agregar formulario si la fecha actual es igual a RM1 o RM2
  // Función para agregar formulario si la fecha actual está dentro del rango entre RM1 y RM2
void _agregarFormulario() {
  final currentDate = DateTime.now();

  // Validar que las fechas RM1 y RM2 estén definidas
  if (_fechaRM1 == null || _fechaRM2 == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Las fechas de registro no están definidas.')),
    );
    return;
  }

  // Convertir las fechas a objetos DateTime
  final rm1Date = DateTime.parse(_fechaRM1!);
  final rm2Date = DateTime.parse(_fechaRM2!);

  // Verificar si la fecha actual está dentro del rango permitido
  if (currentDate.isAfter(rm1Date) && currentDate.isBefore(rm2Date) || currentDate.isAtSameMomentAs(rm1Date) || currentDate.isAtSameMomentAs(rm2Date)) {
    setState(() {
      _formulariosMobiliario.add({
        'nombre': '',
        'cantidad': 0,
        'condicion': 'Nuevo',
        'comentarios': '',
        'periodo': currentDate.toIso8601String().split('T')[0], // Formato AAAA-MM-DD
      });
    });
  } else {
    // Mostrar un mensaje si la fecha actual no está dentro del rango permitido
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se puede agregar mobiliario fuera del periodo permitido.')),
    );
  }
}


  void _eliminarFormulario(int index) {
    setState(() {
      _formulariosMobiliario.removeAt(index);
    });
  }

  // Función para registrar los datos y almacenarlos
  void _registrarMobiliarios() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Guardamos los datos en la lista _datosMobiliarioGuardados
      setState(() {
        _datosMobiliarioGuardados.addAll(_formulariosMobiliario);
      });

      // Llamamos a la función para insertar los datos en la base de datos
      try {
        await DatabaseHelper().insertarDatosEnRegistroMoviliario(_datosMobiliarioGuardados);
        setState(() {
          _registroExitoso = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todos los registros se enviaron correctamente.')),
        );
      } catch (e) {
        // Si ocurre un error durante la inserción
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al insertar los datos: $e')),
        );
      }

      // Limpiar los formularios después de enviarlos
      setState(() {
        _formulariosMobiliario.clear();
        _datosMobiliarioGuardados.clear(); // Limpiar los datos guardados
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.color1),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text('REGISTRO DE MOBILIARIO POR EC'),
        titleTextStyle: AppTextStyles.primaryRegular(color: AppColors.color1),
        backgroundColor: AppColors.color3,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Periodo Escolar: ${_periodoEscolar['Inicio']} - ${_periodoEscolar['Fin']}',
              style: AppTextStyles.secondMedium(color: AppColors.color2),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView.builder(
                  itemCount: _formulariosMobiliario.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: AppColors.color1,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mobiliario',
                                  style: AppTextStyles.secondRegular(color: AppColors.color3),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.color3),
                                  onPressed: () => _eliminarFormulario(index),
                                ),
                              ],
                            ),
                            TextFormField(
                              decoration: AppButtons.textFieldStyle(labelText: 'Nombre del mobiliario'),
                              onSaved: (value) => _formulariosMobiliario[index]['nombre'] = value!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, ingrese el nombre del mobiliario.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              decoration: AppButtons.textFieldStyle(
                                labelText: 'Cantidad de unidades',
                              ),
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _formulariosMobiliario[index]['cantidad'] = int.parse(value!),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, ingrese la cantidad de unidades.';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Ingrese un número válido.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              decoration: AppButtons.dropdownButtonStyle(
                                labelText: 'Condición del mobiliario',
                              ),
                              value: _formulariosMobiliario[index]['condicion'],
                              items: const [
                                DropdownMenuItem(
                                  value: 'Nuevo',
                                  child: Text('Nuevo'),
                                ),
                                DropdownMenuItem(
                                  value: 'Usado',
                                  child: Text('Usado'),
                                ),
                                DropdownMenuItem(
                                  value: 'Dañado',
                                  child: Text('Dañado'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _formulariosMobiliario[index]['condicion'] = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              decoration: AppButtons.textFieldStyle(
                                labelText: 'Comentarios adicionales (opcional)',
                              ),
                              onSaved: (value) => _formulariosMobiliario[index]['comentarios'] = value,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _agregarFormulario,
                  style: AppButtons.btnFORM(backgroundColor: AppColors.color2),
                  child: Text('Agregar Mobiliario', style: AppTextStyles.secondRegular(color: AppColors.color1, fontSize: 10)),
                ),
                ElevatedButton(
                  onPressed: _registrarMobiliarios,
                  style: AppButtons.btnFORM(backgroundColor: AppColors.color3),
                  child: Text('Enviar Todo', style: AppTextStyles.secondRegular(color: AppColors.color1, fontSize: 10)),
                ),
              ],
            ),
            if (_registroExitoso)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    '¡Todos los registros se enviaron correctamente!',
                    style: AppTextStyles.primaryRegular(color: Colors.green),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
