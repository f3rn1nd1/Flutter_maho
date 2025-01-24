class User {
  final int id;
  final String name;
  final String email;
  final String estado;
  final String rol;
  final String ultimaConexion;
  final String telefono;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String admin;
  final String? anexo;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.estado,
    required this.rol,
    required this.ultimaConexion,
    required this.telefono,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.admin,
    this.anexo,
  });

  // Método para convertir JSON en un objeto User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      estado: json['estado'],
      rol: json['rol'],
      ultimaConexion: json['ultima_conexion'],
      telefono: json['telefono'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      admin: json['admin'].toString(), // Convertir a String por si es int o bool
      anexo: json['anexo'],
    );
  }

  // Método para convertir un objeto User en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'estado': estado,
      'rol': rol,
      'ultima_conexion': ultimaConexion,
      'telefono': telefono,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'admin': admin,
      'anexo': anexo,
    };
  }
}