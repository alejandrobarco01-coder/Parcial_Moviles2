class Establecimiento {
  final int id;
  final String nombre;
  final String nit;
  final String direccion;
  final String telefono;
  final String logo;

  Establecimiento({
    required this.id,
    required this.nombre,
    required this.nit,
    required this.direccion,
    required this.telefono,
    required this.logo,
  });

  factory Establecimiento.fromJson(Map<String, dynamic> json) {
    String logoUrl = json['logo']?.toString() ?? '';
    if (logoUrl.isNotEmpty && !logoUrl.startsWith('http')) {
      logoUrl = 'https://parking.visiontic.com.co/logos/$logoUrl';
    }

    return Establecimiento(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      nit: json['nit']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      logo: logoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'nit': nit,
      'direccion': direccion,
      'telefono': telefono,
      'logo': logo,
    };
  }
}
