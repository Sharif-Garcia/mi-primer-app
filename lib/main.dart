import 'package:flutter/material.dart';
import 'package:mi_primer_app/features/entregas/data/entregas_locales.dart';
import 'package:mi_primer_app/features/entregas/domain/entrega.dart';

void main() => runApp(const MiApp());

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Entregas',
    theme: ThemeData(colorSchemeSeed: Colors.green),
    home: const PantallaEntregas(),
  );
}

class PantallaEntregas extends StatefulWidget {
  const PantallaEntregas({super.key});

  @override
  State<PantallaEntregas> createState() => _PantallaEntregasState();
}

class _PantallaEntregasState extends State<PantallaEntregas> {
  // `late final` en el campo: el Future se crea UNA vez.
  // Crearlo dentro de build() lo relanza en cada reconstrucción, y esa es la
  // causa del 90 % de los FutureBuilder que parpadean sin parar.
  late final Future<List<Entrega>> _entregas = EntregasLocales().obtenerTodas();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Entregas')),
    body: FutureBuilder<List<Entrega>>(
      future: _entregas,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          // El mensaje de CampoInvalido dice el campo. Aquí se ve por qué
          // valió la pena escribirlo.
          return Center(child: Text('No se pudo leer:\n${snapshot.error}'));
        }

        final entregas = snapshot.data ?? const <Entrega>[];
        return ListView.separated(
          itemCount: entregas.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final entrega = entregas[i];
            return ListTile(
              title: Text(
                '${entrega.material.tipo} · ${entrega.material.pesoKg}kg',
              ),
              subtitle: Text(
                '${entrega.puntoAcopio} · ${entrega.estado.etiqueta}',
              ),
              trailing: entrega.tieneObservaciones
                  ? const Icon(Icons.notes_outlined)
                  : null,
            );
          },
        );
      },
    ),
  );
}
