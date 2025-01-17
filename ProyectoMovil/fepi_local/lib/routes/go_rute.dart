import 'package:fepi_local/routes/screens.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [

    GoRoute(
      path: '/screen_Inicio_EC',
      name: InicioEC.routeName,
      builder: (context, state) => InicioEC(),
    ),
    GoRoute(
      path: '/screen_Inicio_ECAR',
      name: InicioECAR.routeName,
      builder: (context, state) => InicioECAR(),
    ),
    GoRoute(
      path: '/screen_Inicio_ECA',
      name: InicioECA.routeName,
      builder: (context, state) => InicioECA(),
    ),
    GoRoute(
      path: '/screen_Inicio_APEC',
      name: InicioAPEC.routeName,
      builder: (context, state) => InicioAPEC(),
    ),




    GoRoute(
      path: '/screen_pantalla_pl003_01',
      name: ScreenPantallaPl003_01.routeName,
      builder: (context, state) => ScreenPantallaPl003_01(),
    ),
     GoRoute(
      path: '/screen_pantalla_pl004_01',
      name: ScreenPantallaPl004_01.routeName,
      builder: (context, state) => ScreenPantallaPl004_01(),
    ),
     
     GoRoute(
      path: '/screen_pantalla_pl013_01',
      name: ScreenPantallaPl013_01.routeName,
      builder: (context, state) => ScreenPantallaPl013_01(),
    ),
    GoRoute(
      path: '/screen_pantalla_pl012_01',
      name: DynamicCardsWidget2.routeName,
      builder: (context, state) => DynamicCardsWidget2(),
    ),
    GoRoute(
      path: '/login',
      name: LoginScreen.routeName,
      builder: (context, state) => LoginScreen(),
    ),
    
    GoRoute(
      path: '/screen_pantalla_se00401',
      name: CalificacionesScreen.routeName,
      builder: (contex , state) => CalificacionesScreen(),

    ),
    GoRoute(
      path: '/screen_pantalla_se001',
      name: ScreenPantallaSe001.routeName,
      builder: (contex , state) => ScreenPantallaSe001(),

    ),
    GoRoute(
      path: '/screen_pantalla_se001_02',
      name: ScreenPantallaSe00102.routeName,
      builder: (contex , state) => ScreenPantallaSe00102(),

    ),

    GoRoute(
      path: '/screen_pantalla_eq00301',
      name: ScreenPantallaEq00301.routeName,
      builder: (contex , state) => ScreenPantallaEq00301(),

    ),
    GoRoute(
      path: '/screen_pantalla_se003_01',
      name: SreenPantallaSe003_01.routeName,
      builder: (context, state) => SreenPantallaSe003_01(),
    ),
    GoRoute(
      path: '/screen_pantalla_se003_02',
      name: ScrenPantallaSe00302.routeName,
      builder: (contex , state) => ScrenPantallaSe00302(),

    ),
    GoRoute(
      path: '/screen_pantalla_se003_03',
      name: ScrenPantallaSe00303.routeName,
      builder: (contex , state) => ScrenPantallaSe00303(),

    ),
    GoRoute(
      path: '/screen_pantalla_se002_01',
      name: SreenPantallaSe002_01.routeName,
      builder: (context, state) => SreenPantallaSe002_01(),
    ),
    GoRoute(
      path: '/screen_pantalla_se002_02',
      name: ScrenPantallaSe00202.routeName,
      builder: (contex , state) => ScrenPantallaSe00202(),

    ),
    GoRoute(
      path: '/screen_pantalla_se002_03',
      name: ScrenPantallaSe00203.routeName,
      builder: (contex , state) => ScrenPantallaSe00203(),

    ),
    GoRoute(path: '/screen_pantalla_se006_01',
    name: ScreenPantallaSe006_01.routeName,
    builder: (contex , state) => ScreenPantallaSe006_01(),
    ),
    GoRoute(path: '/screen_pantalla_se006_02',
    name: ScreenPantallaSe006_02.routeName,
    builder: (contex , state) => ScreenPantallaSe006_02(),
    ),
    GoRoute(path: '/screen_pantalla_eq02_02',
    name: FormularioEntrega.routeName,
    builder: (contex , state) => FormularioEntrega()),
    GoRoute(path: '/screen_pantalla_cp003',
    name: ScreenPantallaCp003.routeName,
    builder: (contex , state) => ScreenPantallaCp003()),
    GoRoute(path: '/screen_pantalla_cp004',
    name: ScreenPantallaCp004.routeName,
    builder: (contex , state) => ScreenPantallaCp004()),
    GoRoute(path: '/screen_pantalla_cp004_2',
    name: ScreenPantallaCp0042.routeName,
    builder: (contex , state) => ScreenPantallaCp0042()),
    GoRoute(path: '/screen_pantalla_be002',
    name: ScreenPantallaBe002.routeName,
    builder: (contex , state) => ScreenPantallaBe002()),
    GoRoute(
      path: '/screen_pantalla_cp002',
      name: CapacitationInitialPageECAR.routeName,
      builder: (context, state) => CapacitationInitialPageECAR(),
    ),
    GoRoute(
      path: '/screen_pantalla_cp0021',
      name: CapacitationInitialPageEC.routeName,
      builder: (context, state) => CapacitationInitialPageEC(),
    ),
    GoRoute(path: '/screen_pantalla_pc001',
    name: ScreenPantallaPc001.routeName,
    builder: (context, state) => ScreenPantallaPc001(),
    ),
    GoRoute(path: '/screen_pantalla_pc003_01',
    name: ScreenPantallaPc00301.routeName,
    builder: (context, state) => ScreenPantallaPc00301(),
    )
  ],
);
