import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schooldashboard/Global/global.dart';
import 'package:schooldashboard/Utils/allNotifications.dart';

class PersonsScreenClass extends StatefulWidget {
  const PersonsScreenClass({super.key});

  @override
  State<PersonsScreenClass> createState() => _PersonsScreenClassState();
}

class _PersonsScreenClassState extends State<PersonsScreenClass> {
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController dniController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController createdAtController = TextEditingController();
  TextEditingController updatedAtController = TextEditingController();

  Map<String,dynamic>? personaGuardada;

  Future<void> savePerson() async {
    if(
    nameController.text.trim().isEmpty ||
    lastNameController.text.trim().isEmpty ||
    dniController.text.trim().isEmpty ||
    emailController.text.trim().isEmpty ||
    phoneController.text.trim().isEmpty
    ){
      Notificaciones.mostrarMensaje(context, "Un dato está vacío.", color: Colors.red);
      return;
    }
    final url = Uri.parse('${generalURL}api/person/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": nameController.text,
        "apellido": lastNameController.text,
        "dni": dniController.text,
        "correo": emailController.text,
        "telefono": phoneController.text
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      setState(() {
        personaGuardada = data;
        idController.text = data['id'].toString();
        stateController.text = data['estado'].toString();
        createdAtController.text = data['createdAt'].toString();
        updatedAtController.text = data['updatedAt'].toString();
      });
      idController.clear();
      nameController.clear();
      lastNameController.clear();
      dniController.clear();
      emailController.clear();
      phoneController.clear();
      stateController.clear();
      createdAtController.clear();
      updatedAtController.clear();
      getPersons();
      Notificaciones.mostrarMensaje(context, "Curso guardado correctamente", color: Colors.green);
    } else {
      print("Error al guardar grado: ${response.body}");
    }
  }

  List<Map<String,dynamic>> personas = [];

  Future<void> getPersons() async {
    final url = Uri.parse('${generalURL}api/person/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        personas = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print("Error al obtener datos de personas: ${response.body}");
    }
  }

  Future<void> deletePerson(int id) async {
    final url = Uri.parse('${generalURL}api/person/delete/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print("Persona removida: $id");
      getPersons();
    } else {
      print("Error al remover persona: ${response.body}");
    }
  }

  @override
  void initState() {
    super.initState();
    getPersons();
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
                  decoration: const InputDecoration(hintText: "Nombres"),
                  controller: nameController,
                  enabled: true,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Apellidos"),
                  controller: lastNameController,
                  enabled: true,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "DNI"),
                  controller: dniController,
                  enabled: true,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Correo"),
                  controller: emailController,
                  enabled: true,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Teléfono"),
                  controller: phoneController,
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
                ElevatedButton(onPressed: savePerson, child: Text("Guardar")),
                const SizedBox(height: 30),
                const Text("Grados registrados:", style: TextStyle(fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: personas.length,
                  itemBuilder: (context, index) {
                    final persons = personas[index];
                    return ListTile(
                      title: Text("ID: ${persons['id']} - ${persons['nombre']}"),
                      subtitle: Text(
                          "Nombres y Apellidos: ${persons['nombre']} ${persons['apellido']}\n"
                          "DNI: ${persons['dni']}\n"
                          "Correo: ${persons['correo']} | Teléfono: ${persons['telefono']}\n"
                          "Estado: ${persons['estado'] == true? 'Activo': 'Inactivo'} | Creado: ${persons['createdAt']}"),
                      trailing: Container(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => deletePerson(persons['id']),
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