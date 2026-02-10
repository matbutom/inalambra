import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';

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
      ),
      home: const PaginaInicio(titulo: 'inalambra'),
    );
  }
}

class PaginaInicio extends StatefulWidget {
  const PaginaInicio({super.key, required this.titulo});

  final String titulo;
  // final int agno = 2026;

  @override
  State<PaginaInicio> createState() => _EstadoPaginaInicio();
}



class _EstadoPaginaInicio extends State<PaginaInicio> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.titulo),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('app desarrollada por piruetas',
           ),
            const Text('en santiago de chile'),
            const Text('febrero 2026'),
          ],
        ),
      ),
    );
  }
}
