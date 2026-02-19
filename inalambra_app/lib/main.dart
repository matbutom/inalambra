import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:io';
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
      home: PaginaInicio(
          titulo: 'inalambra',
          v: '0.0.1',
          agno: 2026),
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
        // center
        Center(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              const Spacer(),
              const Text('hola!'),
              const Spacer(),
              ElevatedButton(
                  onPressed: () {},
                  child: 
              const Text("botón")),
              const Spacer(),
              ElevatedButton(
                  onPressed: () {},
                  child:
                  const Text("otro botón")),
              const Spacer(),
            ],
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
              title: Text(
                conectado ? 'conectado' : 'desconectado',
              ),
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
        Column(children: [],),

        // recibir
        Column(children: [],),

        // info
        Center(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              const Spacer(),
              TextoCentrado('inalambra'),
              TextoCentrado('v${widget.v}'),
              TextoCentrado(widget.agno.toString()),
              TextoCentrado('app desarrollada por piruetas'),
              TextoCentrado('en santiago de chile'),
              TextoCentrado('iniciada para el curso'),
              TextoCentrado('dis9079 interacciones inalámbricas'),
              TextoCentrado('dictado en diseño udp 2026'),
              TextoCentrado('por aarón montoya y mateo arce'),
              const Spacer(),
            ],
          ),
        ),
      ][indiceActualPagina],
    );
  }
}

///////////////////////
// clases para piruetas
///////////////////////

class TextoCentrado extends StatelessWidget {
  const TextoCentrado(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    // TODO: Replace Container with widgets.
    return Expanded(child: Text(texto, textAlign: TextAlign.center, ));
  }
}

class ToggleConTexto extends StatelessWidget {
  const ToggleConTexto(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    // TODO: Replace Container with widgets.
    return Expanded(child: Text(texto, textAlign: TextAlign.center, ));
  }
}