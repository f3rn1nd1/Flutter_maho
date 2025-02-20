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
    this.id,
    this.name,
    this.email,
    this.estado,
    this.rol,
    this.ultimaConexion,
    this.telefono,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.admin,
    this.anexo,
  });

  // Método para convertir JSON en un objeto User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] != null ? json['id'] as int : null,
      name: json['name'] != null ? json['name'] as String : null,
      email: json['email'] != null ? json['email'] as String : null,
      estado: json['estado'] != null ? json['estado'] as String : null,
      rol: json['rol'] != null ? json['rol'] as String : null,
      ultimaConexion: json['ultima_conexion'] != null
          ? json['ultima_conexion'] as String
          : null,
      telefono: json['telefono'] != null ? json['telefono'] as String : null,
      emailVerifiedAt: json['email_verified_at'] != null
          ? json['email_verified_at'] as String
          : null,
      createdAt:
          json['created_at'] != null ? json['created_at'] as String : null,
      updatedAt:
          json['updated_at'] != null ? json['updated_at'] as String : null,
      deletedAt:
          json['deleted_at'] != null ? json['deleted_at'] as String : null,
      admin: json['admin'] != null ? json['admin'].toString() : null,
      anexo: json['anexo'] != null ? json['anexo'] as String : null,
    );
  }

  // Método para convertir un objeto User en JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    // Solo incluir los campos que no son null
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
    if (admin != null) data['admin'] = admin;
    if (anexo != null) data['anexo'] = anexo;

    return data;
  }
}
