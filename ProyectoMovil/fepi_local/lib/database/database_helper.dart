import 'dart:convert';
import 'dart:typed_data';

import 'package:mysql1/mysql1.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  // Configuración para conectarse a la base de datos MySQL en la nube
  static final ConnectionSettings settings = ConnectionSettings(
    host: '34.118.149.167', // IP pública de Google Cloud
    port: 3306, // Puerto configurado
    user: 'root', // Usuario de la base de datos
    password: '1234567890', // Contraseña
    db: 'conafe_motor', // Nombre de la base de datos
  );

  // Base de datos local SQLite
  static Database? _localDb;

  Future<Database> get localDb async {
    if (_localDb != null) return _localDb!;
    _localDb = await _initLocalDatabase();
    return _localDb!;
  }

  Future<Database> _initLocalDatabase() async {
    String path = join(await getDatabasesPath(), 'Conafe.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
        await _createHashTable(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Usuarios (
        id_Usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT,
        password TEXT,
        rol TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Region (
        cv_region TEXT PRIMARY KEY,
        Nombre TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Microrregion (
        cv_microrregion TEXT PRIMARY KEY,
        id_Region TEXT NULL,
        Nombre TEXT,
        FOREIGN KEY (id_Region) REFERENCES Region(cv_region)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS CCT (
        id_CCT TEXT PRIMARY KEY,
        microrregion_id TEXT NULL,
        tipo_Servicio TEXT,
        Nombre TEXT,
        FOREIGN KEY (microrregion_id) REFERENCES Microrregion(cv_microrregion)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS DatosUsuarios (
        id_Datos INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Usuario INTEGER NULL,
        nombreCompleto TEXT,
        situacion_Educativa TEXT,
        contexto TEXT,
        CCT TEXT NULL,
        Region TEXT NULL,
        Microrregion TEXT NULL,
        Estado TEXT,
        Nivel TEXT,
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario),
        FOREIGN KEY (CCT) REFERENCES CCT(id_CCT),
        FOREIGN KEY (Region) REFERENCES Region(cv_region),
        FOREIGN KEY (Microrregion) REFERENCES Microrregion(cv_microrregion)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Materias (
        id_Materia INTEGER PRIMARY KEY AUTOINCREMENT,
        Grado TEXT,
        Nivel TEXT,
        Nombre TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Grupos (
        id_Grupo INTEGER PRIMARY KEY AUTOINCREMENT,
        id_CCT TEXT NULL,
        Grado TEXT,
        FOREIGN KEY (id_CCT) REFERENCES CCT(id_CCT)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Alumnos (
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
        nota TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS PromocionesAlumnos (
        id_PromocionAlumno INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Alumno INTEGER NULL,
        calfFinal INTEGER,
        tipoPromocion TEXT,
        Grado TEXT,
        Nivel TEXT,
        FOREIGN KEY (id_Alumno) REFERENCES Alumnos(id_Alumno)
      );
    ''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS Materias (
        id_Materia INTEGER PRIMARY KEY AUTOINCREMENT,
        Grado INTEGER NULL,
        Nivel TEXT NULL,
        Nombre TEXT
      );
''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Calificaciones (
        id_Calf INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Alumno INTEGER NULL,
        id_Profesor INTEGER NULL,
        id_Materia INTEGER NULL,
        calificacion INTEGER,
        Periodo INTEGER,
        FOREIGN KEY (id_Materia) REFERENCES Materias(id_Materia),
        FOREIGN KEY (id_Profesor) REFERENCES Usuarios(id_Usuario),
        FOREIGN KEY (id_Alumno) REFERENCES Alumnos(id_Alumno)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS AsignacionGrupos (
        id_AsignacionGrupo INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Grupo INTEGER NULL,
        id_Alumno INTEGER NULL,
        FOREIGN KEY (id_Alumno) REFERENCES Alumnos(id_Alumno),
        FOREIGN KEY (id_Grupo) REFERENCES Grupos(id_Grupo)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS AsignacionMaestro (
        id_AsignacionMaestro INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Grupo INTEGER NULL,
        id_Maestro INTEGER NULL,
        FOREIGN KEY (id_Grupo) REFERENCES Grupos(id_Grupo),
        FOREIGN KEY (id_Maestro) REFERENCES Usuarios(id_Usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS CCTAsignado (
        id_ACCT INTEGER PRIMARY KEY AUTOINCREMENT,
        id_CCT TEXT NULL,
        id_Microregion TEXT NULL,
        id_Usuario INTEGER NULL,
        FOREIGN KEY (id_Microregion) REFERENCES Microrregion(cv_microrregion),
        FOREIGN KEY (id_CCT) REFERENCES CCT(id_CCT),
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS MicroRegionAsignada (
        id_MicroRegionAsignada INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Microregion TEXT NULL,
        id_Region TEXT NULL,
        id_Usuario INTEGER NULL,
        FOREIGN KEY (id_Microregion) REFERENCES Microrregion(cv_microrregion)
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario),
        FOREIGN KEY (id_Region) REFERENCES Region(cv_region)

      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS RegionAsignada (
        id_RegionAsignada INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Region TEXT NULL,
        id_Usuario INTEGER NULL,
        FOREIGN KEY (id_Region) REFERENCES Region(cv_region),
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Dependencias (
        id_Dependencias INTEGER PRIMARY KEY,
        id_Dependiente INTEGER NULL,
        id_Responsable INTEGER NULL,
        FOREIGN KEY (id_Dependiente) REFERENCES Usuarios(id_Usuario),
        FOREIGN KEY (id_Responsable) REFERENCES Usuarios(id_Usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Reportes (
        id_Reporte INTEGER PRIMARY KEY AUTOINCREMENT,
        periodo TEXT,
        estado TEXT,
        reporte BLOB,
        id_usuario INTEGER NULL,
        FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_Usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ActividadAcomp (
        id_ActividadAcomp INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Usuario INTEGER NULL,
        fecha DATE,
        hora TIME,
        id_Figura TEXT NULL,
        descripcion TEXT,
        estado TEXT,
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario),
        FOREIGN KEY (id_Figura) REFERENCES Usuarios(id_Usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ReportesAcomp (
        id_ReporteAcomp INTEGER PRIMARY KEY AUTOINCREMENT,
        reporte BLOB,
        id_ActividadAcomp INTEGER NULL,
        fecha DATE,
        figuraEducativa TEXT,
        id_Usuario INTEGER NULL,
        FOREIGN KEY (id_ActividadAcomp) REFERENCES ActividadAcomp(id_ActividadAcomp),
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Asistencia (
        id_Asistencia INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Profesor INTEGER NULL,
        fecha DATE,
        usuario TEXT,
        horaEntrada TIME,
        horaSalida TIME,
        Asistencia BOOLEAN,
        FOREIGN KEY (id_Profesor) REFERENCES Usuarios(id_Usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS RegistroMoviliario (
        id_RMoviliario INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Comunidad INTEGER NULL,
        nombre TEXT,
        cantidad INTEGER,
        condicion TEXT,
        comentarios TEXT,
        periodo TEXT,
        id_Usuario INTEGER NULL,
        FOREIGN KEY (id_Comunidad) REFERENCES Comunidad(id_Comunidad),
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Recibo (
        id_Recibo INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Usuario INTEGER NULL,
        recibo BLOB,
        tipoRecibo TEXT,
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ActCAP (
        id_ActCAP INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Usuario INTEGER NULL,
        NumCapacitacion INTEGER,
        TEMA TEXT,
        id_Region TEXT NULL,
        id_Microregion TEXT NULL,
        id_CCT INTEGER NULL,
        FechaProgramada DATE,
        Estado TEXT,
        Reporte BLOB,
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario),
        FOREIGN KEY (id_Region) REFERENCES Region(cv_region),
        FOREIGN KEY (id_Microregion) REFERENCES Microrregion(cv_microrregion),
        FOREIGN KEY (id_CCT) REFERENCES CCT(id_CCT)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS PromocionFechas (
        id_PromoFechas INTEGER PRIMARY KEY AUTOINCREMENT,
        promocionPDF BLOB,
        fechas TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS PagosFechas (
        id_PagoFecha INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha DATE,
        tipoPago TEXT,
        id_UsuarioAsignante INTEGER NULL,
        monto REAL,
        id_Usuario INTEGER NULL,
        status TEXT,
        FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
        FOREIGN KEY (id_UsuarioAsignante) REFERENCES Usuarios(id_Usuario)
        
      );
    ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS SolicitudEducadores (
    id_SolicitudEducadores INTEGER PRIMARY KEY AUTOINCREMENT,
    nombreEscuela TEXT,
    id_CCT INTEGER NULL,
    tipoServicio TEXT,
    periodo TEXT,
    numEducadores INTEGER,
    justificacion TEXT,
    contexto TEXT,
    estado TEXT,
    educadoresAsignados INTEGER,
    id_Usuario INTEGER NULL,
    FOREIGN KEY (id_CCT) REFERENCES CCT(id_CCT),
    FOREIGN KEY (id_Usuario) REFERENCES Usuarios(id_Usuario)
  );
''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS CalendarioDECB (
    id_CalendarioDECB INTEGER PRIMARY KEY AUTOINCREMENT,
    evento TEXT,
    fecha DATE,
    description TEXT
  );
''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS capacitacion_inicial_movil (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ec_id INTEGER,
    eca_id INTEGER,
    horasCubiertas INTEGER,
    FOREIGN KEY (ec_id) REFERENCES Usuarios(id_Usuario),
    FOREIGN KEY (eca_id) REFERENCES Usuarios(id_Usuario)
  );
''');
    await db.execute('''
  CREATE TABLE IF NOT EXISTS ActCap_Movil (
    id_ActCap INTEGER PRIMARY KEY AUTOINCREMENT,
    actividad TEXT,
    horas INTEGER,
    ifecha_inicio TEXT,
    fecha_fin TEXT,
    estatus TEXT,
    id_asignado,
    id_responsable,
    FOREIGN KEY (id_asignado) REFERENCES Usuarios(id_Usuario),
    FOREIGN KEY (id_responsable) REFERENCES Usuarios(id_Usuario)
  );
''');
  }

  Future<void> _createHashTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS RegistroHashes (
        tabla TEXT,
        registro_id TEXT,
        hash TEXT,
        PRIMARY KEY (tabla, registro_id)
      );
    ''');
  }

  Future<bool> _isConnectedToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  String _generateHash(Map<String, dynamic> row) {
    final jsonString = jsonEncode(row);
    return base64Encode(utf8.encode(jsonString));
  }

  Future<void> descargarDatos(String tablaLocal, String sqlDescarga) async {
    final db = await localDb;

    if (await _isConnectedToInternet()) {
      final conn = await MySqlConnection.connect(settings);
      try {
        final results = await conn.query(sqlDescarga);
        await db.transaction((txn) async {
          for (var row in results) {
            Map<String, dynamic> mappedRow = {};

            // Mapea los datos descargados
            row.fields.forEach((key, value) {
              if (value is DateTime) {
                mappedRow[key] = value.toIso8601String().substring(0, 10);
              } else if (value is bool) {
                mappedRow[key] = value ? 1 : 0;
              } else {
                mappedRow[key] = value;
              }
            });

            // Obtener el nombre del campo identificador único según la tabla
            final identificador = identificadoresPorTabla[tablaLocal];
            if (identificador == null) {
              print(
                  'No se encontró un $identificador para la tabla: $tablaLocal');
              continue;
            }

            // Usar el identificador único para el registro
            final registroId = mappedRow[identificador]?.toString();
            if (registroId == null) {
              print(
                  'No se encontró un $identificador único en el registro: $mappedRow');
              continue;
            }

            final nuevoHash = _generateHash(mappedRow);

            // Verificar si el registro ya existe en la tabla de hashes
            final existingHash = await txn.rawQuery(
                'SELECT hash FROM RegistroHashes WHERE tabla = ? AND registro_id = ?',
                [tablaLocal, registroId]);

            if (existingHash.isEmpty ||
                existingHash.first['hash'] != nuevoHash) {
              try {
                // Insertar o reemplazar el registro en la tabla local
                await txn.insert(tablaLocal, mappedRow,
                    conflictAlgorithm: ConflictAlgorithm.replace);
                print('Registro insertado: $mappedRow');

                // Actualizar el hash en la tabla de hashes
                await txn.insert(
                  'RegistroHashes',
                  {
                    'tabla': tablaLocal,
                    'registro_id': registroId,
                    'hash': nuevoHash,
                  },
                  conflictAlgorithm: ConflictAlgorithm.replace,
                );
              } catch (e) {
                print('Error al insertar registro: $e');
              }
            } else {
              print('Registro ya actualizado: $mappedRow');
            }
          }
        });
        print('Datos descargados y actualizados para $tablaLocal.');
      } catch (e) {
        print('Error al descargar datos: $e');
      } finally {
        await conn.close();
      }
    } else {
      print('Sin conexión a internet. Descarga no realizada para $tablaLocal.');
    }
  }

  final Map<String, String> identificadoresPorTabla = {
    'Usuarios': 'id_Usuario',
    'Region': 'cv_region',
    'Microrregion': 'cv_microrregion',
    'CCT': 'id_CCT',
    'DatosUsuarios': 'id_Usuario',
    'Dependencias': 'id_Dependencias',
    'Grupos': 'id_Grupo',
    'Alumnos': 'id_Alumno',
    'PromocionesAlumnos': 'id_PromocionAlumno',
    'AsignacionGrupos': 'id_AsignacionGrupo',
    'AsignacionMaestro': 'id_AsignacionMaestro',
    'Reportes': 'id_Reporte',
    'ActividadAcomp': 'id_ActividadAcomp',
    'ReportesAcomp': 'id_ReporteAcomp',
    'Asistencia': 'id_Asistencia',
    'RegistroMoviliario': 'id_RMoviliario',
    'Recibo': 'idRecibo',
    'ActCAP': 'id_ActCAP',
    'SolicitudEducadores': 'id_SolicitudEducadores',
    'PagosFechas': 'id_PagoFecha',
    'CalendarioDECB': 'id_CalendarioDECB',
    'Calificaciones': 'id_Calf',
    'Materias': 'id_Materia',
    'capacitacion_inicial_movil': 'id',
    'ActCap_Movil': 'id_ActCap'

    // Agrega más tablas según sea necesario
  };

   // Si necesitas trabajar con base64
Future<void> cargarDatosManualmente(List<Map<String, dynamic>> configuraciones) async {
  final db = await localDb;

  if (await _isConnectedToInternet()) {
    final conn = await MySqlConnection.connect(settings);
    try {
      for (var config in configuraciones) {
        final tablaLocal = config['tablaLocal'];
        final sqlCarga = config['sqlCarga'];

        // Verificar si hay una sentencia SQL de carga personalizada para esta tabla
        if (sqlCarga != null && sqlCarga.isNotEmpty) {
          final localData = await db.rawQuery('SELECT * FROM $tablaLocal');
          
          // Recorrer los datos locales
          for (var row in localData) {
            // Convertir los valores de la fila a un formato adecuado para MySQL
            final convertedValues = row.map((key, value) {
              if (value == null) {
                return MapEntry(key, null); // Dejarlo como null si el valor es null
              } else if (value is String) {
                return MapEntry(key, value); // No hacer nada con las cadenas de texto
              } else if (value is DateTime) {
                return MapEntry(key, value.toIso8601String().substring(0, 19)); // Fecha en formato correcto
              } else if (value is bool) {
                return MapEntry(key, value ? 1 : 0); // Convertir bool a 1 o 0
              } else {
                return MapEntry(key, value.toString()); // Convertir otros tipos a cadena
              }
            });

            // Construir la lista de valores a pasar en la consulta
            final valuesList = convertedValues.values.toList();

            // Ejecutar la consulta de inserción
            try {
              // Realizar la consulta con los valores
              await conn.query(sqlCarga, valuesList);
              print('Cargado en MySQL: $sqlCarga');

            } catch (e) {
              print('Error cargando registro en $tablaLocal: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Error general al cargar datos: $e');
    } finally {
      await conn.close();
    }
  } else {
    print('Sin conexión a internet. Carga no realizada.');
  }
}
Future<void> cargarDatosGenerica(List<Map<String, dynamic>> configuraciones) async {
  final db = await localDb;

  if (await _isConnectedToInternet()) {
    final conn = await MySqlConnection.connect(settings);
    try {
      for (var config in configuraciones) {
        final tablaLocal = config['tablaLocal'];
        final sqlCarga = config['sqlCarga'];

        // Verificar si hay una sentencia SQL de carga personalizada para esta tabla
        if (sqlCarga != null && sqlCarga.isNotEmpty) {
          // Consultamos todos los registros de la tabla local con '*'
          final localData = await db.rawQuery('SELECT * FROM $tablaLocal');

          // Recorrer los datos locales
          for (var row in localData) {
            // Convertir los valores de la fila a un formato adecuado para MySQL
            final convertedValues = row.map((key, value) {
              if (value == null) {
                return MapEntry(key, null); // Dejarlo como null si el valor es null
              } else if (value is String) {
                return MapEntry(key, value); // No hacer nada con las cadenas de texto
              } else if (value is DateTime) {
                return MapEntry(key, value.toIso8601String().substring(0, 19)); // Fecha en formato correcto
              } else if (value is bool) {
                return MapEntry(key, value ? 1 : 0); // Convertir bool a 1 o 0
              } else {
                return MapEntry(key, value.toString()); // Convertir otros tipos a cadena
              }
            });

            // Construir la lista de valores a pasar en la consulta
            final valuesList = convertedValues.values.toList();

            // Ejecutar la consulta de inserción con la SQL personalizada
            try {
              // Realizar la consulta con los valores
              await conn.query(sqlCarga, valuesList);
              print('Cargado en MySQL: $sqlCarga');
            } catch (e) {
              print('Error cargando registro en $tablaLocal: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Error general al cargar datos: $e');
    } finally {
      await conn.close();
    }
  } else {
    print('Sin conexión a internet. Carga no realizada.');
  }
}

Future<void> cargarDatos(String tablaLocal, String sqlCarga) async {
  final db = await localDb;

  if (await _isConnectedToInternet()) {
    final conn = await MySqlConnection.connect(settings);
    try {
      final localData = await db.rawQuery('SELECT * FROM $tablaLocal');

      for (var row in localData) {
        // Generar hash del registro
        final nuevoHash = _generateHash(row);

        // Obtener el identificador único de la tabla
        final identificador = identificadoresPorTabla[tablaLocal];
        if (identificador == null) {
          print('Advertencia: No se encontró un identificador para $tablaLocal.');
          continue;
        }

        // Verificar si el registro ya existe en la tabla de hashes
        final registroId = row[identificador]?.toString();
        if (registroId == null) {
          print('Advertencia: No se encontró $identificador en el registro.');
          continue;
        }

        final existingHash = await db.rawQuery(
          'SELECT hash FROM RegistroHashes WHERE tabla = ? AND registro_id = ?',
          [tablaLocal, registroId],
        );

        // Comparar hashes
        if (existingHash.isNotEmpty && existingHash.first['hash'] == nuevoHash) {
          print('Registro ya actualizado: $row');
          continue;
        }

        // Mapea y convierte los valores de la fila
        final convertedValues = row.map((key, value) {
          if (value == null) {
            return MapEntry(key, 'NULL');
          } else if (value is String) {
            return MapEntry(key, "'${value.replaceAll("'", "''")}'");
          } else if (value is DateTime) {
            return MapEntry(key, "'${value.toIso8601String().substring(0, 19)}'");
          } else if (value is bool) {
            return MapEntry(key, value ? '1' : '0');
          } else if (value is List<int>) {
            // Convierte el valor a un Uint8List
            return MapEntry(key, Uint8List.fromList(value)); // BLOBs como Uint8List
          } else {
            return MapEntry(key, value.toString());
          }
        });

        // Construir la consulta SQL
        final columns = convertedValues.keys.join(', ');
        final values = convertedValues.values.map((e) {
          if (e is Uint8List) {
            return 'X\'${e.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join()}\'';
          } else {
            return e;
          }
        }).join(', ');

        final query = sqlCarga.isNotEmpty
            ? sqlCarga
            : '''
            INSERT INTO $tablaLocal ($columns) 
            VALUES ($values) 
            ON DUPLICATE KEY UPDATE ${convertedValues.keys.map((key) => '$key=VALUES($key)').join(', ')}
        ''';

        try {
          await conn.query(query);
          print('Cargado en MySQL: $query');

          // Actualizar el hash en la tabla de hashes
          await db.insert(
            'RegistroHashes',
            {
              'tabla': tablaLocal,
              'registro_id': registroId,
              'hash': nuevoHash,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } catch (e) {
          print('Error cargando registro en $tablaLocal: $e');
        }
      }

      print('Datos cargados para $tablaLocal.');
    } catch (e) {
      print('Error general al cargar datos: $e');
    } finally {
      await conn.close();
    }
  } else {
    print('Sin conexión a internet. Carga no realizada para $tablaLocal.');
  }
}


  Future<void> sincronizarTodo() async {
    // Definir las configuraciones para las tablas
    List<Map<String, dynamic>> configuraciones = [
      {
        'tablaLocal': 'Usuarios',
        'sqlDescarga':
            'SELECT id as id_Usuario, usuario, contrasenia as password, rol FROM usuario',
      },
      {
        'tablaLocal': 'Region',
        'sqlDescarga': 'SELECT cv_region, nombre_region as Nombre FROM region',
      },
      {
        'tablaLocal': 'Microrregion',
        'sqlDescarga':
            'SELECT cv_microrregion, nombre_microrregion as Nombre,  region_id as id_Region FROM microrregion',
      },
      {
        'tablaLocal': 'CCT',
        'sqlDescarga':
            'SELECT cv_comunidad as id_CCT, tipo_servicio as tipo_Servicio, nombre_comunidad as Nombre, microrregion_id FROM comunidad',
      },
      {
        'tablaLocal': 'DatosUsuarios',
        'sqlDescarga': '''
    SELECT 
      u.id AS id_Usuario, 
      dc.Estado,
      dc.Nivel,
      CONCAT(dp.nombre, ' ', dp.apellidopa, ' ', dp.apellidoma) AS nombreCompleto, 
      dc.situacionEducativa AS situacion_Educativa, 
      dc.contexto, 
      dc.CCT, 
      dc.Region, 
      dc.Microrregion
    FROM 
      datos_personales AS dp
    INNER JOIN 
      usuario AS u ON u.id = dp.usuario_id
    INNER JOIN 
      datos_complementarios AS dc ON u.id = dc.id_Usuario
  ''',
      },
      {
        'tablaLocal': 'Dependencias',
        'sqlDescarga':
            'SELECT id_Dependencias,id_Dependiente,id_Responsable FROM dependencias',
      },
      {
        'tablaLocal': 'Grupos',
        'sqlDescarga': 'SELECT id_Grupo, id_CCT, Grado FROM Grupos',
        'sqlCarga': '''
  INSERT INTO Grupos (id_CCT, Grado)
  VALUES (?, ?)
  ON DUPLICATE KEY UPDATE
    id_CCT = VALUES(id_CCT),
    Grado = VALUES(Grado)
'''

      },
      {
        'tablaLocal': 'Alumnos',
        'sqlDescarga':
            'SELECT id_Alumno, actaNacimiento, curp, fechaNacimiento, lugarNacimiento, domicilio, municipio, estado,certificadoEstudios, nombrePadre, ocupacionPadre, telefonoPadre, fotoVacunacion, state, nota FROM Alumnos',
        'sqlCarga': '''
    INSERT INTO Alumnos (
      id_Alumno, actaNacimiento, curp, fechaNacimiento, lugarNacimiento, domicilio,
      municipio, estado, certificadoEstudios, nombrePadre, ocupacionPadre,
      telefonoPadre, fotoVacunacion, state, nota
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      actaNacimiento = VALUES(actaNacimiento),
      curp = VALUES(curp),
      fechaNacimiento = VALUES(fechaNacimiento),
      lugarNacimiento = VALUES(lugarNacimiento),
      domicilio = VALUES(domicilio),
      municipio = VALUES(municipio),
      estado = VALUES(estado),
      certificadoEstudios = VALUES(certificadoEstudios),
      nombrePadre = VALUES(nombrePadre),
      ocupacionPadre = VALUES(ocupacionPadre),
      telefonoPadre = VALUES(telefonoPadre),
      fotoVacunacion = VALUES(fotoVacunacion),
      state = VALUES(state),
      nota = VALUES(nota)
  '''
      },
      {
        'tablaLocal': 'PromocionesAlumnos',
        'sqlDescarga':
            'SELECT id_PromocionAlumno,id_Alumno,calfFinal,tipoPromocion,Grado,Nivel FROM PromocionesAlumnos ',
        'sqlCarga': '''
    INSERT INTO PromocionesAlumnos (
      id_PromocionAlumno, id_Alumno, calfFinal, tipoPromocion, Grado, Nivel
    )
    VALUES (?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      id_Alumno = VALUES(id_Alumno),
      calfFinal = VALUES(calfFinal),
      tipoPromocion = VALUES(tipoPromocion),
      Grado = VALUES(Grado),
      Nivel = VALUES(Nivel)
  '''
      },
      {
        'tablaLocal': 'AsignacionGrupos',
        'sqlDescarga':
            'SELECT id_AsignacionGrupo,id_Grupo,id_Alumno FROM AsignacionGrupos',
      },
      {
        'tablaLocal': 'AsignacionMaestro',
        'sqlDescarga':
            'SELECT id_AsignacionMaestro,id_Grupo,id_Maestro FROM AsignacionMaestro',
      },
      {
        'tablaLocal': 'Reportes',
        'sqlCarga': '''
    INSERT INTO Reportes (
      id_Reporte, periodo, reporte, id_Usuario
    )
    VALUES (?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      periodo = VALUES(periodo),
      reporte = VALUES(reporte),
      id_Usuario = VALUES(id_Usuario)
  '''
      },
      {
        'tablaLocal': 'ActividadAcomp',
        'sqlDescarga':
            'SELECT id_ActividadAcomp, id_Usuario, fecha, hora, id_Figura, descripcion,estado FROM ActividadAcomp',
         'sqlCarga': '''
    INSERT INTO ActividadAcomp (
      id_ActividadAcomp, id_Usuario, fecha, hora, id_Figura, descripcion, estado
    )
    VALUES (?, ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      id_Usuario = VALUES(id_Usuario),
      fecha = VALUES(fecha),
      hora = VALUES(hora),
      id_Figura = VALUES(id_Figura),
      descripcion = VALUES(descripcion),
      estado = VALUES(estado)
  '''
      },
      {
        'tablaLocal': 'ReportesAcomp',
        'sqlDescarga':
            'SELECT id_ReporteAcomp, reporte,id_ActividadAcomp,Fecha,FiguraEducativa,id_Usuario FROM ReportesAcomp',
            'sqlCarga': '''
    INSERT INTO ReportesAcomp (
      id_ReporteAcomp, reporte, id_ActividadAcomp, Fecha, FiguraEducativa, id_Usuario
    )
    VALUES (?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      reporte = VALUES(reporte),
      id_ActividadAcomp = VALUES(id_ActividadAcomp),
      Fecha = VALUES(Fecha),
      FiguraEducativa = VALUES(FiguraEducativa),
      id_Usuario = VALUES(id_Usuario)
  '''
      },
      {
        'tablaLocal': 'Asistencia',
        'sqlDescarga':
            'SELECT id_Asistencia,id_Profesor,fecha,usuario,horaEntrada,horaSalida,Asistencia FROM Asistencia',
            'sqlCarga': '''
    INSERT INTO Asistencia (
      id_Asistencia, id_Profesor, fecha, usuario, horaEntrada, horaSalida, Asistencia
    )
    VALUES (?, ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      id_Profesor = VALUES(id_Profesor),
      fecha = VALUES(fecha),
      usuario = VALUES(usuario),
      horaEntrada = VALUES(horaEntrada),
      horaSalida = VALUES(horaSalida),
      Asistencia = VALUES(Asistencia)
  '''
      },
      {
        'tablaLocal': 'RegistroMoviliario',
        'sqlDescarga':
            'SELECT id_RMoviliario,id_Comunidad,nombre,cantidad,condicion,comentarios,periodo,id_Usuario FROM RegistroMoviliario',
            'sqlCarga': '''
    INSERT INTO RegistroMoviliario (
      id_RMoviliario, id_Comunidad, nombre, cantidad, condicion, comentarios, periodo, id_Usuario
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      id_Comunidad = VALUES(id_Comunidad),
      nombre = VALUES(nombre),
      cantidad = VALUES(cantidad),
      condicion = VALUES(condicion),
      comentarios = VALUES(comentarios),
      periodo = VALUES(periodo),
      id_Usuario = VALUES(id_Usuario)
  '''
      },
      {
        'tablaLocal': 'Recibo',
        'sqlDescarga':
            'SELECT idRecibo,id_Usuario,recibo,tipoRecibo FROM Recibo',
        'sqlCarga': '''
    INSERT INTO Recibo (
      idRecibo, id_Usuario, recibo, tipoRecibo
    )
    VALUES (?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      id_Usuario = VALUES(id_Usuario),
      recibo = VALUES(recibo),
      tipoRecibo = VALUES(tipoRecibo)
  '''
      },
      {
        'tablaLocal': 'ActCAP',
        'sqlDescarga':
            'SELECT id_ActCAP,id_Usuario,NumCapacitacion,TEMA,id_Region,id_Microregion,id_CCT,FechaProgramada,Estado,Reporte FROM ActCAP',
      },
      {
        'tablaLocal': 'SolicitudEducadores',
        'sqlDescarga':
            'SELECT id_SolicitudEducadores, nombreEscuela, id_CCT, tipoServicio, periodo, numEducadores, justificacion, contexto, estado,educadoresAsignados,id_Usuario FROM  SolicitudEducadores',
            'sqlCarga': '''
    INSERT INTO ActCAP (
      id_ActCAP, id_Usuario, NumCapacitacion, TEMA, id_Region, id_Microregion, id_CCT, FechaProgramada, Estado, Reporte
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      id_Usuario = VALUES(id_Usuario),
      NumCapacitacion = VALUES(NumCapacitacion),
      TEMA = VALUES(TEMA),
      id_Region = VALUES(id_Region),
      id_Microregion = VALUES(id_Microregion),
      id_CCT = VALUES(id_CCT),
      FechaProgramada = VALUES(FechaProgramada),
      Estado = VALUES(Estado),
      Reporte = VALUES(Reporte)
  '''
     
      },
      {
        'tablaLocal': 'PagosFechas',
        'sqlDescarga':
            'SELECT  id as id_PagoFecha, payment_type as tipoPago, payment_date as fecha, assigned_by_id as id_UsuarioAsignante, amount as monto, assigned_to_id as id_Usuario, status FROM  modulo_DECB_paymentschedule',
      },
      {
        'tablaLocal': 'ActCAP',
        'sqlDescarga':
            'SELECT id_ActCAP,id_Usuario,NumCapacitacion,TEMA,id_Region,id_Microregion,id_CCT,FechaProgramada,Estado,Reporte FROM ActCAP',
     'sqlCarga': '''
    INSERT INTO ActCAP (
      id_ActCAP, id_Usuario, NumCapacitacion, TEMA, id_Region, id_Microregion, id_CCT, FechaProgramada, Estado, Reporte
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      id_Usuario = VALUES(id_Usuario),
      NumCapacitacion = VALUES(NumCapacitacion),
      TEMA = VALUES(TEMA),
      id_Region = VALUES(id_Region),
      id_Microregion = VALUES(id_Microregion),
      id_CCT = VALUES(id_CCT),
      FechaProgramada = VALUES(FechaProgramada),
      Estado = VALUES(Estado),
      Reporte = VALUES(Reporte)
  '''
      },
      {
        'tablaLocal': 'CalendarioDECB',
        'sqlDescarga':
            'SELECT id as id_CalendarioDECB, event_type as evento, date as fecha, description FROM modulo_DECB_calendarevent',
      },
      {
        'tablaLocal': 'Materias',
        'sqlDescarga': 'SELECT id_Materia,Grado,Nivel,Nombre FROM Materias',
      },
      {
        'tablaLocal': 'Calificaciones',
        'sqlDescarga':
            'SELECT id_Calf,id_Alumno,id_Profesor,calificacion,id_Materia, Periodo FROM Calificaciones',
        'sqlCarga': '''
    INSERT INTO Calificaciones (
      id_Calf, id_Alumno, id_Profesor, calificacion, id_Materia, Periodo
    )
    VALUES (?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      id_Alumno = VALUES(id_Alumno),
      id_Profesor = VALUES(id_Profesor),
      calificacion = VALUES(calificacion),
      id_Materia = VALUES(id_Materia),
      Periodo = VALUES(Periodo)
  '''
      },
      {
        'tablaLocal': 'capacitacion_inicial_movil',
        'sqlDescarga': 'SELECT * FROM capacitacion_inicial_movil',
        'sqlCarga': '''
    INSERT INTO capacitacion_inicial_movil (
      id, ec_id, eca_id, horasCubiertas
    )
    VALUES (?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      ec_id = VALUES(ec_id),
      eca_id = VALUES(eca_id),
      horasCubiertas = VALUES(horasCubiertas)
  '''
      },
      {
        'tablaLocal': 'ActCap_Movil',
        'sqlDescarga': 'SELECT * FROM ActCap_Movil',
        'sqlCarga': '''
    INSERT INTO ActCap_Movil (
      id_ActCap, actividad, horas, ifecha_inicio, fecha_fin, estatus, id_asignado, id_responsable
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      actividad = VALUES(actividad),
      horas = VALUES(horas),
      ifecha_inicio = VALUES(ifecha_inicio),
      fecha_fin = VALUES(fecha_fin),
      estatus = VALUES(estatus),
      id_asignado = VALUES(id_asignado),
      id_responsable = VALUES(id_responsable)
  '''
      }
    ];
await cargarDatosGenerica(configuraciones);
    // Llamar a sincronizarTablas con las configuraciones
    await sincronizarTablas(configuraciones);
     // Cargar los datos manualmente
  await cargarDatosManualmente(configuraciones);
    print('Sincronización completa para todas las tablas.');

    // Inyecciones locales
    final db = await localDb;

    try {
      await db.transaction((txn) async {
        // Inyección para Usuarios

        // Inyección para CCT
        await txn.rawInsert('''
  INSERT INTO CCTAsignado (id_CCT, id_Usuario, id_Microregion)
  SELECT DISTINCT 
    d.CCT, 
    d.id_Usuario, 
    c.microrregion_id
  FROM DatosUsuarios d
  INNER JOIN CCT c ON d.CCT = c.id_CCT
  WHERE d.CCT IS NOT NULL AND d.id_Usuario IS NOT NULL
''');

// Inyección para MicroRegion
        await txn.rawInsert('''
  INSERT INTO MicroRegionAsignada (id_Microregion, id_Region, id_Usuario)
  SELECT DISTINCT 
    d.Microrregion, 
    m.id_Region, 
    d.id_Usuario
  FROM DatosUsuarios d
  INNER JOIN Microrregion m ON d.Microrregion = m.cv_microrregion
  WHERE d.Microrregion IS NOT NULL AND d.id_Usuario IS NOT NULL
''');

// Inyección para Region
        await txn.rawInsert('''
  INSERT INTO RegionAsignada (id_Region, id_Usuario)
  SELECT DISTINCT 
    d.Region, 
    d.id_Usuario
  FROM DatosUsuarios d
  INNER JOIN Region r ON d.Region = r.cv_region
  WHERE d.Region IS NOT NULL AND d.id_Usuario IS NOT NULL
''');

        print('Inyecciones locales completadas.');
      });
    } catch (e) {
      print('Error en las inyecciones locales: $e');
    }
  }

  Future<void> sincronizarTabla(String tablaLocal, String sqlDescarga,
      {String? sqlCarga}) async {
    await descargarDatos(tablaLocal, sqlDescarga);
    if (sqlCarga != null) {
      await cargarDatos(tablaLocal, sqlCarga);
    }
  }

  Future<void> sincronizarTablas(
      List<Map<String, dynamic>> configuraciones) async {
    for (var config in configuraciones) {
      await sincronizarTabla(
        config['tablaLocal'],
        config['sqlDescarga'],
        sqlCarga: config['sqlCarga'],
      );
    }
  }
}
