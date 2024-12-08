// Archivo: lib/JsonModels/users.dart

class Users {
  final int? usrId;  // El signo de interrogación indica que puede ser nulo.
  final String usrName;
  final String usrPassword;

  Users({this.usrId, required this.usrName, required this.usrPassword});

  // Convierte el objeto Users a un Map para insertar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'usrId': usrId,
      'usrName': usrName,
      'usrPassword': usrPassword,
    };
  }

  // Método para crear un Users a partir de un Map
  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      usrId: map['usrId'],
      usrName: map['usrName'],
      usrPassword: map['usrPassword'],
    );
  }
}
