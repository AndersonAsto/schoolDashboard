import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Map<String,dynamic>? savedRole;

  Future<void> _guardarRol() async {
    final url = Uri.parse('http://localhost:3000/api/user/register');
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
      setState(() {
        _listarRoles();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rol guardado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el rol')),
      );
    }
  }

  List<dynamic> listaRoles = [];

  Future<void> _listarRoles() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/user/list'));
    if (response.statusCode == 200) {
      setState(() {
        listaRoles = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _listarRoles();
  }

  Future<void> _mostrarSeleccionPersonas(BuildContext context) async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/person/personavailablestudent'));
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
                    personIdController.text = persona['id'].toString();
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

  void _mostrarSeleccionRol(BuildContext context) {
    final roles = ['admin', 'docente', 'alumno'];

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
                return ListTile(
                  title: Text(rol),
                  onTap: () {
                    roleController.text = rol;
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
      appBar: AppBar(title: const Text("Registro de Usuarios", style: TextStyle(color: Colors.white),),backgroundColor: Colors.black,),
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
                  controller: personIdController,
                  enabled: false,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Nombre de Usuario"),
                  controller: userNameController,
                  enabled: true,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Contraseña"),
                  controller: passwordController,
                  enabled: true,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Rol"),
                  controller: roleController,
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
                      decoration: const InputDecoration(hintText: "Código de Persona"),
                      controller: personIdController,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _mostrarSeleccionRol(context),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: const InputDecoration(hintText: "Rol"),
                      controller: roleController,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: _guardarRol, child: Text("Guardar")),
                const SizedBox(height: 30),
                const Text('Lista de Usuarios Registrados'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listaRoles.length,
                  itemBuilder: (context, index) {
                    final rol = listaRoles[index];
                    return ListTile(
                      title: Text('${rol['username']} - ${rol['rol']}'),
                      subtitle: Text('ID: ${rol['id']}, Persona: ${rol['persona']['nombre']} ${rol['persona']['apellido']}, Estado: ${rol['estado'] ? 'Activo' : 'Inactivo'}'),
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