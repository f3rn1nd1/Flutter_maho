class User {
  final int? id;
  final String? name;
  final String? email;
  final String? estado;
  final String? rol;
  final String? ultimaConexion;
  final String? telefono;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? admin;
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
    required this.anexo,
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
      admin:
          json['admin'].toString(), // Convertir a String por si es int o bool
      anexo: json['anexo'],
    );
  }

  // Método para convertir un objeto User en JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    // Añadir solo los atributos que no son null o "null"
    if (id != null) data['id'] = id;
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (estado != null) data['estado'] = estado;
    if (rol != null) data['rol'] = rol;
    if (ultimaConexion != null) data['ultima_conexion'] = ultimaConexion;
    if (telefono != null) data['telefono'] = telefono;
    if (emailVerifiedAt != null) data['email_verified_at'] = emailVerifiedAt;
    if (createdAt != null) data['created_at'] = createdAt;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    if (deletedAt != null) data['deleted_at'] = deletedAt;
    if (admin != null && admin != "null") data['admin'] = admin; // Excluir si es "null"
    if (anexo != null) data['anexo'] = anexo;

    return data;
  }
}
