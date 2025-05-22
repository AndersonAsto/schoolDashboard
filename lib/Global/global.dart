import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String generalURL = 'http://localhost:3000/';

Future<void> showGradeSelection(BuildContext context, TextEditingController controller1, TextEditingController controller2) async {
  final response = await http.get(Uri.parse('http://localhost:3000/api/grade/list'));
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al obtener los grados')),
    );
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
          child: TextField(
            decoration: InputDecoration(
              hintText: "Código",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            controller: idController,
            enabled: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Estado",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            controller: statusController,
            enabled: false,
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
          child:  TextField(
            decoration:
            InputDecoration(
              hintText: "Creado el...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            controller: createdAtController,
            enabled: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            decoration:
              InputDecoration(
                hintText: "Actualizado el...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            controller: updatedAtController,
            enabled: false,
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

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.enabled = true,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
    );
  }
}