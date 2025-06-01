import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:schooldashboard/Global/global.dart';
import 'package:schooldashboard/Utils/allNotifications.dart';

class StudentsScreenClass extends StatefulWidget{
  @override
  State<StudentsScreenClass> createState() => _StudentsScreenClassState();
}

class _StudentsScreenClassState extends State<StudentsScreenClass> {
  TextEditingController idController = TextEditingController();
  TextEditingController studentIdController = TextEditingController();
  TextEditingController gradeIdController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController createdAtController = TextEditingController();
  TextEditingController updatedAtController = TextEditingController();
  TextEditingController studentDisplayController = TextEditingController();
  TextEditingController gradeDisplayController = TextEditingController();

  Map<String,dynamic>? savedStudents;

  Future<void> saveStudent() async {
    if(
      studentIdController.text.trim().isEmpty ||
      gradeIdController.text.trim().isEmpty
    ){
      Notificaciones.mostrarMensaje(context, "Algunos campos aún están vacíos.", color: Colors.red);
      return;
    }

    if (idToEdit != null) {
      Notificaciones.mostrarMensaje(context, "Estás editando un registro. Cancela la edición para guardar uno nuevo.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/student/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "alumno_id": int.parse(studentIdController.text),
        "grado_id": int.parse(gradeIdController.text)
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      setState(() {
        savedStudents = data;
        idController.text = data['id'].toString();
        statusController.text = data['estado'].toString();
        createdAtController.text = data['createdAt'].toString();
        updatedAtController.text = data['updatedAt'].toString();
      });
      clearTextFields();
      idToEdit = null;
      getStudents();
      Notificaciones.mostrarMensaje(context, "Estudiante guardado correctamente", color: Colors.green);
    } else {
      Notificaciones.mostrarMensaje(context, "Error al guardar estudiante", color: Colors.red);
      print("Error al guardar estudiante: ${response.body}");
    }
  }

  void clearTextFields (){
    idController.clear();
    studentIdController.clear();
    gradeIdController.clear();
    statusController.clear();
    createdAtController.clear();
    updatedAtController.clear();
    studentDisplayController.clear();
    gradeDisplayController.clear();
  }

  List<Map<String, dynamic>> studentsList = [];

  Future<void> getStudents() async {
    final url = Uri.parse('${generalURL}api/student/list');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        studentsList = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  int? idToEdit;

  Future<void> updateStudent () async {
    if (idToEdit == null) {
      Notificaciones.mostrarMensaje(context, "Selecciona un estudiante para actualizar", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/student/update/$idToEdit');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "alumno_id": int.parse(studentIdController.text),
        "grado_id": int.parse(gradeIdController.text)
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        clearTextFields();
        idToEdit = null;
      });
      getStudents();
    } else {
      print("Error al actualizar estudiante: ${response.body}");
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

  Future<void> deleteStudent(int id) async {
    final url = Uri.parse('${generalURL}api/student/delete/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print("Estudiante retirado: $id");
      getStudents();
    } else {
      print("Error al retirar estudiante: ${response.body}");
    }
  }

  @override
  void initState() {
    super.initState();
    getStudents();
  }

  Future<void> showPersonSelection(BuildContext context) async {
    final response = await http.get(Uri.parse('${generalURL}api/person/personavailable'));
    final List<dynamic> persons = jsonDecode(response.body);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Seleccionar Persona'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: persons.length,
              itemBuilder: (context, index) {
                final person = persons[index];
                return Card(
                  child: ListTile(
                    title: Text('${person['id']} - ${person['nombre']} ${person['apellido']}'),
                    onTap: () {
                      studentIdController.text = person['id'].toString();
                      studentDisplayController.text = '${person['id']} - ${person['nombre']} ${person['apellido']}';
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
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Estudiantes", style: TextStyle(color: Colors.white),),backgroundColor: Colors.black, automaticallyImplyLeading: false,),
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
                    Expanded(child: CustomTextField(label: "Código de Persona", controller: studentIdController, enabled: false,),),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: GestureDetector(
                          onTap: () => showPersonSelection(context),
                          child: AbsorbPointer(
                            child: TextField(
                              style: TextStyle(fontSize: 13),
                              decoration: const InputDecoration(hintText: "Seleccionar Persona", contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),),
                              controller: studentDisplayController,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: "Código de Grado", controller: gradeIdController, enabled: false,),),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: GestureDetector(
                          onTap: () async => await showGradeSelection(context, gradeIdController, gradeDisplayController),
                          child: AbsorbPointer(
                            child: TextField(
                              style: TextStyle(fontSize: 13),
                              decoration: const InputDecoration(hintText: "Seleccionar Grados", contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),),
                              controller: gradeDisplayController,
                            ),
                          ),
                        ),
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CommonTimestampsFields(createdAtController: createdAtController, updatedAtController: updatedAtController),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: saveStudent, child: const Text("Guardar")),
                    IconButton(onPressed: cancelUpdate, icon: const Icon(Icons.edit_off, color: Colors.deepOrange)),
                    ElevatedButton(onPressed: updateStudent, child: const Text("Actualizar")),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Estudiantes Registrados', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: studentsList.length,
                  itemBuilder: (context, index) {
                    final student = studentsList[index];
                    return ListTile(
                      title: Text('ID: ${student['id']}, Persona: ${student['alumno']['nombre']} ${student['alumno']['apellido']}'),
                      subtitle: Text(
                        '${student['grado']['nombre']} \n'
                        'Estado: ${student['estado'] ? 'Activo' : 'Inactivo'}'
                      ),
                      trailing: Container(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  idToEdit = student['id'];
                                  idController.text = student['id'].toString();
                                  studentIdController.text = student['alumno']['id'].toString();
                                  studentDisplayController.text = '${student['alumno']['id']} - ${student['alumno']['nombre']} ${student['alumno']['apellido']}';
                                  gradeIdController.text = student['grado']['id'].toString();
                                  gradeDisplayController.text = '${student['grado']['id']} - ${student['grado']['nombre']}';
                                  statusController.text = student['estado'].toString();
                                  createdAtController.text = student['createdAt'].toString();
                                  updatedAtController.text = student['updatedAt'].toString();
                                });
                              },
                              icon: const Icon(Icons.edit, color: Colors.blue,),
                            ),
                            IconButton(
                              onPressed: () => deleteStudent(student['id']),
                              icon: const Icon(Icons.delete, color: Colors.red,),
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