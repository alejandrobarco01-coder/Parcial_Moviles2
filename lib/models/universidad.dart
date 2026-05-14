// lib/models/universidad.dart
// Modelo de datos para una universidad almacenada en Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';

class Universidad {
  /// ID del documento Firestore (opcional, null antes de guardar).
  final String? id;
  final String nit;
  final String nombre;
  final String direccion;
  final String telefono;
  /// En Firestore se persiste como `pagina_web`.
  final String paginaWeb;

  const Universidad({
    this.id,
    required this.nit,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.paginaWeb,
  });

  /// Crea una instancia a partir de un DocumentSnapshot de Firestore.
  factory Universidad.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Universidad(
      id: doc.id,
      nit: data['nit']?.toString() ?? '',
      nombre: data['nombre']?.toString() ?? '',
      direccion: data['direccion']?.toString() ?? '',
      telefono: data['telefono']?.toString() ?? '',
      paginaWeb: data['pagina_web']?.toString() ?? '',
    );
  }

  /// Convierte la instancia a un mapa para escribir en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'nit': nit,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'pagina_web': paginaWeb,
    };
  }
}
