import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/constansts/app_text_styles.dart';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final isVisibleNotifier = ValueNotifier<bool>(false);
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    isVisibleNotifier.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String username = usernameController.text.trim();
      String password = passwordController.text.trim();

      // Llamar a la función verificarLogin desde UsuariosDB
     final dbHelper = DatabaseHelper();
     await dbHelper.database;
      // Esto crea la base de datos si no existe
     var result = await dbHelper.validarUsuario(username, password);

      if (result != null) {
        // Si la verificación es exitosa, guardar id_Usuario y rol en SharedPreferences
        int idUsuario = result['id_Usuario'];
        String rol = result['rol'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id_Usuario', idUsuario); // Guardar id_Usuario
        await prefs.setString('rol', rol); // Guardar rol

        setState(() {
          isLoading = false;
        });

        // Redirigir según el rol del usuario
        if (rol == 'ASPIRANTE') {
          context.go('/screen_pantalla_cp0021');
        } else if (rol == 'EC') {
          context.go('/screen_Inicio_EC');
        } else if (rol == 'ECAR') {
          context.go('/screen_Inicio_ECAR');
        } else if (rol == 'ECA') {
          context.go('/screen_Inicio_ECA');
        } else if (rol == 'APEC') {
          context.go('/screen_Inicio_APEC');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Rol de usuario desconocido', style: AppTextStyles.secondMedium())),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario o contraseña incorrectos', style: AppTextStyles.secondMedium())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.color3,
        child: Stack(
          children: [
            _containerbeige(size),
            _logo(),
            _iconperson(),
            _loginform(context),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView _loginform(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 250),
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 50),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.color1,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.color2,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text('Iniciar sesión',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: usernameController,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: 'Usuario',
                          labelText: 'Ingrese su usuario',
                          icon: Icon(Icons.supervised_user_circle),
                        ),
                        validator: (value) {
                          return (value == null || value.isEmpty)
                              ? "El usuario es obligatorio"
                              : null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ValueListenableBuilder<bool>( 
                        valueListenable: isVisibleNotifier,
                        builder: (context, isVisible, child) {
                          return TextFormField(
                            controller: passwordController,
                            autocorrect: false,
                            obscureText: !isVisible,
                            decoration: InputDecoration(
                              hintText: '*****',
                              labelText: 'Contraseña',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  isVisibleNotifier.value =
                                      !isVisibleNotifier.value;
                                },
                                icon: Icon(isVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                              icon: const Icon(Icons.lock_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "La contraseña es obligatoria";
                              } else if (value.length < 6) {
                                return "La contraseña debe tener al menos 6 caracteres";
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.color3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Ingresar',
                          style: TextStyle(color: AppColors.color1),
                        ),
                        onPressed: isLoading ? null : _login,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 50),
          const Text(
            '© 2024 Equipo uno. todos los derechos reservados.',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  SafeArea _iconperson() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        width: double.infinity,
        child: const Icon(
          Icons.person_pin,
          color: AppColors.color2,
          size: 100,
        ),
      ),
    );
  }

  Positioned _logo() {
    return Positioned(
      top: 1,
      right: 10,
      child: Image.asset(
        'lib/assets/logo.png',
        width: 120,
        height: 120,
      ),
    );
  }

  Container _containerbeige(Size size) {
    return Container(
      color: AppColors.color4,
      width: double.infinity,
      height: size.height * 0.4,
    );
  }
}
