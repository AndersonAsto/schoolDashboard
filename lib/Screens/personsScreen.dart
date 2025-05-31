import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  TextEditingController statusController = TextEditingController();
  TextEditingController createdAtController = TextEditingController();
  TextEditingController updatedAtController = TextEditingController();

  Map<String, dynamic>? savedPersons;

  Future<void> savePerson() async {
    if (
      nameController.text.trim().isEmpty ||
      lastNameController.text.trim().isEmpty ||
      dniController.text.trim().isEmpty ||
      emailController.text.trim().isEmpty ||
      phoneController.text.trim().isEmpty
    ){
      Notificaciones.mostrarMensaje(context, "Algunos de los campos aún están vacíos.", color: Colors.red);
      return;
    }

    if (idToEdit != null) {
      Notificaciones.mostrarMensaje(context, "Estás editando un registro. Cancela la edición para guardar uno nuevo.", color: Colors.red);
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
        savedPersons = data;
        idController.text = data['id'].toString();
        statusController.text = data['estado'].toString();
        createdAtController.text = data['createdAt'].toString();
        updatedAtController.text = data['updatedAt'].toString();
      });
      clearTextFields();
      idToEdit = null;
      getPersons();
      Notificaciones.mostrarMensaje(context, "Persona guardada correctamente", color: Colors.green);
    } else {
      Notificaciones.mostrarMensaje(context, "Error al guardar persona", color: Colors.red);
      print("Error al guardar grado: ${response.body}");
    }
  }

  void clearTextFields (){
    idController.clear();
    nameController.clear();
    lastNameController.clear();
    dniController.clear();
    emailController.clear();
    phoneController.clear();
    statusController.clear();
    createdAtController.clear();
    updatedAtController.clear();
  }

  List<Map<String, dynamic>> personsList = [];

  Future<void> getPersons() async {
    final url = Uri.parse('${generalURL}api/person/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        personsList = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print("Error al obtener datos de personas: ${response.body}");
    }
  }

  int? idToEdit;

  Future<void> updatePerson () async {
    if (idToEdit == null) {
      Notificaciones.mostrarMensaje(context, "Selecciona un curso para actualizar", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/person/update/$idToEdit');
    final response = await http.put(
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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        clearTextFields();
        idToEdit = null;
      });
      getPersons();
    } else {
      print("Error al actualizar persona: ${response.body}");
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
      appBar: AppBar(
        title: const Text("Registro de Grados", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: SelectableRegion(
        selectionControls: materialTextSelectionControls,
        focusNode: FocusNode(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                CommonInfoFields(idController: idController, statusController: statusController),
                const SizedBox(height: 10),
                CustomTextField(label: "Nombres", controller: nameController, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]"))]),
                const SizedBox(height: 10),
                CustomTextField(label: "Apellidos", controller: lastNameController, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]"))]),
                const SizedBox(height: 10),
                CustomTextField(
                  label: "Correo",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9@._-]")),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: "DNI",
                        controller: dniController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        label: "Teléfono",
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CommonTimestampsFields(createdAtController: createdAtController, updatedAtController: updatedAtController),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: savePerson, child: const Text("Guardar")),
                    IconButton(onPressed: cancelUpdate, icon: const Icon(Icons.edit_off, color: Colors.deepOrange)),
                    ElevatedButton(onPressed: updatePerson, child: const Text("Actualizar")),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Personas Registradas", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: personsList.length,
                  itemBuilder: (context, index) {
                    final person = personsList[index];
                    return ListTile(
                      title: Text("ID: ${person['id']} - ${person['nombre']}"),
                      subtitle: Text(
                        "Nombres y Apellidos: ${person['nombre']} ${person['apellido']}\n"
                        "DNI: ${person['dni']}\n"
                        "Correo: ${person['correo']} | Teléfono: ${person['telefono']}\n"
                        "Estado: ${person['estado'] == true ? 'Activo' : 'Inactivo'} | Creado: ${person['createdAt']}"
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
                                  idToEdit = person['id'];
                                  idController.text = person['id'].toString();
                                  nameController.text = person['nombre'];
                                  lastNameController.text = person['apellido'];
                                  dniController.text = person['dni'];
                                  emailController.text = person['correo'];
                                  phoneController.text = person['telefono'];
                                  statusController.text = person['estado'].toString();
                                  createdAtController.text = person['createdAt'].toString();
                                  updatedAtController.text = person['updatedAt'].toString();
                                });
                              },
                              icon: const Icon(Icons.edit, color: Colors.blue,),
                            ),
                            IconButton(
                              onPressed: () => deletePerson(person['id']),
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
        ),
      ),
    );
  }
}