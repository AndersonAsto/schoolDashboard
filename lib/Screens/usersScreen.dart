import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schooldashboard/Global/global.dart';
import 'dart:convert';
import 'package:schooldashboard/Utils/allNotifications.dart';

class UsersScreenClass extends StatefulWidget {
  const UsersScreenClass({super.key});

  @override
  State<UsersScreenClass> createState() => _UsersScreenClassState();
}

class _UsersScreenClassState extends State<UsersScreenClass> {
  TextEditingController idController = TextEditingController();
  TextEditingController personIdController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController createdAtController = TextEditingController();
  TextEditingController updatedAtController = TextEditingController();
  TextEditingController personDisplayController = TextEditingController();

  Map<String,dynamic>? savedUsers;

  Future<void> saveUser() async {
    if(
      personIdController.text.trim().isEmpty ||
      userNameController.text.trim().isEmpty ||
      passwordController.text.trim().isEmpty ||
      roleController.text.trim().isEmpty
    ){
      Notificaciones.mostrarMensaje(context, "Algunos campos aún están vacíos.", color: Colors.red);
      return;
    }

    if (idToEdit != null) {
      Notificaciones.mostrarMensaje(context, "Estás editando un registro. Cancela la edición para guardar uno nuevo.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/user/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "persona_id": int.parse(personIdController.text),
        "username": userNameController.text,
        "password_hash": passwordController.text,
        "rol": roleController.text,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      setState(() {
        savedUsers = data;
        idController.text = data['id'].toString();
        statusController.text = data['estado'].toString();
        createdAtController.text = data['createdAt'].toString();
        updatedAtController.text = data['updatedAt'].toString();
      });
      clearTextFields();
      idToEdit = null;
      getUsers();
      Notificaciones.mostrarMensaje(context, "Usuario guardado correctamente", color: Colors.green);
    } else {
      Notificaciones.mostrarMensaje(context, "Error al guardar usuario", color: Colors.red);
      print("Error al guardar usuario: ${response.body}");
    }
  }

  void clearTextFields (){
    idController.clear();
    personIdController.clear();
    userNameController.clear();
    passwordController.clear();
    roleController.clear();
    statusController.clear();
    createdAtController.clear();
    updatedAtController.clear();
    personDisplayController.clear();
  }

  List<Map<String, dynamic>> usersList = [];

  Future<void> getUsers() async {
    final url = Uri.parse('${generalURL}api/user/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        usersList = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print("Error al obtener datos de usuarios: ${response.body}");
    }
  }

  bool _showPassword = false;

  int? idToEdit;

  Future<void> updateUser () async {
    if (idToEdit == null) {
      Notificaciones.mostrarMensaje(context, "Selecciona un usuario para actualizar", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/user/update/$idToEdit');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "persona_id": int.parse(personIdController.text),
        "username": userNameController.text,
        "password_hash": passwordController.text,
        "rol": roleController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        clearTextFields();
        idToEdit = null;
      });
      getUsers();
    } else {
      print("Error al actualizar usuario: ${response.body}");
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

  Future<void> deleteUser(int id) async {
    final url = Uri.parse('${generalURL}api/user/delete/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print("Usuario eliminado: $id");
      getUsers();
    } else {
      print("Error al eliminar usuario: ${response.body}");
    }
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> showPersonSelection(BuildContext context) async {
    final response = await http.get(Uri.parse('${generalURL}api/person/personavailablestudent'));
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
                      personIdController.text = person['id'].toString();
                      personDisplayController.text = '${person['id']} - ${person['nombre']} ${person['apellido']}';
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

  void showRoleSelection(BuildContext context) {
    final roles = ['Administrador', 'Docente', 'Apoderado'];

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Seleccionar Rol'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: roles.length,
              itemBuilder: (context, index) {
                final rol = roles[index];
                return Card(
                  child: ListTile(
                    title: Text(rol),
                    onTap: () {
                      roleController.text = rol;
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
      appBar: AppBar(title: const Text("Registro de Usuarios", style: TextStyle(color: Colors.white),),backgroundColor: Colors.black, automaticallyImplyLeading: false,),
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
                    Expanded(child: CustomTextField(label: "Código de Persona", controller: personIdController, enabled: false,)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => showPersonSelection(context),
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: const InputDecoration(hintText: "Seleccionar Persona"),
                            controller: personDisplayController,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: CustomTextField(label: "Nombre de Usuario", controller: userNameController)
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(label: "Rol", controller: roleController, enabled: false,)
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => showRoleSelection(context),
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: const InputDecoration(hintText: "Seleccionar Rol"),
                            controller: roleController,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                CommonTimestampsFields(createdAtController: createdAtController, updatedAtController: updatedAtController),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: saveUser, child: const Text("Guardar")),
                    IconButton(onPressed: cancelUpdate, icon: const Icon(Icons.edit_off, color: Colors.deepOrange)),
                    ElevatedButton(onPressed: updateUser, child: const Text("Actualizar")),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Usuarios Registrados', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: usersList.length,
                  itemBuilder: (context, index) {
                    final user = usersList[index];
                    return ListTile(
                      title: Text('${user['username']} - ${user['rol']}'),
                      subtitle: Text('ID: ${user['id']}, Persona: ${user['persona']['nombre']} ${user['persona']['apellido']}, Estado: ${user['estado'] ? 'Activo' : 'Inactivo'}'),
                      trailing: Container(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  idToEdit = user['id'];
                                  idController.text = user['id'].toString();
                                  personIdController.text = user['persona']['id'].toString();
                                  personDisplayController.text = '${user['persona']['id']} - ${user['persona']['nombre']} ${user['persona']['apellido']}';
                                  userNameController.text = user['username'];
                                  passwordController.text = user['password_hash'];
                                  roleController.text = user['rol'];
                                  statusController.text = user['estado'].toString();
                                  createdAtController.text = user['createdAt'].toString();
                                  updatedAtController.text = user['updatedAt'].toString();
                                });
                              },
                              icon: const Icon(Icons.edit, color: Colors.blue,),
                            ),
                            IconButton(
                              onPressed: () => deleteUser(user['id']),
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