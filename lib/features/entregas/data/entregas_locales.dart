import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:mi_primer_app/core/json.dart';
import 'package:mi_primer_app/features/entregas/domain/entrega.dart';
import 'package:mi_primer_app/features/entregas/domain/entregas_repository.dart';
import 'package:mi_primer_app/features/entregas/domain/estado_entrega.dart';

/// Cómo se lee un archivo de texto. Se inyecta para poder probar sin assets.
typedef LectorDeAssets = Future<String> Function(String ruta);

class EntregasLocales implements EntregasRepository {
  EntregasLocales({
    LectorDeAssets? lector,
    this.ruta = 'assets/data/entregas.json',
  }) : _lector = lector ?? rootBundle.loadString;

  final LectorDeAssets _lector;
  final String ruta;

  List<Entrega>? _cache;

  @override
  Future<List<Entrega>> obtenerTodas() async {
    final guardado = _cache;
    if (guardado != null) return guardado;

    final crudo = await _lector(ruta);
    final decodificado = jsonDecode(crudo);

    if (decodificado is! List) {
      throw const CampoInvalido(
        '(raíz)',
        'el archivo debe contener una lista',
        null,
      );
    }

    return _cache = decodificado
        .map((e) => Entrega.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Entrega?> obtenerPorId(String id) async {
    for (final entrega in await obtenerTodas()) {
      if (entrega.id == id) return entrega;
    }
    return null;
  }

  @override
  Future<List<Entrega>> obtenerPendientes() async {
    final todas = await obtenerTodas();
    return todas.where((e) => e.estado is Registrada).toList(growable: false);
  }
}
