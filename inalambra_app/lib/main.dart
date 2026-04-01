// bibliotecas

// import 'piruetas.dart';
import 'widgets/recibir.dart';
import 'widgets/info.dart';
import 'services/osc_service.dart';

import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'inalambra',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
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

  // OSC: sin broker — configuración de IP y puertos UDP
  final TextEditingController _hostController = TextEditingController(
    text: '192.168.1.100',
  );
  final TextEditingController _puertoRemotoController = TextEditingController(
    text: '57120',
  );
  final TextEditingController _puertoLocalController = TextEditingController(
    text: '57121',
  );

  EstadoOsc _estadoOsc = EstadoOsc.inactivo;
  OscService? _oscService;
  StreamSubscription<OscMessage>? _subscription;
  final _recibirKey = GlobalKey<WidgetRecibirState>();

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

  // OSC

  Future<void> _iniciar() async {
    final host = _hostController.text.trim();
    if (host.isEmpty) return;
    final remotePort =
        int.tryParse(_puertoRemotoController.text.trim()) ?? 57120;
    final localPort =
        int.tryParse(_puertoLocalController.text.trim()) ?? 57121;

    _oscService = OscService(
      remoteHost: host,
      remotePort: remotePort,
      localPort: localPort,
    );

    try {
      await _oscService!.init();
      setState(() {
        _estadoOsc = EstadoOsc.listo;
      });
      _subscription = _oscService!.messages.listen(_onMensajeRecibido);
    } catch (e) {
      _oscService!.dispose();
      _oscService = null;
      setState(() {
        _estadoOsc = EstadoOsc.error;
      });
    }
  }

  void _detener() {
    _subscription?.cancel();
    _subscription = null;
    _oscService?.dispose();
    _oscService = null;
    setState(() {
      _estadoOsc = EstadoOsc.inactivo;
    });
  }

  void _onMensajeRecibido(OscMessage msg) {
    final now = DateTime.now();
    final hora = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    // componente = última parte de la dirección OSC (ej: /dis9079/led → led)
    final parts = msg.address.split('/');
    final componente = parts.isNotEmpty ? parts.last : 'otros';
    final contenido = msg.arguments.isNotEmpty
        ? msg.arguments.first.toString()
        : msg.address;
    _recibirKey.currentState?.agregarMensaje({
      'contenido': contenido,
      'componente': componente,
      'hora': hora,
    });
  }

  void _enviar(String address, List<dynamic> args) {
    if (_oscService == null || _estadoOsc != EstadoOsc.listo) return;
    _oscService!.send(OscMessage(address, args));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _oscService?.dispose();
    _hostController.dispose();
    _puertoRemotoController.dispose();
    _puertoLocalController.dispose();
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
          NavigationDestination(
            icon: Icon(Icons.wifi),
            label: 'destino',
          ),
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
                    mainAxisAlignment: MainAxisAlignment.center,
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
                    mainAxisAlignment: MainAxisAlignment.center,
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

        // destino - configuración OSC UDP
        Column(
          children: [
            SwitchListTile(
              value: _estadoOsc == EstadoOsc.listo,
              onChanged: _hostController.text.trim().isEmpty
                  ? null
                  : (bool valor) {
                      if (valor) {
                        _iniciar();
                      } else {
                        _detener();
                      }
                    },
              title: Text(
                _estadoOsc == EstadoOsc.listo
                    ? 'listo'
                    : _estadoOsc == EstadoOsc.error
                    ? 'error al abrir socket'
                    : 'inactivo',
              ),
              subtitle: _hostController.text.trim().isEmpty
                  ? const Text('ingresa una IP destino')
                  : Text(
                      '${_hostController.text.trim()}:${_puertoRemotoController.text}',
                    ),
              secondary: Icon(
                _estadoOsc == EstadoOsc.listo ? Icons.wifi : Icons.wifi_off,
                color: _estadoOsc == EstadoOsc.listo
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      labelText: 'IP destino',
                      hintText: '192.168.1.100',
                      prefixIcon: Icon(Icons.computer),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _puertoRemotoController,
                          decoration: const InputDecoration(
                            labelText: 'puerto remoto',
                            hintText: '57120',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _puertoLocalController,
                          decoration: const InputDecoration(
                            labelText: 'puerto local',
                            hintText: '57121',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        // enviar
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('enviar mensaje'),
                const SizedBox(height: 32),
                DropdownButtonFormField<String>(
                  value: _mensajeSeleccionado,
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
                  onPressed:
                      (_mensajeSeleccionado == null ||
                              _estadoOsc != EstadoOsc.listo)
                          ? null
                          : () {
                              final m = _mensajes.firstWhere(
                                (m) => m['etiqueta'] == _mensajeSeleccionado,
                              );
                              final componente = m['componente']!;
                              // OSC: dirección /dis9079/<componente>, argumento = etiqueta
                              _enviar(
                                '/dis9079/$componente',
                                [_mensajeSeleccionado!],
                              );
                              setState(() {
                                _ultimoEnvio =
                                    '$_mensajeSeleccionado → /dis9079/$componente'
                                    '\nvía ${_hostController.text.trim()}';
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
                              _estadoOsc != EstadoOsc.listo)
                          ? null
                          : () {
                              final texto =
                                  _mensajeManualController.text.trim();
                              // OSC: mensajes de texto libre en /dis9079/mensaje
                              _enviar('/dis9079/mensaje', [texto]);
                              setState(() {
                                _ultimoEnvio =
                                    '"$texto"'
                                    '\nvía ${_hostController.text.trim()}';
                                _mensajeManualController.clear();
                              });
                            },
                  icon: const Icon(Icons.send),
                  label: const Text('enviar mensaje'),
                ),
                if (_estadoOsc != EstadoOsc.listo)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'inicia el socket primero',
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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

        WidgetRecibir(_estadoOsc == EstadoOsc.listo, key: _recibirKey),

        WidgetInfo(),
      ][indiceActualPagina],
    );
  }
}
