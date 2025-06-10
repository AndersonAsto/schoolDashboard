import 'package:schooldashboard/Utils/customNotifications.dart';
import 'package:schooldashboard/Global/global.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

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
    Notificaciones.showNotification(context, "Error al obtener los grados", color: appColors[0]);
  }
}

Future<void> showCourseSelection(BuildContext context, TextEditingController controller1, TextEditingController controller2) async {
  final url = Uri.parse('${generalURL}api/course/list');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final List<dynamic> courses = jsonDecode(response.body);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Seleccionar Curso'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  child: ListTile(
                    title: Text('${course['id']} - ${course['nombre']}'),
                    onTap: () {
                      controller1.text = course['id'].toString();
                      controller2.text = '${course['id']} - ${course['nombre']}';
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
    Notificaciones.showNotification(context, "Error al cargar cursos disponibles", color: appColors[0]);
    print("Error al cargar cursos disponibles: ${response.body}");
  }
}