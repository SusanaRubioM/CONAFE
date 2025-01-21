import 'package:fepi_local/routes/screens.dart';
import 'package:fepi_local/screens/home_aspirante.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/ScreenPantallaPl003_01',
  routes: [
    GoRoute(
      path: '/ScreenPantallaPl003_01',
      name: ScreenPantallaPl003_01.routeName,
      builder: (context, state) => ScreenPantallaPl003_01(),
    ),
    GoRoute(
      path: '/login',
      name: LoginScreen.routeName,
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/aspirantes_home',
      name: HomeScreenAsp.routeName,
      builder: (context, state) => HomeScreenAsp(),
    ),
    
  
    
  ],
);
