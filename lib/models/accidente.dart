class Accidente {
  final String? claseDeAccidente;
  final String? gravedadDelAccidente;
  final String? barrioHecho;
  final String? dia;
  final String? hora;
  final String? area;
  final String? claseDeVehiculo;

  Accidente({
    this.claseDeAccidente,
    this.gravedadDelAccidente,
    this.barrioHecho,
    this.dia,
    this.hora,
    this.area,
    this.claseDeVehiculo,
  });

  factory Accidente.fromJson(Map<String, dynamic> json) {
    return Accidente(
      claseDeAccidente: json['clase_de_accidente']?.toString(),
      gravedadDelAccidente: json['gravedad_del_accidente']?.toString(),
      barrioHecho: json['barrio_hecho']?.toString(),
      dia: json['dia']?.toString(),
      hora: json['hora']?.toString(),
      area: json['area']?.toString(),
      claseDeVehiculo: json['clase_de_vehiculo']?.toString(),
    );
  }
}
