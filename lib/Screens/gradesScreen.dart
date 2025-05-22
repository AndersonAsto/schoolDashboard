import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schooldashboard/Global/global.dart';
import 'package:schooldashboard/Utils/allNotifications.dart';

class GradesScreenClass extends StatefulWidget {
  const GradesScreenClass({super.key});

  @override
  State<GradesScreenClass> createState() => _GradesScreenClassState();
}

class _GradesScreenClassState extends State<GradesScreenClass> {
  TextEditingController idController = TextEditingController();
  TextEditingController gradeController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController createdAtController = TextEditingController();
  TextEditingController updatedAtController = TextEditingController();

  Map<String, dynamic>? savedGrades;

  Future<void> saveGrade() async {
    if (gradeController.text.trim().isEmpty) {
      Notificaciones.mostrarMensaje(context, "El nombre del grado no puede estar vacío.", color: Colors.red);
      return;
    }

    if (idToEdit != null) {
      Notificaciones.mostrarMensaje(context, "Estás editando un grado. Cancela la edición para guardar uno nuevo.", color: Colors.red);
      return;
    }

    final url = Uri.parse('http://localhost:3000/api/grade/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nombre": gradeController.text}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      setState(() {
        savedGrades = data;
        idController.text = data['id'].toString();
        statusController.text = data['estado'].toString();
        createdAtController.text = data['createdAt'].toString();
        updatedAtController.text = data['updatedAt'].toString();
      });
      clearTextFields();
      idToEdit = null;
      getGrades();
      Notificaciones.mostrarMensaje(context, "Grado guardado correctamente", color: Colors.green);
    } else {
      Notificaciones.mostrarMensaje(context, "Error al guardar grado", color: Colors.red);
      print("Error al guardar grado: ${response.body}");
    }
  }

  void clearTextFields() {
    idController.clear();
    gradeController.clear();
    statusController.clear();
    createdAtController.clear();
    updatedAtController.clear();
  }

  List<Map<String, dynamic>> gradesList = [];

  Future<void> getGrades() async {
    final url = Uri.parse('http://localhost:3000/api/grade/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        gradesList = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print("Error al obtener grados: ${response.body}");
    }
  }

  int? idToEdit;

  Future<void> updateGrade() async {
    if (idToEdit == null) {
      Notificaciones.mostrarMensaje(context, "Selecciona un grado para actualizar", color: Colors.red);
      return;
    }

    final url = Uri.parse('http://localhost:3000/api/grade/update/$idToEdit');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nombre": gradeController.text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        clearTextFields();
        idToEdit = null;
      });
      getGrades();
    } else {
      print("Error al actualizar grado: ${response.body}");
    }
  }

  Future<void> cancelUpdate() async {
    if (idToEdit != null) {
      setState(() {
        clearTextFields();
        idToEdit = null;
      });
    }
  }

  Future<void> deleteGrade(int id) async {
    final url = Uri.parse('http://localhost:3000/api/grade/delete/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print("Grado eliminado: $id");
      getGrades();
    } else {
      print("Error al eliminar grado: ${response.body}");
    }
  }

  @override
  void initState() {
    super.initState();
    getGrades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Grados", style: TextStyle(color: Colors.white),), backgroundColor: Colors.black,),
      body: SelectableRegion(
        focusNode: FocusNode(),
        selectionControls: materialTextSelectionControls,
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
                      child: CustomTextField(label: "Grado", controller: gradeController)
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CommonTimestampsFields(createdAtController: createdAtController, updatedAtController: updatedAtController),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: saveGrade, child: const Text("Guardar")),
                    IconButton(onPressed: cancelUpdate, icon: const Icon(Icons.edit_off, color: Colors.deepOrange)),
                    ElevatedButton(onPressed: updateGrade, child: const Text("Actualizar")),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Grados Registrados", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: gradesList.length,
                  itemBuilder: (context, index) {
                    final grade = gradesList[index];
                    return ListTile(
                      title: Text("ID: ${grade['id']} - ${grade['nombre']}"),
                      subtitle: Text("Estado: ${grade['estado'] == true ? 'Activo' : 'Inactivo'} | Creado: ${grade['createdAt']}"),
                      trailing: SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  idToEdit = grade['id'];
                                  idController.text = grade['id'].toString();
                                  gradeController.text = grade['nombre'];
                                  statusController.text = grade['estado'].toString();
                                  createdAtController.text = grade['createdAt'].toString();
                                  updatedAtController.text = grade['updatedAt'].toString();
                                });
                              },
                              icon: const Icon(Icons.edit, color: Colors.blue,),
                            ),
                            IconButton(onPressed: () => deleteGrade(grade['id']), icon: const Icon(Icons.delete, color: Colors.red,),),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
