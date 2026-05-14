// lib/services/universidad_service.dart
// Servicio CRUD para la colección "universidades" en Cloud Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/universidad.dart';

class UniversidadService {
  final CollectionReference _col =
      FirebaseFirestore.instance.collection('universidades');

  // ── Lectura en tiempo real ────────────────────────────────────────────────

  /// Devuelve un stream que emite la lista actualizada cada vez que
  /// la colección cambia en Firestore.
  Stream<List<Universidad>> getUniversidades() {
    return _col.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Universidad.fromFirestore(doc))
          .toList();
    });
  }

  // ── Escritura ─────────────────────────────────────────────────────────────

  /// Crea un nuevo documento en la colección.
  Future<void> crearUniversidad(Universidad u) async {
    try {
      await _col.add(u.toMap());
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException al crear universidad: ${e.message}');
      throw Exception('Error al guardar la universidad: ${e.message}');
    } catch (e) {
      debugPrint('Error inesperado al crear universidad: $e');
      throw Exception('Error inesperado al guardar la universidad: $e');
    }
  }

  /// Actualiza un documento existente por su [id].
  Future<void> actualizarUniversidad(String id, Universidad u) async {
    try {
      await _col.doc(id).update(u.toMap());
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException al actualizar universidad: ${e.message}');
      throw Exception('Error al actualizar la universidad: ${e.message}');
    } catch (e) {
      debugPrint('Error inesperado al actualizar universidad: $e');
      throw Exception('Error inesperado al actualizar la universidad: $e');
    }
  }

  /// Elimina el documento con el [id] dado.
  Future<void> eliminarUniversidad(String id) async {
    try {
      await _col.doc(id).delete();
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException al eliminar universidad: ${e.message}');
      throw Exception('Error al eliminar la universidad: ${e.message}');
    } catch (e) {
      debugPrint('Error inesperado al eliminar universidad: $e');
      throw Exception('Error inesperado al eliminar la universidad: $e');
    }
  }

  // ── Sembrado de datos ─────────────────────────────────────────────────────

  /// Si la colección está vacía, inserta el dato de ejemplo requerido.
  Future<void> sembrarSiVacia() async {
    try {
      final snapshot = await _col.limit(1).get();
      if (snapshot.docs.isEmpty) {
        await crearUniversidad(
          const Universidad(
            nit: '890.123.456-7',
            nombre: 'UCEVA',
            direccion: 'Cra 27A #48-144, Tuluá - Valle',
            telefono: '+57 602 2242202',
            paginaWeb: 'https://www.uceva.edu.co',
          ),
        );
        debugPrint('Dato semilla "UCEVA" insertado en Firestore.');
      }
    } catch (e) {
      debugPrint('Error al sembrar datos iniciales: $e');
    }
  }
}
