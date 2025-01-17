import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:fepi_local/routes/getSavedPreferences.dart';
import 'package:mysql1/mysql1.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'Conafe.db');

    // Si la base de datos no existe, la crea
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Método que crea las tablas
  Future<void> _onCreate(Database db, int version) async {
    await _createAlumnosTable(db);
    await _createRegionTable(db);
    await _createMicroregionTable(db);
    await _createComunidadTable(db);
    await _createCCTTable(db);
    await _CreateRegionAsignada(db);
    await _CreateMicroregionAsignada(db);
    await _CreateCCTAsignado(db);
    await _createUsuariosTable(db);
    await _createDependenciasTable(db);
    await _createDatosUsuariosTable(db);
    await _createReportesTable(db);
    await _createActividadAcompTable(db);
    await _createReportesAcompTable(db);
    await _createAsistenciaTable(db);
    await _createGruposTable(db);
    await _createAsignacionGruposTable(db);
    await _createAsignacionMaestrosTable(db);
    await _createMateriasTable(db);
    await _createCalificacionesTable(db);
    await _createPromocionAlumnosTable(db);
    await _createRegistroMoviliarioTable(db);
    await _createReciboTable(db);
    await _createActCAPTable(db);
    await _createPromocionFechasTable(db);
    await _createFechasPagoTable(db);
    await _createSolicitudEducadoresTable(db);
    await _createCalendarioDECBTable(db);
    //await insertMassiveDataForAllTables();
    //await printAllTables();
  }

  Future<void> _createMateriasTable(Database db) async {
  await db.execute('''
    CREATE TABLE Materias (
      id_Materia INTEGER PRIMARY KEY AUTOINCREMENT,
      Grado TEXT,
      Nivel TEXT,
      Nombre TEXT
    );
  ''');
}

  Future<void> _createGruposTable(Database db) async {
  await db.execute('''
    CREATE TABLE Grupos (
      id_Grupo INTEGER PRIMARY KEY AUTOINCREMENT,
      Nivel TEXT,
      Grado TEXT
    );
  ''');
}

  
  Future<void> _createAsignacionGruposTable(Database db) async {
  await db.execute('''
    CREATE TABLE AsignacionGrupos (
      id_AsignacionGrupo INTEGER PRIMARY KEY AUTOINCREMENT,
      id_Grupo INTEGER,
      id_Alumno INTEGER,
      FOREIGN KEY (id_Alumno) REFERENCES Alumnos(id_Alumno)
    );
  ''');
}

  Future<void> _createAsignacionMaestrosTable(Database db) async {
  await db.execute('''
    CREATE TABLE AsignacionMaestro (
      id_AsignacionMaestro INTEGER PRIMARY KEY AUTOINCREMENT,
      id_Grupo INTEGER,
      id_Maestro INTEGER,
      FOREIGN KEY (id_Grupo) REFERENCES Grupos(id_Grupo),
      FOREIGN KEY (id_Maestro) REFERENCES Usuarios(id_Usuario)
    );
  ''');
}

  Future<void> _createAlumnosTable(Database db) async {
    await db.execute('''
      CREATE TABLE Alumnos (
        id_Alumno INTEGER PRIMARY KEY AUTOINCREMENT,
        actaNacimiento BLOB, -- Archivo PDF
        curp TEXT,
        fechaNacimiento TEXT,
        lugarNacimiento TEXT,
        domicilio TEXT,
        municipio TEXT,
        estado TEXT,
        certificadoEstudios BLOB, -- Archivo PDF
        nombrePadre TEXT,
        ocupacionPadre TEXT,
        telefonoPadre TEXT,
        fotoVacunacion BLOB, -- Imagen
        state TEXT,
        nota TEXT,
      );
    ''');
  }

Future<void> _createPromocionAlumnosTable(Database db) async {
  await db.execute('''
    CREATE TABLE PromocionesAlumnos (
      id_PromocionAlumno INTEGER PRIMARY KEY AUTOINCREMENT,
      id_Alumno INTEGER,
      calfFinal INTEGER,
      tipoPromocion TEXT,
      Grado TEXT,
      Nivel TEXT,
      FOREIGN KEY (id_Alumno) REFERENCES Alumnos(id_Alumno)
    );
  ''');
}


  Future<void> _createCalificacionesTable(Database db) async {
    await db.execute('''
      CREATE TABLE Calificaciones (
        id_Calf INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Alumno INTEGER,
        calificacion INTEGER,
        id_Materia INTEGER,
        FOREIGN KEY (id_Materia) REFERENCES Materias(id_Materia),
        FOREIGN KEY (id_Alumno) REFERENCES Alumnos(id_Alumno)
      );
    ''');
  }




  Future<void> _createRegionTable(Database db) async {
    await db.execute('''
      CREATE TABLE Region (
        id_Region INTEGER PRIMARY KEY AUTOINCREMENT,
        Nombre TEXT
      );
    ''');
  }
  Future<void> _createMicroregionTable(Database db) async {
    await db.execute('''
      CREATE TABLE Microrregion (
        id_Microregion INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Region INTEGER,
        Nombre TEXT,
        FOREIGN KEY (id_Region) REFERENCES Region(id_Region)
      );
    ''');
  }

  Future<void> _createComunidadTable(Database db) async {
    await db.execute('''
      CREATE TABLE Comunidad (
        id_Comunidad INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Microregion INTEGER,
        Nombre TEXT,
        FOREIGN KEY (id_Microregion) REFERENCES Microrregion(id_Microregion)
      );
    ''');
  }

  Future<void> _createCCTTable(Database db) async{
    await db.execute('''
      CREATE TABLE CCT (
        id_CCT INTEGER PRIMARY KEY AUTOINCREMENT,
        claveCCT TEXT,
        id_Comunidad INTEGER,
        tipo_Servicio TEXT,
        Nombre TEXT
      );
    ''');
  }
  

  Future<void> _createUsuariosTable(Database db) async {
    await db.execute('''
      CREATE TABLE Usuarios (
        id_Usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT,
        password TEXT,
        rol TEXT
      );
    ''');
  }

  Future<void> _CreateCCTAsignado(Database db) async{
    await db.execute('''
      CREATE TABLE CCTAsignado (
        id_ACCT INTEGER PRIMARY KEY AUTOINCREMENT,
        id_CCT INTEGER,
        id_Usuario INTEGER,
        FOREIGN KEY (id_CCT) REFERENCES CCT(id_CCT),
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
      );
    ''');
  }
  Future<void> _CreateMicroregionAsignada(Database db) async{
    await db.execute('''
      CREATE TABLE MicroRegionAsignada (
        id_MicroRegionAsignada INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Microregion INTEGER,
        id_Usuario INTEGER,
        FOREIGN KEY (id_Microregion) REFERENCES Microregion(id_Microregion),
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
      );
    ''');
  }
  Future<void> _CreateRegionAsignada(Database db) async{
    await db.execute('''
      CREATE TABLE RegionAsignada (
        id_RegionAsignada INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Region INTEGER,
        id_Usuario INTEGER,
        FOREIGN KEY (id_Region) REFERENCES Microregion(id_Region),
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
      );
    ''');
  }


  Future<void> _createDatosUsuariosTable(Database db) async {
    await db.execute('''
      CREATE TABLE DatosUsuarios (
        id_Datos INTEGER PRIMARY KEY AUTOINCREMENT,
        nombreCompleto TEXT,
        situacion_Educativa TEXT,
        contexto TEXT,
        nivel TEXT,
        Estado BOOLEAN
      );
    ''');
  }

  Future<void> _createDependenciasTable(Database db) async {
    await db.execute('''
      CREATE TABLE Dependencias (
        id_Dependencias INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Dependiente INTEGER,
        id_Responsable INTEGER,
        FOREIGN KEY (id_Dependiente) REFERENCES Usuarios(id_Usuario),
        FOREIGN KEY (id_Responsable) REFERENCES Usuarios(id_Usuario)
      );
    ''');
  }

  

  Future<void> _createReportesTable(Database db) async {
    await db.execute('''
      CREATE TABLE Reportes (
        id_Reporte INTEGER PRIMARY KEY AUTOINCREMENT,
        periodo TEXT,
        estado TEXT,
        reporte BLOB,
        id_usuario INTEGER,
        FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_Usuario)
      );
    ''');
  }

  Future<void> _createActividadAcompTable(Database db) async {
    await db.execute('''
      CREATE TABLE ActividadAcomp (
        id_ActividadAcomp INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Usuario INTEGER,
        fecha DATE,
        hora TIME,
        id_Figura TEXT,
        descripcion TEXT,
        estado TEXT,
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario),
        FOREIGN KEY (id_Figura) REFERENCES Usuarios(id_Usuario)
      );
    ''');
  }

  Future<void> _createReportesAcompTable(Database db) async {
    await db.execute('''
      CREATE TABLE ReportesAcomp (
        id_ReporteAcomp INTEGER PRIMARY KEY AUTOINCREMENT,
        reporte BLOB,
        id_ActividadAcomp INTEGER,
        fecha DATE,
        figuraEducativa TEXT,
        id_Usuario INTEGER,
        FOREIGN KEY (id_ActividadAcomp) REFERENCES ActividadAcomp(id_ActividadAcomp),
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
      );
    ''');
  }

  Future<void> _createAsistenciaTable(Database db) async {
    await db.execute('''
      CREATE TABLE Asistencia (
        id_Asistencia INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Profesor INTEGER,
        fecha DATE,
        usuario TEXT,
        horaEntrada TIME,
        horaSalida TIME,
        Asistencia BOOLEAN,
        FOREIGN KEY (id_Profesor) REFERENCES Usuarios(id_Usuario)
      );
    ''');
  }

  

  Future<void> _createRegistroMoviliarioTable(Database db) async {
    await db.execute('''
      CREATE TABLE RegistroMoviliario (
        id_RMoviliario INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Comunidad INTEGER,
        nombre TEXT,
        cantidad INTEGER,
        condicion TEXT,
        comentarios TEXT,
        periodo TEXT,
        id_Usuario INTEGER,
        FOREIGN KEY (id_Comunidad) REFERENCES Comunidad(id_Comunidad),
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
      );
    ''');
  }

  Future<void> _createReciboTable(Database db) async {
    await db.execute('''
      CREATE TABLE Recibo (
        id_Recibo INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Usuario INTEGER,
        recibo BLOB,
        tipoRecibo TEXT,
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
      );
  }

    ''');
    
    }
  Future<void> _createActCAPTable(Database db) async {
    await db.execute('''
      CREATE TABLE ActCAP (
        id_ActCAP INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Usuario INTEGER,
        NumCapacitacion INTEGER,
        TEMA TEXT,
        id_Region INTEGER,
        id_Microregion INTEGER,
        id_CCT INTEGER,
        FechaProgramada DATE,
        Estado TEXT,
        Reporte BLOB,
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
      );
    ''');
  }

  Future<void> _createPromocionFechasTable(Database db) async {
    await db.execute('''
      CREATE TABLE PromocionFechas (
        id_PromoFechas INTEGER PRIMARY KEY AUTOINCREMENT,
        promocionPDF BLOB,
        fechas TEXT
      );
    ''');
  }

  Future<void> _createFechasPagoTable(Database db) async {
    await db.execute('''
      CREATE TABLE PagosFechas (
        id_PagoFecha INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha DATE,
        tipoPago TEXT,
        monto real,
        id_Usuario INTEGER,
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario) 
      );
    ''');
  }

  Future<void> _createSolicitudEducadoresTable(Database db) async {
    await db.execute('''
      CREATE TABLE SolicitudEducadores (
        id_SolicitudEducadores INTEGER PRIMARY KEY AUTOINCREMENT,
        nombreEscuela TEXT,
        id_CCT,
        tipoServicio TEXT,
        periodo TEXT,
        numEducadores INTEGER,
        justificacion TEXT,
        contexto TEXT,
        estado TEXT,
        educadoresAsignados INT,
        id_Usuario INTEGER,
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario) 
      );
    ''');
  }

  Future<void> _createCalendarioDECBTable(Database db) async {
    await db.execute('''
      CREATE TABLE CalendarioDECB (
        id_CalendarioDECB INTEGER PRIMARY KEY AUTOINCREMENT,
        evento TEXT,
        fecha DATE
      );
    ''');
  }

  
   
  



































    

  Future<void> printAllTables() async {
    final db= await database;
    // Obtener el nombre de todas las tablas en la base de datos
    List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';");

    for (var table in tables) {
      String tableName = table['name'];

      // Obtener los registros de la tabla
      List<Map<String, dynamic>> rows = await db.query(tableName);

      print('=== Tabla: $tableName ===');
      if (rows.isEmpty) {
        print('No hay datos en esta tabla.');
      } else {
        for (var row in rows) {
          print(row);
        }
      }
      print('\n');
    }
  }


























  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///
  ///
  Future<void> insertarDatosEnRegistroMoviliario(
  List<Map<String, dynamic>> datosMobiliario,
) async {
  final prefs = await getSavedPreferences();
  final idUsuario = prefs['id_Usuario'] ?? 0;
  final db = await DatabaseHelper().database; // Obtenemos la referencia a la base de datos

  // Obtener el id_CCT del usuario a través de la tabla CCTAsignado
  final List<Map<String, dynamic>> cctResult = await db.rawQuery(''' 
    SELECT c.id_CCT
    FROM CCTAsignado ca
    INNER JOIN CCT c ON ca.id_CCT = c.id_CCT
    WHERE ca.id_Usuario = ?
  ''', [idUsuario]);

  // Si no encontramos un CCT asignado al usuario, lanzamos una excepción o retornamos
  if (cctResult.isEmpty) {
    throw Exception('No se encontró el CCT asociado al usuario.');
  }

  // Obtenemos el id_CCT
  final idCCT = cctResult[0]['id_CCT'];

  // Recorremos cada uno de los elementos del listado y los insertamos en la tabla
  for (var mobiliario in datosMobiliario) {
    await db.insert(
      'RegistroMoviliario', // Nombre de la tabla
      {
        'id_Comunidad': idCCT, // Usamos el id_CCT obtenido
        'nombre': mobiliario['nombre'], // Nombre del mobiliario
        'cantidad': mobiliario['cantidad'], // Cantidad de unidades
        'condicion': mobiliario['condicion'], // Condición del mobiliario
        'comentarios': mobiliario['comentarios'], // Comentarios adicionales
        'periodo': mobiliario['periodo'], // Periodo escolar
        'id_Usuario': idUsuario, // Id del usuario
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // En caso de conflicto, reemplazar
    );
  }

  print('Datos de mobiliario insertados correctamente.');
}

Future<Map<String, String>> obtenerFechaEventoPorNombre(String nombreEvento) async {
  final db= await database;
  // Realizamos la consulta para obtener el evento y su fecha
  final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT evento, fecha
    FROM CalendarioDECB
    WHERE evento = ?
  ''', [nombreEvento]);

  if (result.isEmpty) {
    // Si no se encuentra el evento, retornamos un mapa vacío
    return {};
  }

  // Si encontramos el evento, devolvemos el nombre y la fecha en un mapa
  return {
    'nombre': result[0]['evento'],
    'fecha': result[0]['fecha'],
  };
}


Future<List<Map<String, dynamic>>> obtenerColegiadosPorUsuario(int idUsuario) async {
  final db = await database;

  // Obtener el rol del usuario
  final List<Map<String, dynamic>> usuarioResult = await db.rawQuery('''
    SELECT rol 
    FROM Usuarios 
    WHERE id_Usuario = ? 
  ''', [idUsuario]);

  if (usuarioResult.isEmpty) {
    return []; // Retorna lista vacía si el usuario no existe
  }

  final String rolUsuario = usuarioResult[0]['rol'];

  // Determinar región y microrregión asignadas
  String? idRegion;
  String? idMicrorregion;

  // Intentar obtener región asignada
  final List<Map<String, dynamic>> regionResult = await db.rawQuery('''
    SELECT r.cv_region 
    FROM RegionAsignada ra
    INNER JOIN Region r ON ra.id_Region = r.cv_region
    WHERE ra.id_Usuario = ?
  ''', [idUsuario]);

  if (regionResult.isEmpty) {
    // Intentar obtener microrregión asignada
    final List<Map<String, dynamic>> microrregionResult = await db.rawQuery('''
      SELECT mra.id_Microregion, mr.id_Region
      FROM MicroregionAsignada mra
      INNER JOIN Microrregion mr ON mra.id_Microregion = mr.cv_microrregion
      WHERE mra.id_Usuario = ?
    ''', [idUsuario]);

    if (microrregionResult.isNotEmpty) {
      idMicrorregion = microrregionResult[0]['id_Microregion'];
      idRegion = microrregionResult[0]['id_Region'];
    } else {
      // Intentar obtener CCT asignado
      final List<Map<String, dynamic>> cctResult = await db.rawQuery('''
        SELECT c.microrregion_id, mr.id_Region
        FROM CCTAsignado ca
        INNER JOIN CCT c ON ca.id_CCT = c.id_CCT
        INNER JOIN Microrregion mr ON c.microrregion_id = mr.cv_microrregion
        WHERE ca.id_Usuario = ?
      ''', [idUsuario]);

      if (cctResult.isNotEmpty) {
        idMicrorregion = cctResult[0]['microrregion_id'];
        idRegion = cctResult[0]['id_Region'];
      }
    }
  } else {
    idRegion = regionResult[0]['cv_region'];
  }

  // Si no se encontró región o microrregión asociada, retorna lista vacía
  if (idRegion == null && idMicrorregion == null) {
    return [];
  }

  // Configurar filtros según el rol
  String filtroRol;
  String filtroRegion = '';
  String filtroMicrorregion = '';
  List<dynamic> parametros = [];

  if (rolUsuario == 'EC' || rolUsuario == 'APEC') {
    filtroRol = "u.rol = 'ECA'";
    filtroMicrorregion = "ac.id_Microregion = ?";
    parametros.add(idMicrorregion);
  } else if (rolUsuario == 'ECA') {
    filtroRol = "u.rol = 'ECAR'";
    filtroMicrorregion = "ac.id_Microregion = ?";
    parametros.add(idMicrorregion);
  } else if (rolUsuario == 'ECAR') {
    filtroRol = "u.rol = 'ECA'";
    filtroRegion = "ac.id_Region = ?";
    parametros.add(idRegion);
  } else {
    return []; // Si el rol no es válido, retorna lista vacía
  }

  // Construir consulta SQL con los filtros configurados
  final String consultaSQL = '''
    SELECT 
      ac.id_ActCAP, 
      ac.NumCapacitacion, 
      ac.TEMA, 
      ac.FechaProgramada, 
      ac.Estado, 
      ac.Reporte, 
      m.Nombre AS Microrregion,
      r.Nombre AS Region,
      u.rol AS CreadorRol
    FROM ActCAP ac
    LEFT JOIN Microrregion m ON ac.id_Microregion = m.cv_microrregion
    LEFT JOIN Region r ON ac.id_Region = r.cv_region
    INNER JOIN Usuarios u ON ac.id_Usuario = u.id_Usuario
    WHERE $filtroRol
      ${filtroRegion.isNotEmpty ? 'AND ' + filtroRegion : ''}
      ${filtroMicrorregion.isNotEmpty ? 'AND ' + filtroMicrorregion : ''}
  ''';

  // Ejecutar consulta SQL
  final List<Map<String, dynamic>> actividadesResult = await db.rawQuery(consultaSQL, parametros);

  // Si no hay actividades, retorna lista vacía
  if (actividadesResult.isEmpty) {
    return [];
  }

  // Transformar resultados
  return actividadesResult.map((actividad) {
    return {
      'id_ActCAP': actividad['id_ActCAP'],
      'NumCapacitacion': actividad['NumCapacitacion'],
      'TEMA': actividad['TEMA'],
      'FechaProgramada': actividad['FechaProgramada'],
      'Estado': actividad['Estado'],
      'Reporte': actividad['Reporte'],
      'Microrregion': actividad['Microrregion'],
      'Region': actividad['Region'],
      'CreadorRol': actividad['CreadorRol'],
    };
  }).toList();
}


Future<List<Map<String, dynamic>>> leerDatosDeTabla(String nombreTabla) async {
  final db = await database;

  try {
    // Verifica que la tabla exista en la base de datos
    final tablas = await db.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND name=?
    ''', [nombreTabla]);

    if (tablas.isEmpty) {
      throw Exception('La tabla $nombreTabla no existe en la base de datos.');
    }

    // Realiza la consulta a la tabla
    final List<Map<String, dynamic>> datos = await db.query(nombreTabla);

    return datos;
  } catch (e) {
    print('Error al leer datos de la tabla $nombreTabla: $e');
    return [];
  }
}











Future<List<Map<String, dynamic>>> obtenerEstructuraRegion(int idUsuario) async {
  final db = await DatabaseHelper().database;
  try {
    // Intentamos obtener la región asignada directamente al usuario
    final List<Map<String, dynamic>> regiones = await db.rawQuery(''' 
      SELECT r.cv_region AS RegionId, r.Nombre AS RegionNombre
      FROM RegionAsignada ra
      INNER JOIN Region r ON ra.id_Region = r.cv_region
      WHERE ra.id_Usuario = ?
    ''', [idUsuario]);

    Object? idRegion;
    String? regionNombre;

    // Si no tiene región asignada, intentamos obtener la microrregión
    if (regiones.isEmpty) {
      final List<Map<String, dynamic>> microrregionResult = await db.rawQuery(''' 
        SELECT mr.id_Region, mr.Nombre AS RegionNombre
        FROM MicroregionAsignada mra
        INNER JOIN Microrregion mr ON mra.id_Microregion = mr.cv_microrregion
        WHERE mra.id_Usuario = ?
      ''', [idUsuario]);

      if (microrregionResult.isEmpty) {
        return []; // Retorna lista vacía si no hay datos
      }

      idRegion = microrregionResult[0]['id_Region'];
      regionNombre = microrregionResult[0]['RegionNombre'];

      // Obtener microrregiones relacionadas con el usuario
      final List<Map<String, dynamic>> microrregiones = await db.rawQuery('''
        SELECT mr.cv_microrregion AS MicrorregionId, mr.Nombre AS MicroregionNombre
        FROM Microrregion mr
        WHERE mr.id_Region = ? AND mr.cv_microrregion IN (
          SELECT id_Microregion FROM MicroregionAsignada WHERE id_Usuario = ?
        )
      ''', [idRegion, idUsuario]);

      List<Map<String, dynamic>> microrregionesConCCT = [];

      for (var microrregion in microrregiones) {
        final String idMicroregion = microrregion['MicrorregionId'];

        final List<Map<String, dynamic>> ccts = await db.rawQuery('''
          SELECT c.id_CCT AS CCTId, c.Nombre AS CCTNombre
          FROM CCT c
          WHERE c.microrregion_id = ?
        ''', [idMicroregion]);

        microrregionesConCCT.add({
          'MicrorregionId': idMicroregion,
          'Microrregion': microrregion['MicroregionNombre'],
          'CCTs': ccts.map((cct) => {
            'CCTId': cct['CCTId'],
            'CCTNombre': cct['CCTNombre'],
          }).toList(),
        });
        print(microrregionesConCCT);
      }
      print('Microrregion<<<');
      return [
        {
          'RegionId': idRegion,
          'Region': regionNombre,
          'Microrregiones': microrregionesConCCT,
        }
      ];
    }

    // Si tiene región asignada, obtenemos datos relacionados
    List<Map<String, dynamic>> resultado = [];

    for (var region in regiones) {
      final String idRegion = region['RegionId'];
      final String regionNombre = region['RegionNombre'];

      final List<Map<String, dynamic>> microrregiones = await db.rawQuery('''
        SELECT mr.cv_microrregion AS MicrorregionId, mr.Nombre AS MicroregionNombre
        FROM Microrregion mr
        WHERE mr.id_Region = ?
      ''', [idRegion]);

      List<Map<String, dynamic>> microrregionesConCCT = [];

      for (var microrregion in microrregiones) {
        final String idMicroregion = microrregion['MicrorregionId'];

        final List<Map<String, dynamic>> ccts = await db.rawQuery('''
          SELECT c.id_CCT AS CCTId, c.Nombre AS CCTNombre
          FROM CCT c
          WHERE c.microrregion_id = ?
        ''', [idMicroregion]);

        microrregionesConCCT.add({
          'MicrorregionId': idMicroregion,
          'Microrregion': microrregion['MicroregionNombre'],
          'CCTs': ccts.map((cct) => {
            'CCTId': cct['CCTId'],
            'CCTNombre': cct['CCTNombre'],
          }).toList(),
        });
      }
      print ('Region<<<<<');
      resultado.add({
        'RegionId': idRegion,
        'Region': regionNombre,
        'Microrregiones': microrregionesConCCT,
      });
    }

    return resultado;
  } catch (e) {
    print('Error al obtener la estructura de región: $e');
    return [];
  }
}








  Future<void> insertarSolicitudEducadores({
  required int idUsuario,
  required Map<String, dynamic> datosSolicitud,
}) async {
  final db = await DatabaseHelper().database;

  // Obtener el id_CCT, el nombre de la escuela y el tipo de servicio relacionados con el id_Usuario
  final resultado = await db.rawQuery('''
    SELECT CCT.id_CCT, CCT.Nombre as nombreEscuela, CCT.tipo_Servicio as tipoServicio
    FROM CCTAsignado
    INNER JOIN CCT ON CCTAsignado.id_CCT = CCT.id_CCT
    WHERE CCTAsignado.id_Usuario = ?
  ''', [idUsuario]);

  if (resultado.isEmpty) {
    throw Exception('No se encontró información del CCT para el usuario.');
  }

  final idCCT = resultado.first['id_CCT'];
  final nombreEscuela = resultado.first['nombreEscuela'] as String;
  final tipoServicio = resultado.first['tipoServicio'] as String;

  // Insertar datos en la tabla SolicitudEducadores
  await db.insert('SolicitudEducadores', {
    'nombreEscuela': nombreEscuela,
    'id_CCT': idCCT,
    'tipoServicio': tipoServicio, // Usar tipoServicio obtenido de CCT
    'periodo': datosSolicitud['periodo'],
    'numEducadores': datosSolicitud['numEducadores'],
    'justificacion': datosSolicitud['justificacion'],
    'contexto': datosSolicitud['contexto'],
    'estado': datosSolicitud['estado'],
    'educadoresAsignados': datosSolicitud['educadoresAsignados'] ?? 0,
    'id_Usuario': idUsuario,
  });
}


Future<List<Map<String, dynamic>>> obtenerSolicitudesEducadores({
  required int idUsuario,
}) async {
  final db = await DatabaseHelper().database;

  // Consultar la tabla SolicitudEducadores por id_Usuario
  final resultado = await db.query(
    'SolicitudEducadores',
    where: 'id_Usuario = ?',
    whereArgs: [idUsuario],
  );

  return resultado;
}


  Future<void> actualizarEstadoReporte(int idReporte, String nuevoEstado) async {
  final db = await DatabaseHelper().database;

  // Validar entrada
  if (nuevoEstado.isEmpty) {
    throw Exception("El estado no puede estar vacío");
  }

  try {
    final int count = await db.update(
      'Reportes',
      {'estado': nuevoEstado}, // Valores a actualizar
      where: 'id_Reporte = ?', // Condición
      whereArgs: [idReporte],  // Argumentos de la condición
    );

    if (count == 0) {
      throw Exception("No se encontró el reporte con id_Reporte: $idReporte");
    }
    print("Estado del reporte actualizado correctamente.");
  } catch (e) {
    print("Error al actualizar el estado del reporte: $e");
    rethrow;
  }
}

  Future<Map<String, String>> obtenerNombreUsuarioYClaveCCT(int idUsuario) async {
  final db = await DatabaseHelper().database; // Conexión a la base de datos

  // Consulta SQL para obtener el nombre del usuario y la clave CCT
  final result = await db.rawQuery('''
    SELECT 
      DatosUsuarios.nombreCompleto AS nombreUsuario,
      CCT.claveCCT
    FROM Usuarios
    INNER JOIN DatosUsuarios ON Usuarios.id_Datos = DatosUsuarios.id_Datos
    INNER JOIN CCTAsignado ON CCTAsignado.id_Usuario = Usuarios.id_Usuario
    INNER JOIN CCT ON CCT.id_CCT = CCTAsignado.id_CCT
    WHERE Usuarios.id_Usuario = ?
  ''', [idUsuario]);

  // Validar resultados
  if (result.isNotEmpty) {
    return {
      'nombreUsuario': result[0]['nombreUsuario'] as String,
      'claveCCT': result[0]['claveCCT'] as String,
    };
  } else {
    throw Exception('No se encontraron datos para el id_Usuario: $idUsuario');
  }
}


  
  /// Obtiene el tipo de servicio del CCT asignado al usuario por su ID
Future<String?> getTipoServicioCCT(int idUsuario) async {
  // Obtén una referencia a la base de datos
  final db = await database;

  // Consulta para obtener el tipo de servicio del CCT asignado al usuario
  final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT 
      CCT.tipo_Servicio AS tipoServicio
    FROM CCTAsignado
    INNER JOIN CCT ON CCTAsignado.id_CCT = CCT.id_CCT
    WHERE CCTAsignado.id_Usuario = ?
  ''', [idUsuario]);

  // Si no hay resultados, retorna null
  if (result.isEmpty) {
    return null;
  }

print(result);
  // Retorna el tipo de servicio como un string
  return result.first['tipoServicio'] as String?;
}

  /// Valida el usuario y contraseña
  Future<Map<String, dynamic>?> validarUsuario(
      String usuario, String password) async {
    final db = await database;

    // Consulta a la base de datos
    final List<Map<String, dynamic>> result = await db.query(
      'Usuarios',
      columns: ['id_Usuario', 'rol'],
      where: 'usuario = ? AND password = ?',
      whereArgs: [usuario, password],
      limit: 1,
    );

    // Si hay un resultado, retornamos el id_Usuario y rol
    if (result.isNotEmpty) {
      print(result);
      return {
        'id_Usuario': result.first['id_Usuario'],
        'rol': result.first['rol'],
      };
    }

    // Si no se encuentra nada, retornamos null
    return null;
  }

  /// Obtiene la region de un usuario por su ID
 /// Obtiene la región de un usuario por su ID
Future<Map<String, String>?> getRegionPorUsuario(int idUsuario) async {
  final db = await database; // Asegúrate de usar tu instancia de base de datos local

  final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT 
      Region.Nombre AS nombreRegion
    FROM DatosUsuarios
    INNER JOIN Region ON DatosUsuarios.Region = Region.cv_region
    WHERE DatosUsuarios.id_Usuario = ? AND DatosUsuarios.Region IS NOT NULL
  ''', [idUsuario]);

  // Si no hay resultados, retorna null
  if (result.isEmpty) {
    return null;
  }

  // Retorna el nombre de la región como un mapa
  return {
    'nombreRegion': result.first['nombreRegion'] as String,
  };
}



/// Obtiene la microrregión asignada a un usuario por su ID
Future<Map<String, String>?> getMicrorregionPorUsuario(int idUsuario) async {
  final db = await database; // Asegúrate de usar tu instancia de base de datos local

  final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT 
      Microrregion.Nombre AS nombreMicrorregion
    FROM DatosUsuarios
    INNER JOIN Microrregion ON DatosUsuarios.Microrregion = Microrregion.cv_microrregion
    WHERE DatosUsuarios.id_Usuario = ? AND DatosUsuarios.Microrregion IS NOT NULL
  ''', [idUsuario]);

  // Si no hay resultados, retorna null
  if (result.isEmpty) {
    return null;
  }

  // Retorna el nombre de la microrregión como un mapa
  return {
    'nombreMicrorregion': result.first['nombreMicrorregion'] as String,
  };
}





Future<Map<int, dynamic>> obtenerAsistenciaPorUsuario(int idUsuario) async {
  final db = await database;



 final List<Map<String, dynamic>> dependientes = await db.rawQuery('''
  SELECT 
    d.id_Dependiente AS idProfesor, 
    du.nombreCompleto AS profesor
  FROM Dependencias d
  INNER JOIN Usuarios u ON d.id_Dependiente = u.id_Usuario
  INNER JOIN DatosUsuarios du ON u.id_Usuario = du.id_Usuario
  WHERE d.id_Responsable = ?
''', [idUsuario]);

print('Dependientes encontrados: $dependientes');
  // Mapa para almacenar la asistencia
  Map<int, dynamic> asistenciaMap = {};

  for (var dependiente in dependientes) {
    final int idProfesor = dependiente['idProfesor'];
    final String nombreProfesor = dependiente['profesor'];

    // Consulta para obtener los datos de asistencia del profesor
    final List<Map<String, dynamic>> asistencias = await db.rawQuery('''
      SELECT fecha, usuario, horaEntrada, horaSalida, Asistencia
      FROM Asistencia
      WHERE id_Profesor = ?
        AND (fecha IS NOT NULL OR usuario IS NOT NULL OR horaEntrada IS NOT NULL OR horaSalida IS NOT NULL)
    ''', [idProfesor]);

    // Agregar los datos al mapa si hay asistencias disponibles
    if (asistencias.isNotEmpty) {
      asistenciaMap[idProfesor] = {
        'nombre': nombreProfesor,
        'asistencias': asistencias.map((asistencia) {
          return {
            'fecha': asistencia['fecha'],
            'usuario': asistencia['usuario'],
            'horaEntrada': asistencia['horaEntrada'],
            'horaSalida': asistencia['horaSalida'],
            'Asistencia': asistencia['Asistencia'] == 1, // Convertir a booleano
          };
        }).toList(),
      };
    } else {
      asistenciaMap[idProfesor] = {
        'nombre': nombreProfesor,
        'asistencias': [],
      };
    }
  }
  print('>>>>>>>>>$asistenciaMap');
  return asistenciaMap;
}






Future<List<Map<String, dynamic>>> getDATAdependientesECA(int idUsuario) async {
  final db = await database;

  // Paso 1: Consulta los IDs de los dependientes
  final List<Map<String, dynamic>> dependencias = await db.rawQuery('''
    SELECT id_Dependiente
    FROM Dependencias
    WHERE id_Responsable = ?
  ''', [idUsuario]);

  if (dependencias.isEmpty) {
    return [];
  }

  final List<int> dependientesIds =
      dependencias.map((e) => e['id_Dependiente'] as int).toList();

  if (dependientesIds.isEmpty) {
    return [];
  }

  // Paso 2: Consulta los datos de los dependientes
  final List<Map<String, dynamic>> dependientesData = await db.rawQuery('''
    SELECT 
      Usuarios.id_Usuario AS id,
      DatosUsuarios.nombreCompleto AS Nombre,
      Usuarios.rol AS Rol,
      (CCT.Nombre || ' - ' || CCT.id_CCT) AS Ubicacion,
      DatosUsuarios.situacion_Educativa AS Situacion,
      DatosUsuarios.contexto AS Contexto,
      DatosUsuarios.Region AS Region,
      DatosUsuarios.Nivel AS Nivel,
      CCT.tipo_Servicio AS TipoServicio,
      DatosUsuarios.Microrregion AS Microrregion,
      DatosUsuarios.Estado AS Estatus -- Nuevo campo
    FROM Usuarios
    INNER JOIN DatosUsuarios ON Usuarios.id_Usuario = DatosUsuarios.id_Usuario
    LEFT JOIN CCT ON DatosUsuarios.CCT = CCT.id_CCT
    WHERE Usuarios.id_Usuario IN (${dependientesIds.join(', ')})
  ''');

  return dependientesData;
}


Future<List<Map<String, dynamic>>> getDATAdependientesECAR(int idUsuario) async {
  final db = await database;

  // Paso 1: Consulta los IDs de los dependientes
  final List<Map<String, dynamic>> dependencias = await db.rawQuery('''
    SELECT id_Dependiente
    FROM Dependencias
    WHERE id_Responsable = ?
  ''', [idUsuario]);

  if (dependencias.isEmpty) {
    return [];
  }

  final List<int> dependientesIds =
      dependencias.map((e) => e['id_Dependiente'] as int).toList();

  if (dependientesIds.isEmpty) {
    return [];
  }

  // Paso 2: Consulta los datos de los dependientes
  final List<Map<String, dynamic>> dependientesData = await db.rawQuery('''
    SELECT 
      Usuarios.id_Usuario AS id,
      DatosUsuarios.nombreCompleto AS Nombre,
      Usuarios.rol AS Rol,
      Microrregion.Nombre AS Ubicacion,
      DatosUsuarios.situacion_Educativa AS Situacion,
      DatosUsuarios.contexto AS Contexto,
      DatosUsuarios.Estado AS Estatus -- Nuevo campo
    FROM Usuarios
    INNER JOIN DatosUsuarios ON Usuarios.id_Usuario = DatosUsuarios.id_Usuario
    LEFT JOIN MicroRegionAsignada ON Usuarios.id_Usuario = MicroRegionAsignada.id_Usuario
    LEFT JOIN Microrregion ON MicroRegionAsignada.id_Microregion = Microrregion.cv_microrregion
    WHERE Usuarios.id_Usuario IN (${dependientesIds.join(', ')})
  ''');

  return dependientesData;
}






  Future<List<Map<String, dynamic>>> cargarAlumnosPorMaestro(int idMaestro) async {
  final db = await database;

  // Consulta para obtener los datos de los alumnos asignados al maestro
  final List<Map<String, dynamic>> alumnos = await db.rawQuery('''
    SELECT 
        Alumnos.id_Alumno,
        Alumnos.curp,
        Alumnos.fechaNacimiento,
        Alumnos.lugarNacimiento,
        Alumnos.domicilio,
        Alumnos.municipio,
        Alumnos.estado,
        Alumnos.nombrePadre,
        Alumnos.ocupacionPadre,
        Alumnos.telefonoPadre,
        Alumnos.state,
        Alumnos.nota,
        CCT.tipo_Servicio AS Nivel, -- Nivel obtenido del campo tipo_Servicio en CCT
        Grupos.Grado
    FROM Alumnos
    INNER JOIN AsignacionGrupos ON Alumnos.id_Alumno = AsignacionGrupos.id_Alumno
    INNER JOIN Grupos ON AsignacionGrupos.id_Grupo = Grupos.id_Grupo
    INNER JOIN CCT ON Grupos.id_CCT = CCT.id_CCT
    INNER JOIN AsignacionMaestro ON Grupos.id_Grupo = AsignacionMaestro.id_Grupo
    WHERE AsignacionMaestro.id_Maestro = ?;
  ''', [idMaestro]);

  return alumnos;
}


  

  

  Future<List<Map<String, dynamic>>> cargarAlumnosDeResponsables(int idUsuario) async {
  final db = await database;

  // Obtener los usuarios dependientes del maestro (responsable)
  final List<Map<String, dynamic>> dependientes = await db.query(
    'Dependencias',
    columns: ['id_Dependiente'],
    where: 'id_Responsable = ?',
    whereArgs: [idUsuario],
  );

  if (dependientes.isEmpty) {
    return []; // Si no hay dependientes, retorna una lista vacía
  }

  // Extraer los IDs de los usuarios dependientes
  final List<int> idsDependientes =
      dependientes.map((e) => e['id_Dependiente'] as int).toList();

  // Crear una consulta para obtener los alumnos relacionados a través de las tablas
  final List<Map<String, dynamic>> alumnos = await db.rawQuery('''
    SELECT 
      a.id_Alumno,
      a.actaNacimiento,
      a.certificadoEstudios,
      a.fotoVacunacion,
      a.curp,
      a.fechaNacimiento,
      a.lugarNacimiento,
      a.domicilio,
      a.municipio,
      a.estado,
      a.nombrePadre,
      a.ocupacionPadre,
      a.telefonoPadre,
      a.state,
      a.nota,
      g.Grado,
      c.tipo_Servicio AS Nivel
    FROM Alumnos a
    INNER JOIN AsignacionGrupos ag ON a.id_Alumno = ag.id_Alumno
    INNER JOIN Grupos g ON ag.id_Grupo = g.id_Grupo
    INNER JOIN CCT c ON g.id_CCT = c.id_CCT
    INNER JOIN AsignacionMaestro am ON g.id_Grupo = am.id_Grupo
    WHERE am.id_Maestro IN (${idsDependientes.map((_) => '?').join(', ')})
  ''', idsDependientes);

  return alumnos;
}



  // Método para actualizar un solo parámetro en la tabla AlumnosAlta según su CURP
  Future<int> actualizarParametroAlumnoPorid(
      int id, String parametro, dynamic valor) async {
    final db = await database;
    return await db.update(
      'Alumnos',
      {parametro: valor},
      where: 'id_Alumno = ?',
      whereArgs: [id],
    );
  }

Future<Map<String, dynamic>> obtenerGrupoConAlumnos(int idUsuario) async {
  final db = await database;

  // Obtener los grupos asignados al maestro (idUsuario)
  final List<Map<String, dynamic>> grupos = await db.rawQuery('''
    SELECT g.id_Grupo, g.Nivel, g.Grado
    FROM Grupos g
    INNER JOIN AsignacionMaestro am ON g.id_Grupo = am.id_Grupo
    WHERE am.id_Maestro = ?
  ''', [idUsuario]);

  if (grupos.isEmpty) {
    // Si no hay grupos asignados al maestro, retorna un mapa vacío
    return {};
  }

  // Crear un mapa para almacenar la información del grupo y sus alumnos
  final Map<String, dynamic> resultado = {};

  // Iterar sobre los grupos encontrados
  for (final grupo in grupos) {
    final int idGrupo = grupo['id_Grupo'];

    // Obtener los alumnos asociados al grupo, incluyendo su calificación final
    final List<Map<String, dynamic>> alumnos = await db.rawQuery('''
      SELECT 
        a.id_Alumno, 
        a.CURP AS nombre,
        pa.calfFinal
      FROM Alumnos a
      INNER JOIN AsignacionGrupos ag ON a.id_Alumno = ag.id_Alumno
      LEFT JOIN PromocionesAlumnos pa ON a.id_Alumno = pa.id_Alumno
      WHERE ag.id_Grupo = ?
    ''', [idGrupo]);

    // Agregar los datos del grupo y sus alumnos al resultado
    resultado[idGrupo.toString()] = {
      'id_Grupo': idGrupo,
      'Nivel': grupo['Nivel'],
      'Grado': grupo['Grado'],
      'Alumnos': alumnos,
    };
  }

  return resultado;
}




















Future<int> obtenerIdMateria(String nombre, String grado, String nivel) async {
  final db = await database;

  // Verificar si la materia ya existe
  final List<Map<String, dynamic>> materias = await db.query(
    'Materias',
    where: 'Nombre = ? AND Grado = ? AND Nivel = ?',
    whereArgs: [nombre, grado, nivel],
  );

  if (materias.isNotEmpty) {
    // Retornar el ID si ya existe
    return materias.first['id_Materia'];
  } else {
    // Crear la materia si no existe y retornar su ID
    return await db.insert('Materias', {
      'Nombre': nombre,
      'Grado': grado,
      'Nivel': nivel,
    });
  }
}
Future<Map<String, dynamic>?> obtenerPromocionAlumno(int idAlumno) async {
  final db = await database;

  // Consultar si existe una promoción para el alumno
  final List<Map<String, dynamic>> promocion = await db.query(
    'PromocionesAlumnos',
    where: 'id_Alumno = ?',
    whereArgs: [idAlumno],
  );

  if (promocion.isNotEmpty) {
    return promocion.first;
  } else {
    return null; // Retorna null si no hay promoción registrada
  }
}


Future<List<Map<String, dynamic>>> obtenerMateriasPorGradoYNivel(
    String grado, String nivel) async {
  final db = await database;

  try {
    // Consulta para obtener las materias asociadas al grado y nivel
    final List<Map<String, dynamic>> materias = await db.query(
      'Materias',
      where: 'Grado = ? AND Nivel = ?',
      whereArgs: [grado, nivel],
    );

    return materias;
  } catch (e) {
    // Manejo de errores
    print('Error al obtener materias: $e');
    return [];
  }
}


Future<void> asignarCalificaciones(int idAlumno, List<Map<String, dynamic>> calificaciones) async {
  final db = await database;

  await db.transaction((txn) async {
    for (var calificacion in calificaciones) {
      final int idMateria = calificacion['idMateria'];
      final int calificacionValue = calificacion['calificacion'];

      // Verificar si ya existe una calificación para el alumno en la materia
      final List<Map<String, dynamic>> existente = await txn.query(
        'Calificaciones',
        where: 'id_Alumno = ? AND id_Materia = ?',
        whereArgs: [idAlumno, idMateria],
      );

      if (existente.isNotEmpty) {
        // Actualizar la calificación existente
        await txn.update(
          'Calificaciones',
          {'calificacion': calificacionValue},
          where: 'id_Alumno = ? AND id_Materia = ?',
          whereArgs: [idAlumno, idMateria],
        );
      } else {
        // Insertar una nueva calificación
        await txn.insert('Calificaciones', {
          'id_Alumno': idAlumno,
          'id_Materia': idMateria,
          'calificacion': calificacionValue,
        });
      }
    }

    // Recalcular la calificación final basada en las materias
    final List<Map<String, dynamic>> calificacionesAlumno = await txn.query(
      'Calificaciones',
      where: 'id_Alumno = ?',
      whereArgs: [idAlumno],
    );

    if (calificacionesAlumno.isNotEmpty) {
      final int totalCalificaciones = calificacionesAlumno.fold<int>(
        0,
        (sum, calif) => sum + (calif['calificacion'] as int),
      );
      final int promedio = (totalCalificaciones / calificacionesAlumno.length).round();

      // Verificar si ya existe un registro en PromocionesAlumnos
      final List<Map<String, dynamic>> promocionExistente = await txn.query(
        'PromocionesAlumnos',
        where: 'id_Alumno = ?',
        whereArgs: [idAlumno],
      );

      if (promocionExistente.isNotEmpty) {
        // Actualizar promoción existente
        await txn.update(
          'PromocionesAlumnos',
          {'calfFinal': promedio, 'tipoPromocion': promedio >= 6 ? 'Ordinaria' : 'Regularizado'},
          where: 'id_Alumno = ?',
          whereArgs: [idAlumno],
        );
      } else {
        // Insertar una nueva promoción
        final alumnoInfo = await txn.query(
          'Alumnos',
          columns: ['id_Grupo'],
          where: 'id_Alumno = ?',
          whereArgs: [idAlumno],
        );

        if (alumnoInfo.isNotEmpty) {
          final int idGrupo = alumnoInfo.first['id_Grupo'] as int;

          final grupoInfo = await txn.query(
            'Grupos',
            columns: ['Grado', 'Nivel'],
            where: 'id_Grupo = ?',
            whereArgs: [idGrupo],
          );

          if (grupoInfo.isNotEmpty) {
            final String grado = grupoInfo.first['Grado'] as String;
            final String nivel = grupoInfo.first['Nivel'] as String;

            await txn.insert('PromocionesAlumnos', {
              'id_Alumno': idAlumno,
              'calfFinal': promedio,
              'tipoPromocion': promedio >= 6 ? 'Ordinaria' : 'Regularizado',
              'Grado': grado,
              'Nivel': nivel,
            });
          }
        }
      }
    }
  });
}








  Future<void> insertarAlumno(Map<String, dynamic> alumno) async {
  final db = await database;

  // Procesar y convertir archivos a bytes si existen
  Uint8List? actaNacimientoBytes =
      await _leerArchivoComoBytes(alumno['actaNacimiento']);
  Uint8List? certificadoEstudiosBytes =
      await _leerArchivoComoBytes(alumno['certificadoEstudios']);
  Uint8List? fotoVacunacionBytes =
      await _leerArchivoComoBytes(alumno['fotoVacunacion']);

  await db.transaction((txn) async {
  // Obtener el id_CCT asociado al maestro
  final int idMaestro = alumno['id_Maestro'];
  final List<Map<String, dynamic>> cctResult = await txn.rawQuery('''
    SELECT ca.id_CCT
    FROM CCTAsignado ca
    WHERE ca.id_Usuario = ?
  ''', [idMaestro]);

  if (cctResult.isEmpty) {
    throw Exception('No se encontró un CCT asociado al maestro.');
  }

  final String idCCT = cctResult.first['id_CCT']; // Obtener el id_CCT del maestro
  final String grado = alumno['gradoEscolar'];

  // Buscar si existe un grupo asociado al maestro con el mismo grado y CCT
  final List<Map<String, dynamic>> grupoExistente = await txn.rawQuery('''
    SELECT g.id_Grupo
    FROM Grupos g
    INNER JOIN AsignacionMaestro am ON g.id_Grupo = am.id_Grupo
    WHERE g.id_CCT = ? AND g.Grado = ? AND am.id_Maestro = ?
  ''', [idCCT, grado, idMaestro]);

  int idGrupo;

  if (grupoExistente.isNotEmpty) {
    // Usar el grupo existente
    idGrupo = grupoExistente.first['id_Grupo'];
  } else {
    // Crear un nuevo grupo con el CCT y grado
    idGrupo = await txn.insert('Grupos', {
      'id_CCT': idCCT, // Asociar el CCT al grupo
      'Grado': grado,
    });

    // Asignar el maestro al nuevo grupo
    await txn.insert('AsignacionMaestro', {
      'id_Grupo': idGrupo,
      'id_Maestro': idMaestro,
    });
  }



    // Insertar datos del alumno
    final int idAlumno = await txn.insert('Alumnos', {
      'actaNacimiento': actaNacimientoBytes,
      'curp': alumno['curp'] ?? '',
      'fechaNacimiento': alumno['fechaNacimiento'] ?? '',
      'lugarNacimiento': alumno['lugarNacimiento'] ?? '',
      'domicilio': alumno['domicilio'] ?? '',
      'municipio': alumno['municipio'] ?? '',
      'estado': alumno['estado'] ?? '',
      'certificadoEstudios': certificadoEstudiosBytes,
      'nombrePadre': alumno['nombrePadre'] ?? '',
      'ocupacionPadre': alumno['ocupacionPadre'] ?? '',
      'telefonoPadre': alumno['telefonoPadre'] ?? '',
      'fotoVacunacion': fotoVacunacionBytes,
      'state': alumno['state'] ?? 'pendiente',
      'nota': alumno['nota'] ?? '',
    });

    // Relacionar el alumno con el grupo (AsignacionGrupos)
    await txn.insert('AsignacionGrupos', {
      'id_Grupo': idGrupo,
      'id_Alumno': idAlumno,
    });

  });
}


  Future<Uint8List?> _leerArchivoComoBytes(dynamic archivo) async {
    if (archivo == null) return null;
    if (archivo is File) {
      return await archivo.readAsBytes();
    } else {
      throw ArgumentError('El archivo debe ser de tipo File o null');
    }
  }


  Future<List<Map<String, dynamic>>> obtenerHistorialEnviosPorUsuarioDEP(
    int idUsuario) async {
  // Abre la base de datos
  final db = await database;

  // Paso 1: Obtener los IDs de los dependientes del usuario
  final List<Map<String, dynamic>> dependientes = await db.query(
    'Dependencias',
    columns: ['id_Dependiente'],
    where: 'id_Responsable = ?',
    whereArgs: [idUsuario],
  );

  if (dependientes.isEmpty) {
    return []; // Retorna una lista vacía si no hay dependientes
  }

  // Extraer los IDs de los dependientes en una lista
  final List<int> idsDependientes =
      dependientes.map((e) => e['id_Dependiente'] as int).toList();

  // Paso 2: Construir la consulta para obtener los reportes de los dependientes
  final List<Map<String, dynamic>> resultado = await db.query(
    'Reportes',
    columns: ['id_Reporte','periodo', 'reporte', 'estado', 'id_usuario'],
    where: 'id_usuario IN (${idsDependientes.map((_) => '?').join(', ')})',
    whereArgs: idsDependientes,
  );

  // Paso 3: Transformar los datos para el historial de envíos
  final List<Map<String, dynamic>> historialEnvios = resultado.map((fila) {
    return {
      'id_Reporte': fila['id_Reporte'],
      'Periodo': fila['periodo'] as String,
      'Reporte': fila['reporte'],
      'Estado': fila['estado'] as String,
      'Usuario': fila['id_usuario'], // Agregamos el ID del dependiente para referencia
    };
  }).toList();

  return historialEnvios;
}




  Future<List<Map<String, dynamic>>> obtenerHistorialEnviosPorUsuario(
      int idUsuario) async {
    // Abre la base de datos
    final db = await database;

    // Realiza la consulta a la tabla Reportes
    final List<Map<String, dynamic>> resultado = await db.query(
      'Reportes',
      columns: ['periodo', 'reporte', 'estado'],
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
    );

    // Transforma los datos para que sean compatibles con historialEnvios
    final List<Map<String, dynamic>> historialEnvios = resultado.map((fila) {
      return {
        'Periodo': fila['periodo'] as String,
        'Reporte': fila['reporte'] ,
        'Estado': fila['estado'] as String,
      };
    }).toList();
    return historialEnvios;
  }

  Future<void> insertarReporte(Map<String, dynamic> reporte) async {
    final db = await database;
    // Prepara los valores que se insertarán en la tabla Reportes
    final Map<String, dynamic> valores = {
      'Periodo': reporte['Periodo'],
      'Estado': reporte['Estado'],
      'Reporte': reporte['Reporte'],
      'id_usuario': reporte['id_usuario'],
    };

    // Inserta el registro en la tabla Reportes
    await db.insert(
      'Reportes',
      valores,
      conflictAlgorithm: ConflictAlgorithm
          .replace, // Para manejar conflictos si el ID ya existe
    );
    print(">>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< jalo pau");
  }

  Future<Map<String, List<Map<String, dynamic>>>> obtenerPagosPorUsuario(int idUsuario) async {
  final db = await database;

  // Realizamos la consulta para obtener los pagos asociados al usuario
  final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT 
      p.fecha,
      p.tipoPago,
      p.monto,
      p.status
    FROM PagosFechas p
    WHERE p.id_Usuario = ?
  ''', [idUsuario]);

  // Creamos el Map que contendrá las fechas de pago organizadas por fecha
  Map<String, List<Map<String, dynamic>>> pagosPorFecha = {};

  // Iteramos sobre los resultados y organizamos los pagos por fecha
  for (var row in results) {
    String fecha = row['fecha']; // La fecha es un String en formato 'yyyy-MM-dd'
    String tipoPago = row['tipoPago'];
    double monto = row['monto'];
    String status = row['status'];

    // Si no existe la fecha en el Map, la inicializamos con una lista vacía
    if (!pagosPorFecha.containsKey(fecha)) {
      pagosPorFecha[fecha] = [];
    }

    // Agregamos el pago correspondiente a esa fecha
    pagosPorFecha[fecha]?.add({
      'tipopago': tipoPago,
      'monto': monto,
      'status': status,
    });
  }
  print(pagosPorFecha);
  // Devolvemos el mapa con los pagos organizados por fecha
  return pagosPorFecha;
}



Future<void> actualizarStatusPago( int idUsuario, String fecha, String nuevoStatus) async {
  final db = await database;
  try {
    // Actualizar el status en la tabla PagosFechas
    int count = await db.update(
      'PagosFechas',
      {'status': nuevoStatus},
      where: 'id_Usuario = ? AND fecha = ?',
      whereArgs: [idUsuario, fecha],
    );

    if (count > 0) {
      // Imprimir el nuevo estado del pago en la consola
      final List<Map<String, dynamic>> resultado = await db.query(
        'PagosFechas',
        columns: ['status'],
        where: 'id_Usuario = ? AND fecha = ?',
        whereArgs: [idUsuario, fecha],
      );

      if (resultado.isNotEmpty) {
        print('Status actualizado: ${resultado.first['status']}');
      } else {
        print('Error al verificar el nuevo estado.');
      }
    } else {
      print('No se encontró ningún registro para actualizar.');
    }
  } catch (e) {
    print('Error al actualizar el status del pago: $e');
  }
}



 Future<void> insertarDatosActCAP(Map<String, dynamic> dataToInsert) async {
  // Obtén la referencia a la base de datos
  final db = await database;
  // Realiza la inserción en la tabla ActCAP
  await db.insert(
    'ActCAP',
    dataToInsert,
    conflictAlgorithm: ConflictAlgorithm.replace,  // Define el comportamiento ante conflictos
  );
 print(dataToInsert);
  print('Datos insertados correctamente');
}


  Future<List<Map<String, dynamic>>> obtenerActividadesCAPPorUsuario(int idUsuario) async {
  final db = await database; 

  // Ejecuta la consulta para obtener los registros de ActCAP con el nombre de microrregión y CCT
  final List<Map<String, dynamic>> resultado = await db.rawQuery('''
    SELECT 
      a.id_ActCAP, 
      a.NumCapacitacion, 
      a.TEMA, 
      a.FechaProgramada, 
      a.Estado, 
      a.Reporte, 
      m.Nombre AS Microrregion,  -- Nombre de la microrregión
      c.Nombre AS CCT           -- Nombre del CCT
    FROM ActCAP a
    INNER JOIN Microrregion m ON a.id_Microregion = m.cv_microrregion
    INNER JOIN CCT c ON a.id_CCT = c.id_CCT
    WHERE a.id_Usuario = ?
  ''', [idUsuario]);

  print('>>>>$resultado');
  return resultado;
}





Future<int> editarActividad(Map<String, dynamic> actividad) async {
  final db = await database;

  // Actualizamos solo los campos que recibimos
  return await db.update(
    'ActCAP',
    {
      'Estado': actividad['Estado'], // Actualiza el estado
      'Reporte': actividad['Reporte'], // Actualiza el reporte
    },
    where: 'id_ActCAP = ?', 
    whereArgs: [actividad['id_ActCAP']], // Filtra por id_ActCAP
  );
}

  
 Future<Map<String, Map<String, dynamic>>> obtenerDependientesPorUsuario(int idUsuario) async {
  final db = await database;

  // Ajustamos la consulta SQL para incluir las relaciones correctas
  final dependientes = await db.rawQuery('''
    SELECT du.nombreCompleto, d.id_Dependiente
    FROM Dependencias d
    INNER JOIN Usuarios u ON u.id_Usuario = d.id_Dependiente
    INNER JOIN DatosUsuarios du ON du.id_Usuario = u.id_Usuario
    WHERE d.id_Responsable = ?
  ''', [idUsuario]);

  // Creamos el mapa para almacenar los dependientes
  Map<String, Map<String, dynamic>> dependientesMap = {};

  // Iteramos sobre los resultados para construir el mapa
  for (var dependiente in dependientes) {
    String? nombreCompleto = dependiente['nombreCompleto'] as String?;
    if (nombreCompleto != null) {
      dependientesMap[nombreCompleto] = {
        'id_Maestro': dependiente['id_Dependiente'],
        'asistencia': false, // Valor por defecto para asistencia
        'entrada': null,     // Hora de entrada por defecto
        'salida': null,      // Hora de salida por defecto
      };
    }
  }
print(dependientesMap);
  return dependientesMap;
}



Future<void> insertarAsistencia(List<Map<String, dynamic>> registrosAsistencia, int usuario) async {
  final db = await database;
  for (var registro in registrosAsistencia) {
    await db.insert(
      'Asistencia',
      {
        'id_Profesor': registro['id_Profesor'],
        'fecha': registro['fecha'], // Solo fecha (YYYY-MM-DD)
        'usuario': usuario,
        'horaEntrada': registro['entrada'] ?? null,
        'horaSalida': registro['salida'] ?? null,
        'Asistencia': registro['asistencia'] ? 1 : 0, // Convertimos el booleano a entero
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}


Future<Map<String, dynamic>?> getReporteByActividadId(int idActividadAcomp) async {
  final db = await database;
  try {
    // Ejecutar la consulta usando id_ActividadAcomp
    final List<Map<String, dynamic>> result = await db.query(
      'ReportesAcomp', // Nombre de la tabla
      where: 'id_ActividadAcomp = ?', // Condición
      whereArgs: [idActividadAcomp], // Argumentos de la condición
    );

    // Retornar el primer resultado si existe
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null; // Retorna null si no se encuentra el reporte
    }
  } catch (e) {
    // Manejo de errores
    print('Error al obtener el reporte: $e');
    return null;
  }
}


Future<Map<String, List<Map<String, dynamic>>>> obtenerActividadesPorUsuario(int idUsuario) async {
  final db = await database;

  // Realizar la consulta para obtener las actividades relacionadas con el id_Usuario
  final List<Map<String, dynamic>> actividades = await db.rawQuery('''
    SELECT a.id_ActividadAcomp, a.fecha, a.hora, a.descripcion, a.estado, a.id_Figura, du.nombreCompleto AS figuraNombre
    FROM ActividadAcomp a
    INNER JOIN Usuarios u ON a.id_Usuario = u.id_Usuario
    INNER JOIN DatosUsuarios du ON a.id_Figura = du.id_Usuario
    WHERE a.id_Usuario = ?
  ''', [idUsuario]);

  // Crear un Map<String, List<Map<String, dynamic>>> con los datos obtenidos
  Map<String, List<Map<String, dynamic>>> eventos = {};

  for (var actividad in actividades) {
    String fecha = actividad['fecha'] ?? '';
    if (eventos[fecha] == null) {
      eventos[fecha] = [];
    }

    eventos[fecha]!.add({
      'id_ActividadAcomp': actividad['id_ActividadAcomp'],
      'fecha': actividad['fecha'],
      'hora': actividad['hora'],
      'descripcion': actividad['descripcion'],
      'estado': actividad['estado'],
      'figuraNombre': actividad['figuraNombre'], // Nombre de la figura educativa
    });
  }

  return eventos;
}


Future<Map<int, dynamic>> obtenerDependientesYSubdependientes(int idUsuario) async {
  final db = await database;

  // Obtener los dependientes directos del usuario
  final List<Map<String, dynamic>> dependientesDirectos = await db.rawQuery('''
    SELECT 
      d.id_Dependiente AS idDependiente, 
      du.nombreCompleto AS nombre, 
      u.rol AS rol
    FROM Dependencias d
    INNER JOIN Usuarios u ON d.id_Dependiente = u.id_Usuario
    INNER JOIN DatosUsuarios du ON u.id_Usuario = du.id_Usuario
    WHERE d.id_Responsable = ?
  ''', [idUsuario]);

  // Mapa para almacenar dependientes y subdependientes
  Map<int, dynamic> resultado = {};

  for (var dependiente in dependientesDirectos) {
    final int idDependiente = dependiente['idDependiente'];
    final String nombre = dependiente['nombre'];
    final String rol = dependiente['rol'];

    // Obtener los subdependientes del dependiente actual
    final List<Map<String, dynamic>> subdependientes = await db.rawQuery('''
      SELECT 
        d.id_Dependiente AS idSubdependiente, 
        du.nombreCompleto AS nombre, 
        u.rol AS rol
      FROM Dependencias d
      INNER JOIN Usuarios u ON d.id_Dependiente = u.id_Usuario
      INNER JOIN DatosUsuarios du ON u.id_Usuario = du.id_Usuario
      WHERE d.id_Responsable = ?
    ''', [idDependiente]);

    // Agregar dependiente y sus subdependientes al mapa
    resultado[idDependiente] = {
      'nombre': nombre,
      'rol': rol,
      'subdependientes': subdependientes.map((sub) {
        return {
          'idSubdependiente': sub['idSubdependiente'],
          'nombre': sub['nombre'],
          'rol': sub['rol']
        };
      }).toList(),
    };
  }

  return resultado;
}





  Future<void> insertarActividad(Map<String, dynamic> actividad) async {
  // Obtener la instancia de la base de datos
  final Database db = await database;

  // Insertar la nueva actividad en la tabla 'ActividadAcomp'
  await db.insert(
    'ActividadAcomp',
    actividad,
    conflictAlgorithm: ConflictAlgorithm.replace, // Reemplazar en caso de conflicto
  );

  print("Actividad insertada: $actividad");
}

Future<void> eliminarActividad(int idActividad) async {
  // Obtener la instancia de la base de datos
  final Database db = await database;

  // Eliminar la actividad de la tabla 'ActividadAcomp' basada en el id_Actividad
  await db.delete(
    'ActividadAcomp',
    where: 'id_ActividadAcomp = ?',
    whereArgs: [idActividad],
  );

  print("Actividad eliminada con id: $idActividad");
}
  

Future<void> editarActividadAcomp(Map<String, dynamic> actividad) async {
  // Obtener la instancia de la base de datos
  final Database db = await database;

  // Verificar que 'id_ActividadAcomp' no sea null
  final idActividad = actividad['id_ActividadAcomp'];
  if (idActividad == null) {
    print('Error: id_ActividadAcomp es null, no se puede editar la actividad');
    return;
  }

  // Actualizar la actividad en la tabla 'ActividadAcomp'
  await db.update(
    'ActividadAcomp',
    {
      'fecha': actividad['fecha'],
      'hora': actividad['hora'],
      'id_figura': actividad['id_figura'],
      'descripcion': actividad['descripcion'],
      'estado': actividad['estado'],
    },
    where: 'id_ActividadAcomp = ?',
    whereArgs: [idActividad],
  );

  print("Actividad editada: $actividad");
}

Future<void> cambiarEstadoYRegistrarReporte( int idActividad, int idUsuario, Uint8List reporte) async {
  String figura="";
  final db= await database;
  try {
    // 1. Cambiar el estado de la actividad a "inactivo"
    await db.update(
      'ActividadAcomp',
      {'estado': 'inactivo'},  // Se actualiza el estado a 'inactivo'
      where: 'id_ActividadAcomp = ?',
      whereArgs: [idActividad],  // Pasamos el id de la actividad
    );

    // 2. Insertar un nuevo reporte en la tabla ReportesAcomp
    await db.insert(
      'ReportesAcomp',
      {
        'reporte': reporte,  // El contenido del reporte
        'id_ActividadAcomp': idActividad,  // Relacionamos el reporte con la actividad
        'fecha': DateTime.now().toIso8601String(),  // Fecha del reporte
        'figuraEducativa': figura,  // Esto puede ser personalizado
        'id_Usuario': idUsuario,  // Usuario que genera el reporte
      },
      conflictAlgorithm: ConflictAlgorithm.replace,  // En caso de conflicto, se reemplaza el registro
    );

    print('Estado de la actividad actualizado y reporte agregado exitosamente.');
  } catch (e) {
    print('Error al cambiar el estado o agregar el reporte: $e');
  }
}



Future<Map<String, Map<String, String>>> obtenerActividadesPorNombreEC(int id) async {
  final db = await database;

  // Realizar la consulta para obtener las actividades relacionadas con el nombreEC
  final List<Map<String, dynamic>> actividades = await db.rawQuery('''
  SELECT a.*
  FROM ActividadAcomp a
  INNER JOIN Dependencias d ON a.id_Usuario = d.id_Responsable
  WHERE d.id_Dependiente = ?
''', [id]);


  // Crear un Map<String, Map<String, String>> con las actividades
  Map<String, Map<String, String>> actividadesMap = {};

  // Iterar sobre las actividades y agregar al Map con una clave genérica
  for (int i = 0; i < actividades.length; i++) {
    actividadesMap['Actividad ${i + 1}'] = {
      'Descripcion': actividades[i]['descripcion'] ?? '',
      'Fecha': actividades[i]['fecha'] ?? '',
      'Estado': actividades[i]['estado'] ?? '',
    };
  }

  return actividadesMap;
}



Future<Map<String, Map<String,dynamic>>> obtenerReportesPorUsuario(int idUsuario) async {
  // Obtener la instancia de la base de datos
  final Database db = await database;

  // Consultar los reportes de los usuarios dependientes del usuario dado
  final List<Map<String, dynamic>> resultados = await db.rawQuery('''
    SELECT 
      ReportesAcomp.id_ReporteAcomp AS idReporte,
      ReportesAcomp.reporte AS reporte,
      ActividadAcomp.descripcion AS actividad,
      ReportesAcomp.figuraEducativa AS figuraEducativa,
      ReportesAcomp.fecha AS fecha
    FROM 
      ReportesAcomp
    INNER JOIN 
      Dependencias ON Dependencias.id_Dependiente = ReportesAcomp.id_Usuario
    INNER JOIN 
      Usuarios ON Usuarios.id_Usuario = Dependencias.id_Dependiente
    INNER JOIN 
      ActividadAcomp ON ActividadAcomp.id_ActividadAcomp = ReportesAcomp.id_ActividadAcomp
    WHERE 
      Dependencias.id_Responsable = ?
  ''', [idUsuario]);

  // Convertir los resultados en el mapa deseado
  Map<String, Map<String, dynamic>> reportesMap = {};
  for (var resultado in resultados) {
    String id = resultado['idReporte'].toString();
    reportesMap[id] = {
      'Reporte': resultado['reporte'],
      'Actividad': resultado['actividad'],
      'Fe': resultado['figuraEducativa'],
      'Fecha': resultado['fecha']
    };
  }

  return reportesMap;
}


Future<Map<String, dynamic>> getPromocionFechasById(int idPromoFechas) async {
  final db= await database;
  // Realiza la consulta para obtener los datos de la tabla 'PromocionFechas' basado en 'id_PromoFechas'
  List<Map<String, dynamic>> result = await db.query(
    'PromocionFechas',
    where: 'id_PromoFechas = ?',
    whereArgs: [idPromoFechas],
  );

  // Si se encuentra el resultado, retorna el primer registro (ya que se espera que sea único por ID)
  if (result.isNotEmpty) {
    return result.first; // Retorna el primer mapa con los datos
  } else {
    throw Exception('No se encontró la promoción con id_PromoFechas: $idPromoFechas');
  }
}

// Función para obtener actividades donde el usuario es id_asignado
Future<List<Map<String, dynamic>>> obtenerActividadesAsignado(int idUsuario) async {
  final db = await database;
  final List<Map<String, dynamic>> actividades = await db.rawQuery('''
    SELECT * FROM ActCap_Movil
    WHERE id_asignado = ?
  ''', [idUsuario]);
  return actividades;
}

// Función para obtener actividades donde el usuario es id_responsable
Future<List<Map<String, dynamic>>> obtenerActividadesResponsable(int idUsuario) async {
  final db = await database;
  final List<Map<String, dynamic>> actividades = await db.rawQuery('''
    SELECT * FROM ActCap_Movil
    WHERE id_responsable = ?
  ''', [idUsuario]);
  return actividades;
}

// Función para actualizar estatus y fecha_fin de una actividad
Future<void> actualizarActividad(
    int idUsuario, int idActividad, Map<String, dynamic> cambios) async {
  final db = await database;

  // Actualizar la actividad en ActCap_Movil
  await db.update(
    'ActCap_Movil',
    {
      'estatus': cambios['estatus'],
      'fecha_fin': cambios['fecha_fin'],
    },
    where: 'id_ActCap = ?',
    whereArgs: [idActividad],
  );

  // Sumar horas a capacitacion_inicial_movil
  final actividad = await db.query(
    'ActCap_Movil',
    columns: ['horas'],
    where: 'id_ActCap = ?',
    whereArgs: [idActividad],
  );

  if (actividad.isNotEmpty) {
    Object? horas = actividad.first['horas'];

    await db.rawUpdate('''
      UPDATE capacitacion_inicial_movil
      SET horasCubiertas = horasCubiertas + ?
      WHERE ec_id = ?
    ''', [horas, idUsuario]);
  }
}

// Función para obtener una lista de ECs con sus nombres donde el usuario es el ECA
Future<List<Map<String, dynamic>>> obtenerEcsPorEca(int idUsuario) async {
  final db = await database;

  final List<Map<String, dynamic>> ecs = await db.rawQuery('''
    SELECT ci.ec_id, du.nombreCompleto
    FROM capacitacion_inicial_movil ci
    INNER JOIN DatosUsuarios du ON ci.ec_id = du.id_Usuario
    WHERE ci.eca_id = ?
  ''', [idUsuario]);
print (ecs);
  return ecs;
}
// Función para insertar una actividad
Future<void> insertarActividadCapI({
  required int ecId,
  required String actividad,
  required int horas,
  required String fechaInicio,
  required String estatus,
  required int idResponsable,
}) async {
  final db = await database;

  try {
    await db.insert('ActCap_Movil', {
      'actividad': actividad,
      'horas': horas,
      'ifecha_inicio': fechaInicio,
      'estatus': estatus,
      'id_asignado': ecId,
      'id_responsable': idResponsable,
    });
  } catch (e) {
    print('Error al insertar actividad: $e');
  }
}
// Función para eliminar una actividad si su estatus no es 'Completado'
Future<void> eliminarActividadI(int idActividad) async {
  final db = await database;

  try {
    // Verificar el estatus de la actividad antes de eliminarla
    final List<Map<String, dynamic>> actividad = await db.query(
      'ActCap_Movil',
      columns: ['estatus'],
      where: 'id_ActCap = ?',
      whereArgs: [idActividad],
    );

    if (actividad.isNotEmpty && actividad.first['estatus'] != 'Completado') {
      // Si el estatus no es 'Completado', eliminamos la actividad
      await db.delete(
        'ActCap_Movil',
        where: 'id_ActCap = ?',
        whereArgs: [idActividad],
      );
      print('Actividad con id $idActividad eliminada correctamente.');
    } else {
      print(
          'No se puede eliminar la actividad con id $idActividad porque ya está Completada.');
    }
  } catch (e) {
    print('Error al eliminar la actividad con id $idActividad: $e');
  }
}

// Función para obtener las horas cubiertas de un usuario (EC)
Future<int> obtenerHorasCubiertas(int ecId) async {
  final db = await database;

  try {
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT horasCubiertas 
      FROM capacitacion_inicial_movil
      WHERE ec_id = ?
    ''', [ecId]);

    if (result.isNotEmpty) {
      return result.first['horasCubiertas'] ?? 0;
    } else {
      return 0; // Si no hay registro, retorna 0
    }
  } catch (e) {
    print('Error al obtener horas cubiertas para ec_id $ecId: $e');
    return 0; // Manejo de errores
  }
}



}
