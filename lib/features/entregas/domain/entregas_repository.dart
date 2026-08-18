import 'package:mi_primer_app/features/entregas/domain/entrega.dart';

abstract interface class EntregasRepository {
  Future<List<Entrega>> obtenerTodas();

  Future<Entrega?> obtenerPorId(String id);

  /// Entregas que aún no han sido evaluadas por el operador.
  Future<List<Entrega>> obtenerPendientes();
}
