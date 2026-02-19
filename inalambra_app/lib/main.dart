// bibliotecas

// import 'piruetas.dart';
import 'widgets/recibir.dart';
import 'widgets/info.dart';

// import 'dart:io';
// import 'dart:async';
// import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
// import 'package:mqtt_client/mqtt_client.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'inalambra',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepOrange),
        fontFamily: 'Roboto',
      ),
      home: PaginaInicio(titulo: 'inalambra', v: '0.0.1', agno: 2026),
    );
  }
}

class PaginaInicio extends StatefulWidget {
  const PaginaInicio({
    super.key,
    required this.titulo,
    required this.v,
    required this.agno,
  });

  final String titulo;
  final String v;
  final int agno;

  @override
  State<PaginaInicio> createState() => _EstadoPaginaInicio();
}

class _EstadoPaginaInicio extends State<PaginaInicio> {
  int indiceActualPagina = 0;

  final List<String> servidores = [
    'broker.hivemq.com',
    'test.mosquitto.org',
    'mqtt.eclipseprojects.io',
  ];
  int? servidorSeleccionado;
  bool conectado = false;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _sesionIniciada = false;
  String _idUsuario = '';

  static const List<Map<String, String>> _mensajes = [
    {'etiqueta': 'encender led', 'componente': 'led', 'icono': 'light'},
    {'etiqueta': 'apagar led', 'componente': 'led', 'icono': 'light_off'},
    {'etiqueta': 'parpadear led', 'componente': 'led', 'icono': 'flare'},
    {'etiqueta': 'bip corto', 'componente': 'buzzer', 'icono': 'volume_up'},
    {'etiqueta': 'bip largo', 'componente': 'buzzer', 'icono': 'volume_up'},
    {
      'etiqueta': 'mensaje en pantalla',
      'componente': 'pantalla',
      'icono': 'monitor',
    },
  ];
  String? _mensajeSeleccionado;
  String? _ultimoEnvio;
  final TextEditingController _mensajeManualController =
      TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _contrasenaController.dispose();
    _mensajeManualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.titulo),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: indiceActualPagina,
        onDestinationSelected: (int indice) {
          setState(() {
            indiceActualPagina = indice;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.home), label: 'inicio'),
          NavigationDestination(icon: Icon(Icons.computer), label: 'servidor'),
          NavigationDestination(icon: Icon(Icons.send), label: 'enviar'),
          NavigationDestination(icon: Icon(Icons.inbox), label: 'recibir'),
          NavigationDestination(icon: Icon(Icons.info), label: 'info'),
        ],
      ),
      body: <Widget>[
        // inicio - login
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _sesionIniciada
                ? Column(
                    mainAxisAlignment: .center,
                    children: [
                      const Icon(Icons.person, size: 64),
                      const SizedBox(height: 16),
                      Text('hola, $_idUsuario'),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _sesionIniciada = false;
                            _idUsuario = '';
                            _idController.clear();
                            _contrasenaController.clear();
                          });
                        },
                        child: const Text('cerrar sesión'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: .center,
                    children: [
                      const Text('iniciar sesión'),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: 'id',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _contrasenaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'contraseña',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          if (_idController.text.isNotEmpty &&
                              _contrasenaController.text.isNotEmpty) {
                            setState(() {
                              _sesionIniciada = true;
                              _idUsuario = _idController.text;
                            });
                          }
                        },
                        child: const Text('entrar'),
                      ),
                    ],
                  ),
          ),
        ),
        // servidor
        Column(
          children: [
            SwitchListTile(
              value: conectado,
              onChanged: servidorSeleccionado == null
                  ? null
                  : (bool valor) {
                      setState(() {
                        conectado = valor;
                      });
                    },
              title: Text(conectado ? 'conectado' : 'desconectado'),
              subtitle: servidorSeleccionado != null
                  ? Text(servidores[servidorSeleccionado!])
                  : const Text('selecciona un servidor'),
              secondary: Icon(
                conectado ? Icons.wifi : Icons.wifi_off,
                color: conectado
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: servidores.length,
                itemBuilder: (context, i) {
                  final seleccionado = servidorSeleccionado == i;
                  return ListTile(
                    leading: Icon(
                      Icons.computer,
                      color: seleccionado
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(servidores[i]),
                    selected: seleccionado,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    onTap: () {
                      setState(() {
                        servidorSeleccionado = i;
                        conectado = false;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),

        // enviar
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                const Text('enviar mensaje'),
                const SizedBox(height: 32),
                DropdownButtonFormField<String>(
                  initialValue: _mensajeSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'tipo de mensaje',
                    border: OutlineInputBorder(),
                  ),
                  items: _mensajes.map((m) {
                    return DropdownMenuItem<String>(
                      value: m['etiqueta'],
                      child: Text(m['etiqueta']!),
                    );
                  }).toList(),
                  onChanged: (String? valor) {
                    setState(() {
                      _mensajeSeleccionado = valor;
                      _ultimoEnvio = null;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: (_mensajeSeleccionado == null || !conectado)
                      ? null
                      : () {
                          final componente = _mensajes.firstWhere(
                            (m) => m['etiqueta'] == _mensajeSeleccionado,
                          )['componente']!;
                          final servidor = servidorSeleccionado != null
                              ? servidores[servidorSeleccionado!]
                              : '';
                          setState(() {
                            _ultimoEnvio =
                                '$_mensajeSeleccionado → $componente\nvía $servidor';
                          });
                        },
                  icon: const Icon(Icons.send),
                  label: const Text('enviar'),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                TextField(
                  controller: _mensajeManualController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'mensaje personalizado',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.edit_outlined),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed:
                      (_mensajeManualController.text.trim().isEmpty ||
                          !conectado)
                      ? null
                      : () {
                          final servidor = servidorSeleccionado != null
                              ? servidores[servidorSeleccionado!]
                              : '';
                          setState(() {
                            _ultimoEnvio =
                                '"${_mensajeManualController.text.trim()}"\nvía $servidor';
                            _mensajeManualController.clear();
                          });
                        },
                  icon: const Icon(Icons.send),
                  label: const Text('enviar mensaje'),
                ),
                if (!conectado)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'conéctate a un servidor primero',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (_ultimoEnvio != null) ...[
                  const SizedBox(height: 32),
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                const Text('mensaje enviado'),
                                const SizedBox(height: 4),
                                Text(_ultimoEnvio!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        WidgetRecibir(conectado),

        WidgetInfo(),

        // info
      ][indiceActualPagina],
    );
  }
}
