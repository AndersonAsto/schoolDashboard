import 'package:flutter/material.dart';

class Notificaciones {
  static void mostrarMensaje(BuildContext context, String mensaje,
      {Color color = Colors.black, Duration duracion = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: duracion,
      ),
    );
  }
}