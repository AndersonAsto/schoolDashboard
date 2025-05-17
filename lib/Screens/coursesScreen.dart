import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:schooldashboard/Utils/allNotifications.dart';

class CoursesScreenClass extends StatefulWidget {
  const CoursesScreenClass({super.key});

  @override
  State<CoursesScreenClass> createState() => _CoursesScreenClassState();
}

class _CoursesScreenClassState extends State<CoursesScreenClass> {
  TextEditingController idController = TextEditingController();
  TextEditingController courseController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController createdAtController = TextEditingController();
  TextEditingController updatedAtController = TextEditingController();

  Map<String, dynamic>? cursoGuardado;

  Future<void> guardarCurso() async {
    if(courseController.text.trim().isEmpty){
      Notificaciones.mostrarMensaje(context, "El nombre del curso no puede estar vacío.", color: Colors.red);
      return;
    }
    final url = Uri.parse('http://localhost:3000/api/course/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nombre": courseController.text}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      setState(() {
        cursoGuardado = data;
        idController.text = data['id'].toString();
        stateController.text = data['estado'].toString();
        createdAtController.text = data['createdAt'].toString();
        updatedAtController.text = data['updatedAt'].toString();
      });
      idController.clear();
      courseController.clear();
      stateController.clear();
      createdAtController.clear();
      updatedAtController.clear();
      obtenerCursos();
      Notificaciones.mostrarMensaje(context, "Curso guardado correctamente", color: Colors.green);
    } else {
      print("Error al guardar grado: ${response.body}");
    }
  }

  List<Map<String,dynamic>> cursos = [];

  Future<void> obtenerCursos() async {
    final url = Uri.parse('http://localhost:3000/api/course/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        cursos = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print("Error al obtener cursos: ${response.body}");
    }
  }


  Future<void> eliminarCurso(int id) async {
    final url = Uri.parse('http://localhost:3000/api/course/delete/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print("Curso eliminado: $id");
      obtenerCursos();
    } else {
      print("Error al eliminar curso: ${response.body}");
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerCursos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Grados", style: TextStyle(color: Colors.white),),backgroundColor: Colors.black,),
      body: SelectableRegion(
        selectionControls: materialTextSelectionControls,
        focusNode: FocusNode(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(hintText: "Código"),
                  controller: idController,
                  enabled: false,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Curso"),
                  controller: courseController,
                  enabled: true,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Estado"),
                  controller: stateController,
                  enabled: false,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Creado el..."),
                  controller: createdAtController,
                  enabled: false,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Actualizado el..."),
                  controller: updatedAtController,
                  enabled: false,
                ),
                ElevatedButton(onPressed: guardarCurso, child: Text("Guardar")),
                const SizedBox(height: 30),
                const Text("Grados registrados:", style: TextStyle(fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: cursos.length,
                  itemBuilder: (context, index) {
                    final courses = cursos[index];
                    return ListTile(
                      title: Text("ID: ${courses['id']} - ${courses['nombre']}"),
                      subtitle: Text("Estado: ${courses['estado'] == true? 'Activo': 'Inactivo'} | Creado: ${courses['createdAt']}"),
                      trailing: Container(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => eliminarCurso(courses['id']),
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ) ,
      ),
    );
  }
}