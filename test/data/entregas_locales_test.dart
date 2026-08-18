import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mi_primer_app/core/json.dart';
import 'package:mi_primer_app/features/entregas/data/entregas_locales.dart';

const _json = '''
[
  {
    "id": "ent-001",
    "estudianteId": "est-2021145",
    "operadorId": "op-003",
    "material": { "tipo": "plastico", "pesoKg": 2.5 },
    "puntoAcopio": "Bloque C - UPC",
    "creadoEn": "2026-08-10T14:20:00Z",
    "estado": { "tipo": "registrada", "registradaEn": "2026-08-10T14:20:00Z" }
  }
]
''';

void main() {
  test('lee la lista completa del archivo', () async {
    final repo = EntregasLocales(lector: (_) async => _json);
    expect((await repo.obtenerTodas()).length, 1);
  });

  test('busca por id y devuelve null cuando no está', () async {
    final repo = EntregasLocales(lector: (_) async => _json);

    expect((await repo.obtenerPorId('ent-001'))?.puntoAcopio, 'Bloque C - UPC');
    expect(await repo.obtenerPorId('no-existe'), isNull);
  });

  test('un archivo que no es una lista se rechaza', () async {
    final repo = EntregasLocales(lector: (_) async => '{"a": 1}');
    expect(repo.obtenerTodas(), throwsA(isA<CampoInvalido>()));
  });

  test(
    'obtenerPendientes devuelve solo las entregas en estado registrada',
    () async {
      final repo = EntregasLocales(lector: (_) async => _json);
      final pendientes = await repo.obtenerPendientes();

      expect(pendientes.length, 1);
      expect(pendientes.first.id, 'ent-001');
    },
  );

  test(
    'el asset declarado en pubspec existe y el modelo lo entiende',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final repo = EntregasLocales(lector: rootBundle.loadString);
      expect((await repo.obtenerTodas()).length, greaterThanOrEqualTo(3));
    },
  );
}
