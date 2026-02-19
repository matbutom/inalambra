import 'package:flutter/material.dart';
import 'package:inalambra_app/piruetas.dart';

class WidgetInfo extends StatelessWidget {
  const WidgetInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          const Spacer(),
          TextoCentrado('inalambra'),
          // TextoCentrado('v${widget.v}'),
          // TextoCentrado(widget.agno.toString()),
          TextoCentrado('app desarrollada por piruetas'),
          TextoCentrado('en santiago de chile'),
          TextoCentrado('iniciada para el curso'),
          TextoCentrado('dis9079 interacciones inalámbricas'),
          TextoCentrado('dictado en diseño udp 2026'),
          TextoCentrado('por aarón montoya y mateo arce'),
          const Spacer(),
        ],
      ),
    );
  }
}
