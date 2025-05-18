import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String generalURL = 'http://localhost:3000/';

Future<void> showGradeSelectionDialog(BuildContext context, TextEditingController controller) async {
  final response = await http.get(Uri.parse('http://localhost:3000/api/grades/list'));
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
                return ListTile(
                  title: Text('${grade['id']} - ${grade['nombre']}'),
                  onTap: () {
                    controller.text = grade['id'].toString();
                    Navigator.of(context).pop();
                  },
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