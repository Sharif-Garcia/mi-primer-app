import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primer_app/core/json.dart';
import 'package:mi_primer_app/features/entregas/domain/entrega.dart';
import 'package:mi_primer_app/features/entregas/domain/estado_entrega.dart';
import 'package:mi_primer_app/features/entregas/domain/material.dart';

Entrega ejemplo({EstadoEntrega? estado, String? observaciones}) => Entrega(
  id: 'ent-001',
  estudianteId: 'est-2021145',
  operadorId: 'op-003',
  material: const Material(tipo: 'plastico', pesoKg: 2.5),
  puntoAcopio: 'Bloque C - UPC',
  creadoEn: DateTime.utc(2026, 8, 10, 14, 20),
  estado: estado ?? Registrada(DateTime.utc(2026, 8, 10, 14, 20)),
  observaciones: observaciones,
);

void main() {
  group('serialización', () {
    test('una entrega sobrevive la ida y vuelta a JSON sin perder nada', () {
      final original = ejemplo(
        estado: PuntosAsignados(41, DateTime.utc(2026, 8, 11, 16, 0)),
        observaciones: 'Cartón compactado en bolsa.',
      );

      // Pasa por TEXTO, no solo por Map: así también se prueba que las
      // fechas sobreviven a jsonEncode.
      final texto = jsonEncode(original.toJson());
      final vuelta = Entrega.fromJson(
        jsonDecode(texto) as Map<String, dynamic>,
      );

      expect(vuelta, equals(original));
    });

    test(
      'una entrega sin la clave observaciones se lee con observaciones nula',
      () {
        final json = ejemplo().toJson()..remove('observaciones');
        expect(Entrega.fromJson(json).observaciones, isNull);
      },
    );

    test(
      'una entrega sin puntoAcopio dice QUÉ campo falló, no solo que falló',
      () {
        final json = ejemplo().toJson()..remove('puntoAcopio');

        expect(
          () => Entrega.fromJson(json),
          throwsA(
            isA<CampoInvalido>().having((e) => e.campo, 'campo', 'puntoAcopio'),
          ),
        );
      },
    );

    test('una fecha que no es ISO 8601 se rechaza', () {
      final json = ejemplo().toJson()..['creadoEn'] = '10 de agosto';
      expect(() => Entrega.fromJson(json), throwsA(isA<CampoInvalido>()));
    });

    test('la hora se conserva en UTC y no se corre cinco horas', () {
      final json = ejemplo().toJson();
      expect(json['creadoEn'], '2026-08-10T14:20:00.000Z');
    });
  });

  group('igualdad', () {
    test('dos entregas con los mismos datos son iguales', () {
      expect(ejemplo(), equals(ejemplo()));
    });

    test('dos entregas con los mismos datos comparten hashCode', () {
      // Sin esto, meterlas en un Set daría dos elementos donde debería haber uno.
      expect(ejemplo().hashCode, equals(ejemplo().hashCode));
      expect({ejemplo(), ejemplo()}.length, 1);
    });

    test('dos entregas con materiales distintos NO son iguales', () {
      expect(
        ejemplo(),
        isNot(
          equals(
            Entrega(
              id: 'ent-001',
              estudianteId: 'est-2021145',
              operadorId: 'op-003',
              material: const Material(tipo: 'vidrio', pesoKg: 1.0),
              puntoAcopio: 'Bloque C - UPC',
              creadoEn: DateTime.utc(2026, 8, 10, 14, 20),
              estado: Registrada(DateTime.utc(2026, 8, 10, 14, 20)),
            ),
          ),
        ),
      );
    });

    test('copyWith cambia solo lo que se le pasa', () {
      final original = ejemplo();
      final copia = original.copyWith(puntoAcopio: 'Bloque A - UPC');

      expect(copia.puntoAcopio, 'Bloque A - UPC');
      expect(copia.id, original.id);
      expect(copia.creadoEn, original.creadoEn);
    });
  });

  group('reglas de negocio', () {
    test('una entrega con puntos asignados no se puede editar', () {
      expect(
        ejemplo(
          estado: PuntosAsignados(41, DateTime.utc(2026, 8, 11, 16, 0)),
        ).sePuedeEditar,
        isFalse,
      );
    });

    test('una entrega registrada sí se puede editar', () {
      expect(
        ejemplo(
          estado: Registrada(DateTime.utc(2026, 8, 10, 14, 20)),
        ).sePuedeEditar,
        isTrue,
      );
    });

    test('una entrega rechazada no otorga puntos', () {
      expect(
        ejemplo(estado: const Rechazada('material mezclado')).puntosGanados,
        0,
      );
    });

    test('una entrega registrada hace 10 días está pendiente mucho tiempo', () {
      final ahora = DateTime.utc(2026, 8, 20, 14, 20);
      expect(
        ejemplo(
          estado: Registrada(DateTime.utc(2026, 8, 10, 14, 20)),
        ).estaPendienteMuchoTiempo(ahora),
        isTrue,
      );
    });

    test('la etiqueta de un rechazo incluye el motivo', () {
      expect(
        const Rechazada('material mezclado').etiqueta,
        contains('material mezclado'),
      );
    });
  });
}
