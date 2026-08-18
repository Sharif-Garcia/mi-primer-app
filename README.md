# EJEMPLO CON CIRCLOOP · Módulo de Entregas

Plataforma de devolución y recompensa por reciclaje para la Universidad
Popular del Cesar. Este módulo modela el registro de entregas de material
reciclable hechas por la comunidad universitaria y validadas por un
operador de acopio.

## El dominio

- `Entrega` — entidad principal. Identidad: `id`.
- `Material` — objeto de valor (tipo + peso en kg).
- `EstadoEntrega` — sellada: `Registrada` · `PuntosAsignados` · `Rechazada`.

Decisión: modelo escrito a mano, sin freezed (ver justificación abajo).

## Cómo correrlo

    flutter pub get
    flutter test
    flutter run

## Decisiones de diseño

### Sobre freezed

Elegí lo escrito a mano por dos razones principales. Primero, el
proyecto está en una etapa donde entender cada pieza del modelo
(constructor, `fromJson`, `toJson`, igualdad, `copyWith`) resulta más
valioso que ahorrar líneas de código, especialmente porque este dominio
seguirá creciendo en semanas posteriores. Segundo, y de forma más
concreta, la versión manual conserva los mensajes de error detallados de
`CampoInvalido`, que indican exactamente qué campo del JSON falló y por
qué; al generar el `fromJson` con `json_serializable`, ese detalle se
pierde y el error vuelve a ser el genérico de Dart (`type 'Null' is not
a subtype of type 'String'`), lo cual dificulta la depuración cuando los
datos externos llegan mal formados.

Queda como trabajo futuro considerar una combinación híbrida —usar
freezed únicamente para generar igualdad, `copyWith` y `toString`,
conservando el `fromJson` manual— si el modelo crece lo suficiente como
para que el código repetitivo se vuelva una carga real de mantenimiento.

### Sobre .gitignore y archivos generados

Dado que la entrega final no utiliza freezed, no existen archivos
`.freezed.dart` ni `.g.dart` en este proyecto, por lo que la decisión de
incluirlos o no en `.gitignore` no aplica actualmente.
