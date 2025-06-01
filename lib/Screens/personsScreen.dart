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
    try {
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
        await getPersons(); // Await to ensure persons are reloaded before notification
        Notificaciones.mostrarMensaje(context, "Persona guardada correctamente", color: Colors.green);
      } else {
        Notificaciones.mostrarMensaje(context, "Error al guardar persona", color: Colors.red);
        print("Error al guardar persona: ${response.body}");
      }
    } catch (e) {
      Notificaciones.mostrarMensaje(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al guardar persona: $e");
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
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          personsList = List<Map<String, dynamic>>.from(data);
          // Update the DataTableSource with the new data
          _personsDataSource = _PersonsDataSource(
            personsList: personsList,
            onEdit: _handleEditPerson,
            onDelete: deletePerson,
          );
        });
      } else {
        Notificaciones.mostrarMensaje(context, "Error al obtener datos de personas", color: Colors.red);
        print("Error al obtener datos de personas: ${response.body}");
      }
    } catch (e) {
      Notificaciones.mostrarMensaje(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al obtener datos de personas: $e");
    }
  }

  int? idToEdit;

  Future<void> updatePerson () async {
    if (idToEdit == null) {
      Notificaciones.mostrarMensaje(context, "Selecciona una persona para actualizar", color: Colors.red);
      return;
    }
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

    final url = Uri.parse('${generalURL}api/person/update/$idToEdit');
    try {
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
        final data = jsonDecode(response.body); // You might not need to use 'data' here if the API just confirms success
        setState(() {
          clearTextFields();
          idToEdit = null;
        });
        await getPersons();
        Notificaciones.mostrarMensaje(context, "Persona actualizada correctamente", color: Colors.green);
      } else {
        Notificaciones.mostrarMensaje(context, "Error al actualizar persona", color: Colors.red);
        print("Error al actualizar persona: ${response.body}");
      }
    } catch (e) {
      Notificaciones.mostrarMensaje(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al actualizar persona: $e");
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
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("Persona removida: $id");
        await getPersons();
        Notificaciones.mostrarMensaje(context, "Persona eliminada correctamente", color: Colors.green);
      } else {
        Notificaciones.mostrarMensaje(context, "Error al remover persona", color: Colors.red);
        print("Error al remover persona: ${response.body}");
      }
    } catch (e) {
      Notificaciones.mostrarMensaje(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al remover persona: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getPersons();
    _personsDataSource = _PersonsDataSource(
      personsList: personsList,
      onEdit: _handleEditPerson,
      onDelete: deletePerson,
    );
  }

  late _PersonsDataSource _personsDataSource;

  void _handleEditPerson(Map<String, dynamic> person) {
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
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                    child: PaginatedDataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Nombres y Apellidos')),
                        DataColumn(label: Text('DNI')),
                        DataColumn(label: Text('Teléfono')),
                        DataColumn(label: Text('Correo')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Creado')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      source: _personsDataSource, // Our custom data source
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonsDataSource extends DataTableSource {
  final List<Map<String, dynamic>> personsList;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  _PersonsDataSource({
    required this.personsList,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= personsList.length) {
      return null;
    }
    final person = personsList[index];
    return DataRow(
      cells: [
        DataCell(Text(person['id'].toString())),
        DataCell(Text('${person['nombre']} ${person['apellido']}')),
        DataCell(Text('${person['dni']}')),
        DataCell(Text('${person['telefono']}')),
        DataCell(Text('${person['correo']}')),
        DataCell(Text(person['estado'] == true ? 'Activo' : 'Inactivo')),
        DataCell(Text(person['createdAt'].toString())),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(person), // Call the onEdit callback
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(person['id']), // Call the onDelete callback
            ),
          ],
        )),
      ],
    );
  }
  @override
  bool get isRowCountApproximate => false; // We know the exact row count

  @override
  int get rowCount => personsList.length; // Total number of rows

  @override
  int get selectedRowCount => 0;
}