import 'package:fepi_local/JsonModels/users.dart';
import 'package:fepi_local/constansts/app_colors.dart';
import 'package:fepi_local/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  LoginScreen({Key? key}) : super(key: key);
  

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final isVisibleNotifier = ValueNotifier<bool>(false);
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final DatabaseHelper dbHelper = DatabaseHelper();

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

      Users user = Users(
        usrName: usernameController.text.trim(),
        usrPassword: passwordController.text.trim(),
      );

      bool loginSuccess = await dbHelper.login(user);

      setState(() {
        isLoading = false;
      });

      if (loginSuccess) {
        context.go('/aspirantes_home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario o contraseña incorrectos')),
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
            containerbeige(size),
            logo(),
            iconperson(),
            loginform(context),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView loginform(BuildContext context) {
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

                      // Campo de contraseña con ValueListenableBuilder
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

  SafeArea iconperson() {
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

  Positioned logo() {
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

  Container containerbeige(Size size) {
    return Container(
      color: AppColors.color4,
      width: double.infinity,
      height: size.height * 0.4,
    );
  }
}


