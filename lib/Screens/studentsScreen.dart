import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:schooldashboard/Global/global.dart';

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

  Map<String,dynamic>? savedStudents;

  Future<void> _guardarEstudiante() async {
    final url = Uri.parse('http://localhost:3000/api/student/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "alumno_id": int.parse(studentIdController.text),
        "grado_id": int.parse(gradeIdController.text)
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _listarEstudiantes();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estudiante guardado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar al estudiante')),
      );
    }
  }

  List<dynamic> listaEstudiantes = [];

  Future<void> _listarEstudiantes() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/student/list'));
    if (response.statusCode == 200) {
      setState(() {
        listaEstudiantes = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _listarEstudiantes();
  }

  Future<void> _mostrarSeleccionPersonas(BuildContext context) async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/person/personavailable'));
    final List<dynamic> personas = jsonDecode(response.body);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Seleccionar Persona'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: personas.length,
              itemBuilder: (context, index) {
                final persona = personas[index];
                return ListTile(
                  title: Text('${persona['id']} - ${persona['nombre']} ${persona['apellido']}'),
                  onTap: () {
                    studentIdController.text = persona['id'].toString();
                    Navigator.of(context).pop();
                  },
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
      appBar: AppBar(title: const Text("Registro de Estudiantes", style: TextStyle(color: Colors.white),),backgroundColor: Colors.black,),
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
                  decoration: const InputDecoration(hintText: "Código de Persona"),
                  controller: studentIdController,
                  enabled: false,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Código de Grado"),
                  controller: gradeIdController,
                  enabled: false,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Estado"),
                  controller: statusController,
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
                GestureDetector(
                  onTap: () => _mostrarSeleccionPersonas(context),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: const InputDecoration(hintText: "Seleccionar Personas"),
                      controller: studentIdController,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async => await showGradeSelectionDialog(context, gradeIdController),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: const InputDecoration(hintText: "Seleccionar Grados"),
                      controller: gradeIdController,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: _guardarEstudiante, child: Text("Guardar")),
                const SizedBox(height: 30),
                const Text('Lista de Usuarios Registrados'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listaEstudiantes.length,
                  itemBuilder: (context, index) {
                    final estudiante = listaEstudiantes[index];
                    return ListTile(
                      title: Text('ID: ${estudiante['id']}, Persona: ${estudiante['alumno']['nombre']} ${estudiante['alumno']['apellido']}'),
                      subtitle: Text('${estudiante['grado']['nombre']} \n'
                          'Estado: ${estudiante['estado'] ? 'Activo' : 'Inactivo'}'),
                      trailing: Container(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: (){},
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