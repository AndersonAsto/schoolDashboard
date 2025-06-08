import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:schooldashboard/Global/global.dart';
import 'package:schooldashboard/Utils/customNotifications.dart';
import 'package:schooldashboard/Utils/customTextFields.dart';

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

  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredGradesList = [];

  List<Map<String, dynamic>> gradesList = [];
  Map<String, dynamic>? savedGrades;
  int? idToEdit;
  late _GradesDataSource _gradesDataSource;

  Future<void> saveGrade() async {
    if (gradeController.text.trim().isEmpty) {
      Notificaciones.mostrarMensaje(context, "El nombre del grado no puede estar vacío.", color: Colors.red);
      return;
    }

    if (idToEdit != null) {
      Notificaciones.mostrarMensaje(context, "Estás editando un grado. Cancela la edición para guardar uno nuevo.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/grade/register');
    try {
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
        await getGrades();
        Notificaciones.mostrarMensaje(context, "Grado guardado correctamente", color: Colors.green);
      } else {
        Notificaciones.mostrarMensaje(context, "Error al guardar grado", color: Colors.red);
        print("Error al guardar grado: ${response.body}");
      }
    } catch (e) {
      Notificaciones.mostrarMensaje(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al guardar grado: $e");
    }
  }

  void clearTextFields() {
    idController.clear();
    gradeController.clear();
    statusController.clear();
    createdAtController.clear();
    updatedAtController.clear();
    filterGrades("");
  }

  Future<void> getGrades() async {
    final url = Uri.parse('${generalURL}api/grade/list');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          gradesList = List<Map<String, dynamic>>.from(data);
          filteredGradesList = gradesList;
          _gradesDataSource = _GradesDataSource(
            gradesList: filteredGradesList,
            onEdit: _handleEditGrade,
            onDelete: deleteGrade,
          );
        });
      } else {
        Notificaciones.mostrarMensaje(context, "Error al obtener grados", color: Colors.red);
        print("Error al obtener grados: ${response.body}");
      }
    } catch (e) {
      Notificaciones.mostrarMensaje(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al obtener grados: $e");
    }
  }

  Future<void> updateGrade() async {
    if (idToEdit == null) {
      Notificaciones.mostrarMensaje(context, "Selecciona un grado para actualizar", color: Colors.red);
      return;
    }
    if (gradeController.text.trim().isEmpty) {
      Notificaciones.mostrarMensaje(context, "El nombre del grado no puede estar vacío.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/grade/update/$idToEdit');
    try {
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
        await getGrades();
        Notificaciones.mostrarMensaje(context, "Grado actualizado correctamente", color: Colors.green);
      } else {
        Notificaciones.mostrarMensaje(context, "Error al actualizar grado", color: Colors.red);
        print("Error al actualizar grado: ${response.body}");
      }
    } catch (e) {
      Notificaciones.mostrarMensaje(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al actualizar grado: $e");
    }
  }

  Future<void> cancelUpdate() async {
    if (idToEdit != null) {
      setState(() {
        clearTextFields();
        idToEdit = null;
      });
      Notificaciones.mostrarMensaje(context, "Edición cancelada.", color: Colors.orange);
    } else {
      Notificaciones.mostrarMensaje(context, "No hay edición activa para cancelar.", color: Colors.blueGrey);
    }
  }

  Future<void> deleteGrade(int id) async {
    final url = Uri.parse('${generalURL}api/grade/delete/$id');
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("Grado eliminado: $id");
        await getGrades();
        Notificaciones.mostrarMensaje(context, "Grado eliminado correctamente", color: Colors.green);
      } else {
        Notificaciones.mostrarMensaje(context, "Error al eliminar grado", color: Colors.red);
        print("Error al eliminar grado: ${response.body}");
      }
    } catch (e) {
      Notificaciones.mostrarMensaje(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al eliminar grado: $e");
    }
  }

  void _handleEditGrade(Map<String, dynamic> grade) {
    setState(() {
      idToEdit = grade['id'];
      idController.text = grade['id'].toString();
      gradeController.text = grade['nombre'];
      statusController.text = grade['estado'].toString();
      createdAtController.text = grade['createdAt'].toString();
      updatedAtController.text = grade['updatedAt'].toString();
    });
  }

  void filterGrades(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredGradesList = gradesList.where((grade) {
        final nombre = grade['nombre']?.toLowerCase() ?? '';
        return nombre.contains(lowerQuery);
      }).toList();

      _gradesDataSource = _GradesDataSource(
        gradesList: filteredGradesList,
        onEdit: _handleEditGrade,
        onDelete: deleteGrade,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getGrades();
    _gradesDataSource = _GradesDataSource(
      gradesList: gradesList,
      onEdit: _handleEditGrade,
      onDelete: deleteGrade,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Grados", style: TextStyle(color: Colors.white),), backgroundColor: Colors.black, automaticallyImplyLeading: false,),
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
                      child: CustomTextField(label: "Grado", controller: gradeController, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]"))])
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
                    IconButton(onPressed: clearTextFields, icon: const Icon(Icons.delete_forever_outlined, color: Colors.deepOrange)),
                    ElevatedButton(onPressed: updateGrade, child: const Text("Actualizar")),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Grados Registrados", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre',
                    prefixIcon: Icon(Icons.search, color: Colors.teal,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    filterGrades(value);
                  },
                ),
                const SizedBox(height: 20),

                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                    child: PaginatedDataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Grado')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Creado')),
                        DataColumn(label: Text('Actualizado')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      source: _gradesDataSource, // Our custom data source
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

class _GradesDataSource extends DataTableSource {
  final List<Map<String, dynamic>> gradesList;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  _GradesDataSource({
    required this.gradesList,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= gradesList.length) {
      return null;
    }
    final grade = gradesList[index];
    return DataRow(
      cells: [
        DataCell(Text(grade['id'].toString())),
        DataCell(Text(grade['nombre'])),
        DataCell(Text(grade['estado'] == true ? 'Activo' : 'Inactivo')),
        DataCell(Text(grade['createdAt'].toString())),
        DataCell(Text(grade['updatedAt'].toString())),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(grade), // Call the onEdit callback
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(grade['id']), // Call the onDelete callback
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false; // We know the exact row count

  @override
  int get rowCount => gradesList.length; // Total number of rows

  @override
  int get selectedRowCount => 0; // No rows are selected by default
}