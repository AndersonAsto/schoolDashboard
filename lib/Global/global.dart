import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:schooldashboard/Utils/allNotifications.dart';

String generalURL = 'http://localhost:3000/';

Future<void> showGradeSelection(BuildContext context, TextEditingController controller1, TextEditingController controller2) async {
  final response = await http.get(Uri.parse('${generalURL}api/grade/list'));
  if (response.statusCode == 200) {
    final List<dynamic> grades = jsonDecode(response.body);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Seleccionar Grado'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: grades.length,
              itemBuilder: (context, index) {
                final grade = grades[index];
                return Card(
                  child: ListTile(
                    title: Text('${grade['id']} - ${grade['nombre']}'),
                    onTap: () {
                      controller1.text = grade['id'].toString();
                      controller2.text = '${grade['id']} - ${grade['nombre']}';
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  } else {
    Notificaciones.mostrarMensaje(context, "Error al obtener los grados", color: Colors.red);
  }
}

class CommonInfoFields extends StatelessWidget {
  final TextEditingController idController;
  final TextEditingController statusController;

  const CommonInfoFields({
    Key? key,
    required this.idController,
    required this.statusController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              controller: idController,
              enabled: false,
              style: TextStyle(fontSize: 13),
              decoration: InputDecoration(
                labelText: "Código",
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              controller: statusController,
              enabled: false,
              style: TextStyle(fontSize: 13),
              decoration: InputDecoration(
                labelText: "Estado",
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CommonTimestampsFields extends StatelessWidget {
  final TextEditingController createdAtController;
  final TextEditingController updatedAtController;

  const CommonTimestampsFields({
    Key? key,
    required this.createdAtController,
    required this.updatedAtController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              decoration:
              InputDecoration(
                labelText: "Creado el...",
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              controller: createdAtController,
              style: TextStyle(fontSize: 13),
              enabled: false,
            ),
          )
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              decoration:
              InputDecoration(
                labelText: "Actualizado el...",
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              controller: updatedAtController,
              style: TextStyle(fontSize: 13),
              enabled: false,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
        style: TextStyle(fontSize: 13),
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }
}