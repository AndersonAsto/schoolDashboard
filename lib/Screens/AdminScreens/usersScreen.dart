import 'package:schooldashboard/Utils/customNotifications.dart';
import 'package:schooldashboard/Utils/customTextFields.dart';
import 'package:schooldashboard/Global/global.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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
  TextEditingController personDisplayController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  Map<String,dynamic>? savedUsers;
  List<Map<String, dynamic>> usersList = [];
  int? idToEdit;
  bool _showPassword = false;
  List<Map<String, dynamic>> filteredUsersList = [];
  late _UsersDataSource _usersDataSource;

  Future<void> saveUser() async {
    if(
      personIdController.text.trim().isEmpty ||
      userNameController.text.trim().isEmpty ||
      passwordController.text.trim().isEmpty ||
      roleController.text.trim().isEmpty
    ){
      Notificaciones.showNotification(context, "Algunos campos aún están vacíos.", color: Colors.red);
      return;
    }

    if (idToEdit != null) {
      Notificaciones.showNotification(context, "Estás editando un registro. Cancela la edición para guardar uno nuevo.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/user/register');
    try {
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
        await getUsers(); // Await to ensure users are reloaded before notification
        Notificaciones.showNotification(context, "Usuario guardado correctamente", color: Colors.teal);
      } else {
        Notificaciones.showNotification(context, "Error al guardar usuario", color: Colors.red);
        print("Error al guardar usuario: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al guardar usuario: $e");
    }
  }

  Future<void> getUsers() async {
    final url = Uri.parse('${generalURL}api/user/list');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          usersList = List<Map<String, dynamic>>.from(data);
          filteredUsersList = usersList;
          _usersDataSource = _UsersDataSource(
            usersList: filteredUsersList,
            onEdit: _handleEditUser,
            onDelete: deleteUser,
          );
        });
      } else {
        Notificaciones.showNotification(context, "Error al obtener datos de usuarios", color: Colors.red);
        print("Error al obtener datos de usuarios: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al obtener datos de usuarios: $e");
    }
  }

  Future<void> updateUser () async {
    if (idToEdit == null) {
      Notificaciones.showNotification(context, "Selecciona un usuario para actualizar", color: Colors.red);
      return;
    }
    if(
    personIdController.text.trim().isEmpty ||
        userNameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        roleController.text.trim().isEmpty
    ){
      Notificaciones.showNotification(context, "Algunos campos aún están vacíos.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/user/update/$idToEdit');
    try {
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
        await getUsers();
        Notificaciones.showNotification(context, "Usuario actualizado correctamente", color: Colors.teal);
      } else {
        Notificaciones.showNotification(context, "Error al actualizar usuario", color: Colors.red);
        print("Error al actualizar usuario: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al actualizar usuario: $e");
    }
  }

  Future<void> deleteUser(int id) async {
    final url = Uri.parse('${generalURL}api/user/delete/$id');
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("Usuario eliminado: $id");
        await getUsers();
        Notificaciones.showNotification(context, "Usuario eliminado correctamente", color: Colors.teal);
      } else {
        Notificaciones.showNotification(context, "Error al eliminar usuario", color: Colors.red);
        print("Error al eliminar usuario: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al eliminar usuario: $e");
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
    filterUsers("");
  }

  Future<void> cancelUpdate () async {
    if (idToEdit != null) {
      setState(() {
        clearTextFields();
        idToEdit = null;
      });
      Notificaciones.showNotification(context, "Edición cancelada.", color: Colors.orange);
    } else {
      Notificaciones.showNotification(context, "No hay edición activa para cancelar.", color: Colors.blueGrey);
    }
  }

  void _handleEditUser(Map<String, dynamic> user) {
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
  }

  Future<void> showPersonSelection(BuildContext context) async {
    final url = Uri.parse('${generalURL}api/person/personavailablestudent');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
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
      } else {
        Notificaciones.showNotification(context, "Error al cargar personas disponibles", color: Colors.red);
        print("Error al cargar personas disponibles: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión al cargar personas: $e", color: Colors.red);
      print("Error de conexión al cargar personas: $e");
    }
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

  void filterUsers(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredUsersList = usersList.where((user) {
        final nombre = '${user['persona']['nombre']} ${user['persona']['apellido']} ${user['rol']} ${user['username']}'.toLowerCase();
        return nombre.contains(lowerQuery);
      }).toList();

      _usersDataSource = _UsersDataSource(
        usersList: filteredUsersList,
        onEdit: _handleEditUser,
        onDelete: deleteUser,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getUsers();
    _usersDataSource = _UsersDataSource(
      usersList: usersList,
      onEdit: _handleEditUser,
      onDelete: deleteUser,
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
                        child: SizedBox(
                          height: 36, // Increased height for better tap target
                          child: GestureDetector(
                            onTap: () => showPersonSelection(context),
                            child: AbsorbPointer(
                              child: TextField(
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: "Seleccionar Persona",
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  border: OutlineInputBorder( // Added border
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                controller: personDisplayController,
                              ),
                            ),
                          ),
                        )
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
                        child: SizedBox(
                          height: 36, // Increased height for better tap target
                          child: TextField(
                            controller: passwordController,
                            obscureText: !_showPassword,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              labelText: "Contraseña",
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              suffixIcon: IconButton(
                                icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder( // Added border
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                        )
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
                        child: SizedBox(
                          height: 36, // Increased height for better tap target
                          child: GestureDetector(
                            onTap: () => showRoleSelection(context),
                            child: AbsorbPointer(
                              child: TextField(
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: "Seleccionar Rol", contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  border: OutlineInputBorder( // Added border
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                controller: roleController,
                              ),
                            ),
                          ),
                        )
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
                    IconButton(onPressed: cancelUpdate, icon: const Icon(Icons.clear_all, color: Colors.deepOrange)),
                    ElevatedButton(onPressed: updateUser, child: const Text("Actualizar")),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Usuarios Registrados", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nombre',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    filterUsers(value);
                  },
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                    child: PaginatedDataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('(ID) Nombres y Apellidos')),
                        DataColumn(label: Text('Usuario')),
                        DataColumn(label: Text('Rol')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Creado')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      source: _usersDataSource, // Our custom data source
                      rowsPerPage: 10, // Set 15 rows per page
                      onPageChanged: (int page) {
                        // Optional: You can add logic here if you need to do something when the page changes
                        print('Page changed to: $page');
                      },
                      // Optional: Adjust available rows per page options
                      availableRowsPerPage: const [5, 10, 15, 20, 50],
                      showCheckboxColumn: false, // Hide checkboxes if not needed
                    ),
                  ),
                )
              ],
            ),
          ),
        ) ,
      ),
    );
  }
}

// Custom DataTableSource to provide data to PaginatedDataTable for Users
class _UsersDataSource extends DataTableSource {
  final List<Map<String, dynamic>> usersList;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  _UsersDataSource({
    required this.usersList,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= usersList.length) {
      return null;
    }
    final user = usersList[index];
    return DataRow(
      cells: [
        DataCell(Text(user['id'].toString())),
        DataCell(Text('(${user['persona']['id']}) ${user['persona']['nombre']} ${user['persona']['apellido']}')),
        DataCell(Text(user['username'])),
        DataCell(Text(user['rol'])),
        DataCell(Text(user['estado'] == true ? 'Activo' : 'Inactivo')),
        DataCell(Text(user['createdAt'].toString())),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(user), // Call the onEdit callback
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(user['id']), // Call the onDelete callback
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false; // We know the exact row count

  @override
  int get rowCount => usersList.length; // Total number of rows

  @override
  int get selectedRowCount => 0; // No rows are selected by default
}