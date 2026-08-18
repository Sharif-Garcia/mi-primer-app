import 'package:mi_primer_app/core/json.dart';

/// En qué punto de su vida está una entrega de material reciclable.
///
/// `sealed` significa dos cosas: nadie fuera de este archivo puede añadir un
/// estado, y el compilador conoce la lista completa. Eso es lo que hace que
/// los `switch` de abajo puedan ser exhaustivos sin `default`.
sealed class EstadoEntrega {
  const EstadoEntrega();

  /// El ÚNICO sitio donde un texto del JSON se convierte en un tipo.
  factory EstadoEntrega.fromJson(Map<String, dynamic> json) {
    final tipo = leerTexto(json, 'tipo');
    return switch (tipo) {
      'registrada' => Registrada(leerFecha(json, 'registradaEn')),
      'puntos_asignados' => PuntosAsignados(
        leerEntero(json, 'puntosOtorgados'),
        leerFecha(json, 'asignadoEn'),
      ),
      'rechazada' => Rechazada(leerTexto(json, 'motivo')),
      _ => throw CampoInvalido('estado.tipo', 'no es un estado conocido', tipo),
    };
  }

  /// Y el único sitio donde vuelve a ser texto. Simétrico a fromJson: si
  /// añades un estado arriba y olvidas añadirlo aquí, esto no compila.
  Map<String, dynamic> toJson() => switch (this) {
    Registrada(:final registradaEn) => {
      'tipo': 'registrada',
      'registradaEn': registradaEn.toIso8601String(),
    },
    PuntosAsignados(:final puntosOtorgados, :final asignadoEn) => {
      'tipo': 'puntos_asignados',
      'puntosOtorgados': puntosOtorgados,
      'asignadoEn': asignadoEn.toIso8601String(),
    },
    Rechazada(:final motivo) => {'tipo': 'rechazada', 'motivo': motivo},
  };

  /// Regla de negocio:  el operador todavía puede modificar el registro.
  bool get sePuedeEditar => switch (this) {
    Registrada() => true,
    PuntosAsignados() || Rechazada() => false,
  };

  /// Texto para la pantalla.
  String get etiqueta => switch (this) {
    Registrada() => 'Registrada',
    PuntosAsignados(:final puntosOtorgados) =>
      'Puntos asignados · $puntosOtorgados pts',
    Rechazada(:final motivo) => 'Rechazada: $motivo',
  };
}

final class Registrada extends EstadoEntrega {
  const Registrada(this.registradaEn);

  final DateTime registradaEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Registrada && other.registradaEn == registradaEn;

  @override
  int get hashCode => Object.hash(runtimeType, registradaEn);

  @override
  String toString() => 'Registrada($registradaEn)';
}

final class PuntosAsignados extends EstadoEntrega {
  const PuntosAsignados(this.puntosOtorgados, this.asignadoEn);
  final int puntosOtorgados;
  final DateTime asignadoEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PuntosAsignados &&
          other.puntosOtorgados == puntosOtorgados &&
          other.asignadoEn == asignadoEn;

  @override
  int get hashCode => Object.hash(runtimeType, puntosOtorgados, asignadoEn);

  @override
  String toString() => 'PuntosAsignados($puntosOtorgados, $asignadoEn)';
}

final class Rechazada extends EstadoEntrega {
  const Rechazada(this.motivo) : assert(motivo != '', 'rechazar exige motivo');
  final String motivo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Rechazada && other.motivo == motivo;

  @override
  int get hashCode => Object.hash(runtimeType, motivo);

  @override
  String toString() => 'Rechazada($motivo)';
}
