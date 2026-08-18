import 'package:mi_primer_app/core/json.dart';

// Qué se entregó y cuánto pesa.
// Es un **objeto de valor**: dos entregas con el mismo tipo y peso
// describen el mismo material, así que no lleva `id` y se compara
/// por contenido.

class Material {
  final String tipo;
  final double pesoKg;

  const Material({required this.tipo, required this.pesoKg})
    : assert(pesoKg > 0, 'el peso debe ser maypr que cero');

  factory Material.fromJson(Map<String, dynamic> json) => Material(
    tipo: leerTexto(json, 'tipo'),
    pesoKg: leerDecimal(json, 'pesoKg'),
  );

  Map<String, dynamic> toJson() => {'tipo': tipo, 'pesoKg': pesoKg};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Material && other.tipo == tipo && other.pesoKg == pesoKg;

  @override
  int get hashCode => Object.hash(tipo, pesoKg);

  @override
  String toString() => 'Material($tipo, ${pesoKg}Kg)';
}
