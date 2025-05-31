import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:schooldashboard/Global/global.dart';
import 'package:schooldashboard/Utils/allNotifications.dart';

class CoursesScreenClass extends StatefulWidget {
  const CoursesScreenClass({super.key});

  @override
  State<CoursesScreenClass> createState() => _CoursesScreenClassState();
}

class _CoursesScreenClassState extends State<CoursesScreenClass> {
  TextEditingController idController = TextEditingController();
  TextEditingController courseController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController createdAtController = TextEditingController();
  TextEditingController updatedAtController = TextEditingController();

  Map<String, dynamic>? savedCourses;

  Future<void> saveCourse() async {
    if(courseController.text.trim().isEmpty){
      Notificaciones.mostrarMensaje(context, "El nombre del curso no puede estar vacío.", color: Colors.red);
      return;
    }

    if (idToEdit != null) {
      Notificaciones.mostrarMensaje(context, "Estás editando un grado. Cancela la edición para guardar uno nuevo.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/course/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nombre": courseController.text}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      setState(() {
        savedCourses = data;
        idController.text = data['id'].toString();
        statusController.text = data['estado'].toString();
        createdAtController.text = data['createdAt'].toString();
        updatedAtController.text = data['updatedAt'].toString();
      });
      clearTextFields();
      idToEdit = null;
      getCourses();
      Notificaciones.mostrarMensaje(context, "Curso guardado correctamente", color: Colors.green);
    } else {
      Notificaciones.mostrarMensaje(context, "Error al guardar curso", color: Colors.red);
      print("Error al guardar grado: ${response.body}");
    }
  }

  void clearTextFields (){
    idController.clear();
    courseController.clear();
    statusController.clear();
    createdAtController.clear();
    updatedAtController.clear();
  }

  List<Map<String,dynamic>> coursesList = [];

  Future<void> getCourses() async {
    final url = Uri.parse('${generalURL}api/course/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        coursesList = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print("Error al obtener cursos: ${response.body}");
    }
  }

  int? idToEdit;

  Future<void> updateCourse () async {
    if (idToEdit == null) {
      Notificaciones.mostrarMensaje(context, "Selecciona un curso para actualizar", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/course/update/$idToEdit');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nombre": courseController.text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        clearTextFields();
        idToEdit = null;
      });
      getCourses();
    } else {
      print("Error al actualizar curso: ${response.body}");
    }
  }

  Future<void> cancelUpdate () async {
    if (idToEdit != null) {
      setState(() {
        clearTextFields();
        idToEdit = null;
      });
    }
  }

  Future<void> deleteCourse(int id) async {
    final url = Uri.parse('${generalURL}api/course/delete/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print("Curso eliminado: $id");
      getCourses();
    } else {
      print("Error al eliminar curso: ${response.body}");
    }
  }

  @override
  void initState() {
    super.initState();
    getCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Grados", style: TextStyle(color: Colors.white),),backgroundColor: Colors.black, automaticallyImplyLeading: false,),
      body: SelectableRegion(
        selectionControls: materialTextSelectionControls,
        focusNode: FocusNode(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                CommonInfoFields(idController: idController, statusController: statusController),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(label: "Curso", controller: courseController, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]"))]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CommonTimestampsFields(createdAtController: createdAtController, updatedAtController: updatedAtController),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: saveCourse, child: const Text("Guardar")),
                    IconButton(onPressed: cancelUpdate, icon: const Icon(Icons.edit_off, color: Colors.deepOrange)),
                    ElevatedButton(onPressed: updateCourse, child: const Text("Actualizar")),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Cursos Registrados", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: coursesList.length,
                  itemBuilder: (context, index) {
                    final course = coursesList[index];
                    return ListTile(
                      title: Text("ID: ${course['id']} - ${course['nombre']}"),
                      subtitle: Text("Estado: ${course['estado'] == true? 'Activo': 'Inactivo'} | Creado: ${course['createdAt']}"),
                      trailing: Container(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  idToEdit = course['id'];
                                  idController.text = course['id'].toString();
                                  courseController.text = course['nombre'];
                                  statusController.text = course['estado'].toString();
                                  createdAtController.text = course['createdAt'].toString();
                                  updatedAtController.text = course['updatedAt'].toString();
                                });
                              },
                              icon: const Icon(Icons.edit, color: Colors.blue,),
                            ),
                            IconButton(onPressed: () => deleteCourse(course['id']), icon: const Icon(Icons.delete, color: Colors.red,),),
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
