import 'dart:typed_data';
import 'package:fepi_local/database/database_gestor.dart';
import 'package:flutter/services.dart'; // Necesario para rootBundle

Future<Uint8List> loadPdfFromAssets(String filename) async {

  final ByteData data = await rootBundle.load('lib/assets/ReciboMateriales.pdf');
  return data.buffer.asUint8List();
}

Future<Uint8List> loadImageFromAssets(String filename) async {
  final ByteData data = await rootBundle.load('lib/assets/logo.png');
  return data.buffer.asUint8List();
}

Future<void> insertMassiveDataForAllTables() async {
  final dbhelper = DatabaseHelper();
  final db = await dbhelper.database;

  // Función auxiliar para formatear fechas
  String formatDate(int year, int month, int day) {
    final formattedMonth = month.toString().padLeft(2, '0');
    final formattedDay = day.toString().padLeft(2, '0');
    return '$year-$formattedMonth-$formattedDay';
  }

// 1. Insertar datos en Region
for (int i = 1; i <= 2; i++) {
    await db.insert('Region', {
      'Nombre': 'Region $i',
    });
  }

// 1. Insertar datos en Microregion
  for (int i = 1; i <= 5; i++) {
    await db.insert('Microrregion', {
      'id_Region': 1,
      'Nombre': 'Microregion $i',
    });
  }


  // 1. Insertar datos en Comunidad
  for (int i = 1; i <= 5; i++) {
    await db.insert('Comunidad', {
      'id_Microregion': i,
      'Nombre': 'Comunidad $i',
    });
  }

  // Insertar datos en CCT
  for (int i = 1; i <= 5; i++) {
    await db.insert('CCT', {
      'claveCCT': 'ClaveCCT-$i',
      'id_Comunidad': i,
      'tipo_Servicio': 'Primaria',
      'Nombre':'Nombre CT-$i' 
    });
  }



  // 2. Insertar datos en DatosUsuarios
  for (int i = 1; i <= 20; i++) {
    await db.insert('DatosUsuarios', {
      'nombreCompleto': 'Nombre Completo $i',
      'situacion_Educativa': 'Nivel $i',
      'contexto': 'Contexto $i',
      'nivel': 'Nivel $i',
      'Estado': i % 2 == 0 ? 0 : 1,
    });
  }
  

  // 3. Insertar datos en Usuarios
  List<String> roles = ['APEC', 'ECAR', 'ECA', 'EC'];
  List<int> apecUsers = [];
  List<int> ecarUsers = [];
  List<int> ecaUsers = [];
  List<int> ecUsers = [];

  for (int i = 1; i <= 20; i++) {
    String role = roles[i % roles.length];
    int userId = await db.insert('Usuarios', {
      'usuario': 'usuario$i',
      'password': 'password$i',
      'rol': role,
      'id_Datos': i,
    });

    if (role == 'APEC') apecUsers.add(userId);
    if (role == 'ECAR') ecarUsers.add(userId);
    if (role == 'ECA') ecaUsers.add(userId);
    if (role == 'EC') ecUsers.add(userId);
  }

  //////////////////
   // Insertar datos en RegionAsignada: solo ECAR
  for (int ecarId in ecarUsers) {
    await db.insert('RegionAsignada', {
      'id_Region': (ecarUsers.indexOf(ecarId) % 2) + 1, // Asignar a una región
      'id_Usuario': ecarId,
    });
  }

  // Insertar datos en MicroregionAsignada: solo ECA
  for (int ecaId in ecaUsers) {
    await db.insert('MicroRegionAsignada', {
      'id_Microregion': (ecaUsers.indexOf(ecaId) % 5) + 1, // Asignar a una microregión
      'id_Usuario': ecaId,
    });
  }

  // Insertar datos en CCTAsignado: solo APEC y EC
  for (int i = 1; i <= 5; i++) {
    for (int userId in [...apecUsers, ...ecUsers]) {
      await db.insert('CCTAsignado', {
        'id_CCT': i, // Asignar a CCT existente
        'id_Usuario': userId,
      });
    }
  }
  /////////////////

  // 4. Insertar datos en Dependencias
  for (int ecarId in ecarUsers) {
    for (int ecaId in ecaUsers) {
      await db.insert('Dependencias', {
        'id_Dependiente': ecaId,
        'id_Responsable': ecarId,
      });
    }
  }

  for (int ecaId in ecaUsers) {
    for (int ecId in ecUsers) {
      await db.insert('Dependencias', {
        'id_Dependiente': ecId,
        'id_Responsable': ecaId,
      });
    }
  }

  for (int ecId in ecUsers) {
    for (int apecId in apecUsers) {
      await db.insert('Dependencias', {
        'id_Dependiente': ecId,
        'id_Responsable': apecId,
      });
    }
  }


  // Inserción en `Grupos`
  for (int i = 1; i <= 5; i++) {
    await db.insert('Grupos', {
      'Nivel': 'Primaria',
      'Grado': 'Grado $i',
    });
  }

  // Inserción en `Alumnos`
  for (int i = 1; i <= 10; i++) {
    await db.insert('Alumnos', {
      'curp': 'CURP${1000 + i}',
      'fechaNacimiento': '2010-01-${i.toString().padLeft(2, '0')}',
      'lugarNacimiento': 'Lugar $i',
      'domicilio': 'Domicilio $i',
      'municipio': 'Municipio $i',
      'estado': 'Estado $i',
      'nombrePadre': 'Padre $i',
      'ocupacionPadre': 'Ocupación $i',
      'telefonoPadre': '123456789$i',
      'state': 'pendiente',
      'nota': 'Nota $i',
    });
  }

  // Inserción en `AsignacionGrupos`
  for (int i = 1; i <= 10; i++) {
    await db.insert('AsignacionGrupos', {
      'id_Grupo': i,
      'id_Alumno': i,
    });
  }

  // Inserción en `AsignacionMaestro`
  for (int i = 1; i <= 5; i++) {
    await db.insert('AsignacionMaestro', {
      'id_Grupo': i,
      'id_Maestro': (i % 3) + 1, // Asignar maestros de ejemplo
    });
  }

  // Inserción en `PromocionesAlumnos`
  for (int i = 1; i <= 10; i++) {
    await db.insert('PromocionesAlumnos', {
      'id_Alumno': i,
      'calfFinal': 80 + (i % 20),
      'tipoPromocion': 'Ordinaria',
      'Grado': 'Grado ${(i % 6) + 1}',
      'Nivel': 'Primaria',
    });
  }
  for(int i=1; i<=6; i++){
    await db.insert('Materias', {
      'Nombre': 'Materia 1: $i', // Calificaciones entre 5 y 10
      'Grado': 'Grado ${(i % 6) + 1}',
      'Nivel': 'Primaria',
    });
  }

  // Inserción en `Calificaciones`
  for (int i = 1; i <= 10; i++) {
    await db.insert('Calificaciones', {
      'id_Alumno': i,
      'id_Materia': i,
      'calificacion': (i % 10) + 5, // Calificaciones entre 5 y 10
    });
  }


  // 6. Insertar fechas de pago
  for (int userId in [...apecUsers, ...ecarUsers, ...ecaUsers, ...ecUsers]) {
    for (int i = 1; i <= 5; i++) {
      await db.insert('PagosFechas', {
        'fecha': formatDate(2022, 1, (i % 28) + 1),
        'tipoPago': 'Mensual',
        'monto': (i * 1000).toDouble(),
        'id_Usuario': userId,
      });

      await db.insert('PagosFechas', {
        'fecha': formatDate(2025, 2, (i)),
        'tipoPago': 'Mensual',
        'monto': (i * 1000).toDouble(),
        'id_Usuario': userId,
      });
    }
  }

  await db.insert('CalendarioDECB', {
    'evento':'RM11',
    'fecha':'2025-01-13'

    });
  await db.insert('CalendarioDECB', {
    'evento':'RM2',
    'fecha':'2025-02-10'

    });

  // 7. ActCAP
  /*for (int i = 1; i <= 10; i++) {
    int creatorId = (i % 2 == 0) ? ecarUsers[i % ecarUsers.length] : ecaUsers[i % ecaUsers.length];
    await db.insert('ActCAP', {
      'id_Usuario': creatorId,
      'NumCapacitacion': i,
      'TEMA': 'Tema Capacitación $i',
      'ClaveRegion': 'CR${i}',
      'NombreRegion': 'Región Capacitación $i',
      'FechaProgramada': formatDate(2023, 5, (i % 28) + 1),
      'Estado': ['Pendiente', 'Aprobado', 'Completado'][i % 3],
      'Reporte': 'Reporte de Capacitación $i',
    });
  }*/

  // 8. Recibo
  for (int i = 1; i <= 20; i++) {
    await db.insert('Recibo', {
      'id_Usuario': ecUsers[i % ecUsers.length],
      'recibo': await loadPdfFromAssets('recibo.pdf'),
      'tipoRecibo': ['Mensual', 'Anual', 'Especial'][i % 3],
    });
  }

  // 9. RegistroMoviliario
  for (int i = 1; i <= 10; i++) {
    await db.insert('RegistroMoviliario', {
      'id_Comunidad': (i % 5) + 1,
      'nombre': 'Mobiliario $i',
      'cantidad': (i % 10) + 1,
      'condicion': ['Bueno', 'Regular', 'Malo'][i % 3],
      'comentarios': 'Comentario sobre el mobiliario $i',
      'periodo': '2023',
      'id_Usuario': apecUsers[i % apecUsers.length],
    });
  }

  // 10. ActividadAcomp
  for (int i = 1; i <= 20; i++) {
    List asignatorId= [...ecaUsers, ...ecUsers];
    for (int asignado in asignatorId){
    int creatorId = (i % 2 == 0) ? ecarUsers[i % ecarUsers.length] : ecaUsers[i % ecaUsers.length];
    await db.insert('ActividadAcomp', {
      'id_Usuario': creatorId,
      'fecha': formatDate(2023, 2, (i % 28) + 1),
      'hora': '10:00:00',
      'id_Figura': asignado,
      'descripcion': 'Descripción de actividad acompañamiento $i',
      'estado': i % 2 == 0 ? 'activo' : 'inactivo',
    });}
  }

  // 11. ReportesAcomp
  for (int i = 1; i <= 20; i++) {
    int creatorId = (i % 2 == 0) ? ecarUsers[i % ecarUsers.length] : ecaUsers[i % ecaUsers.length];
    await db.insert('ReportesAcomp', {
      'reporte': await loadPdfFromAssets('reporte_acomp.pdf'),
      'id_ActividadAcomp': i,
      'fecha': formatDate(2023, 3, (i % 28) + 1),
      'figuraEducativa': 'Figura Educativa $i',
      'id_Usuario': creatorId,
    });
  }

  // 12. Asistencia
  for (int i = 1; i <= 20; i++) {
    int profesorId = i;
    await db.insert('Asistencia', {
      'id_Profesor': profesorId,
      'fecha': formatDate(2023, 4, (i % 28) + 1),
      'usuario': 'usuario$i',
      'horaEntrada': '08:${i % 60}',
      'horaSalida': '16:${i % 60}',
      'Asistencia': i % 2 == 0 ? 1 : 0,
    });
  }

  

  // 15. Reportes
  for (int i = 1; i <= 20; i++) {
    await db.insert('Reportes', {
      'periodo': 'Periodo $i',
      'estado': ['pendiente', 'aprobado', 'rechazado'][i % 3],
      'reporte': await loadPdfFromAssets('reporte.pdf'),
      'id_usuario': ecUsers[i % ecUsers.length],
    });
  }

  // 16. PromocionFechas
  for (int i = 1; i <= 10; i++) {
    await db.insert('PromocionFechas', {
      'promocionPDF': await loadPdfFromAssets('promocion.pdf'),
      'fechas': '2023-${(i % 12) + 1}-${(i % 28) + 1}',
    });
  }
}
