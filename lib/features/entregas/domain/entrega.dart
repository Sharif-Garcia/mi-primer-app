import 'package:mi_primer_app/core/json.dart';
import 'package:mi_primer_app/features/entregas/domain/estado_entrega.dart';
import 'package:mi_primer_app/features/entregas/domain/material.dart';

class Entrega {
  const Entrega({
    required this.id,
    required this.estudianteId,
    required this.operadorId,
    required this.material,
    required this.puntoAcopio,
    required this.creadoEn,
    required this.estado,
    this.observaciones,
  });

  factory Entrega.fromJson(Map<String, dynamic> json) => Entrega(
    id: leerTexto(json, 'id'),
    estudianteId: leerTexto(json, 'estudianteId'),
    operadorId: leerTexto(json, 'operadorId'),
    material: Material.fromJson(leerMapa(json, 'material')),
    puntoAcopio: leerTexto(json, 'puntoAcopio'),
    creadoEn: leerFecha(json, 'creadoEn'),
    estado: EstadoEntrega.fromJson(leerMapa(json, 'estado')),
    observaciones: leerTextoOpcional(json, 'observaciones'),
  );

  final String id;
  final String estudianteId;
  final String operadorId;
  final Material material;
  final String puntoAcopio;
  final DateTime creadoEn;
  final EstadoEntrega estado;
  final String? observaciones;

  Map<String, dynamic> toJson() => {
    'id': id,
    'estudianteId': estudianteId,
    'operadorId': operadorId,
    'material': material.toJson(),
    'puntoAcopio': puntoAcopio,
    'creadoEn': creadoEn.toUtc().toIso8601String(),
    'estado': estado.toJson(),
    if (observaciones != null) 'observaciones': observaciones,
  };

  bool get tieneObservaciones => observaciones != null;

  bool get sePuedeEditar => estado.sePuedeEditar;

  /// Cuántos puntos otorgó esta entrega. Cero si aún no se han asignado.
  int get puntosGanados => switch (estado) {
    PuntosAsignados(:final puntosOtorgados) => puntosOtorgados,
    Registrada() || Rechazada() => 0,
  };

  Duration antiguedad(DateTime ahora) => ahora.difference(creadoEn);

  bool estaPendienteMuchoTiempo(DateTime ahora) =>
      estado is Registrada && antiguedad(ahora) > const Duration(days: 7);

  // ── Copia ───────────────────────────────────────────────────────────────

  Entrega copyWith({
    Material? material,
    String? puntoAcopio,
    EstadoEntrega? estado,
    String? observaciones,
  }) => Entrega(
    id: id, // la identidad NO se copia con cambios
    estudianteId: estudianteId,
    operadorId: operadorId,
    material: material ?? this.material,
    puntoAcopio: puntoAcopio ?? this.puntoAcopio,
    creadoEn: creadoEn, // ni la fecha de creación
    estado: estado ?? this.estado,
    observaciones: observaciones ?? this.observaciones,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entrega &&
          other.id == id &&
          other.estudianteId == estudianteId &&
          other.operadorId == operadorId &&
          other.material == material &&
          other.puntoAcopio == puntoAcopio &&
          other.creadoEn == creadoEn &&
          other.estado == estado &&
          other.observaciones == observaciones;

  @override
  int get hashCode => Object.hash(
    id,
    estudianteId,
    operadorId,
    material,
    puntoAcopio,
    creadoEn,
    estado,
    observaciones,
  );

  @override
  String toString() => 'Entrega($id, $material, ${estado.etiqueta})';
}
