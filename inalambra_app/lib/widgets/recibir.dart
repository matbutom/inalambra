import 'package:flutter/material.dart';
// import 'package:inalambra_app/piruetas.dart';

class WidgetRecibir extends StatefulWidget {
  final bool conectado;
  const WidgetRecibir(this.conectado, {super.key});

  @override
  State<WidgetRecibir> createState() => _WidgetRecibirState();
}

class _WidgetRecibirState extends State<WidgetRecibir> {
  final List<Map<String, String>> _mensajesRecibidos = [];
  String _filtroRecibidos = 'todos';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              for (final filtro in ['todos', 'led', 'buzzer', 'pantalla'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filtro),
                    selected: _filtroRecibidos == filtro,
                    onSelected: (_) {
                      setState(() {
                        _filtroRecibidos = filtro;
                      });
                    },
                  ),
                ),
              const Spacer(),
              if (_mensajesRecibidos.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _mensajesRecibidos.clear();
                    });
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('limpiar'),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Builder(
            builder: (context) {
              final filtrados = _filtroRecibidos == 'todos'
                  ? _mensajesRecibidos
                  : _mensajesRecibidos
                        .where((m) => m['componente'] == _filtroRecibidos)
                        .toList();
              if (filtrados.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.conectado
                            ? 'esperando mensajes...'
                            : 'conéctate a un servidor primero',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                reverse: true,
                itemCount: filtrados.length,
                itemBuilder: (context, i) {
                  final m = filtrados[filtrados.length - 1 - i];
                  final icono = switch (m['componente']) {
                    'led' => Icons.light,
                    'buzzer' => Icons.volume_up,
                    'pantalla' => Icons.monitor,
                    _ => Icons.message,
                  };
                  return ListTile(
                    leading: Icon(
                      icono,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(m['contenido']!),
                    subtitle: Text(m['componente']!),
                    trailing: Text(
                      m['hora']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
