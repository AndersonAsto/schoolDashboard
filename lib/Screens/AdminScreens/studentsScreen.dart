import 'package:schooldashboard/Utils/customNotifications.dart';
import 'package:schooldashboard/Utils/showDataSelection.dart';
import 'package:schooldashboard/Utils/customTextFields.dart';
import 'package:schooldashboard/Global/global.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class StudentsScreenClass extends StatefulWidget{
  const StudentsScreenClass({super.key});

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
  TextEditingController searchController = TextEditingController();

  int? idToEdit;
  Map<String,dynamic>? savedStudents;
  late _StudentsDataSource _studentsDataSource;
  List<Map<String, dynamic>> studentsList = [];
  List<Map<String, dynamic>> filteredStudentsList = [];

  Future<void> saveStudent() async {
    if(
    studentIdController.text.trim().isEmpty ||
        gradeIdController.text.trim().isEmpty
    ){
      Notificaciones.showNotification(context, "Algunos campos aún están vacíos.", color: Colors.red);
      return;
    }

    if (idToEdit != null) {
      Notificaciones.showNotification(context, "Estás editando un registro. Cancela la edición para guardar uno nuevo.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/student/register');
    try {
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
        await getStudents(); // Await to ensure students are reloaded before notification
        Notificaciones.showNotification(context, "Estudiante guardado correctamente", color: Colors.teal);
      } else {
        Notificaciones.showNotification(context, "Error al guardar estudiante", color: Colors.red);
        print("Error al guardar estudiante: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al guardar estudiante: $e");
    }
  }

  Future<void> getStudents() async {
    final url = Uri.parse('${generalURL}api/student/list');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          studentsList = List<Map<String, dynamic>>.from(data);
          filteredStudentsList = studentsList;
          _studentsDataSource = _StudentsDataSource(
            studentsList: filteredStudentsList,
            onEdit: _handleEditStudent,
            onDelete: deleteStudent,
          );
        });
      } else {
        Notificaciones.showNotification(context, "Error al obtener datos de estudiantes", color: Colors.red);
        print("Error al obtener datos de estudiantes: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al obtener datos de estudiantes: $e");
    }
  }

  Future<void> updateStudent () async {
    if (idToEdit == null) {
      Notificaciones.showNotification(context, "Selecciona un estudiante para actualizar", color: Colors.red);
      return;
    }
    if(
    studentIdController.text.trim().isEmpty ||
        gradeIdController.text.trim().isEmpty
    ){
      Notificaciones.showNotification(context, "Algunos campos aún están vacíos.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/student/update/$idToEdit');
    try {
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
        await getStudents();
        Notificaciones.showNotification(context, "Estudiante actualizado correctamente", color: Colors.teal);
      } else {
        Notificaciones.showNotification(context, "Error al actualizar estudiante", color: Colors.red);
        print("Error al actualizar estudiante: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al actualizar estudiante: $e");
    }
  }

  Future<void> deleteStudent(int id) async {
    final url = Uri.parse('${generalURL}api/student/delete/$id');
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("Estudiante retirado: $id");
        await getStudents();
        Notificaciones.showNotification(context, "Estudiante eliminado correctamente", color: Colors.teal);
      } else {
        Notificaciones.showNotification(context, "Error al retirar estudiante", color: Colors.red);
        print("Error al retirar estudiante: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al retirar estudiante: $e");
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
    filterStudents("");
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

  void _handleEditStudent(Map<String, dynamic> student) {
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
  }

  Future<void> showPersonSelection(BuildContext context) async {
    final url = Uri.parse('${generalURL}api/person/personavailable');
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
      } else {
        Notificaciones.showNotification(context, "Error al cargar personas disponibles", color: Colors.red);
        print("Error al cargar personas disponibles: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión al cargar personas: $e", color: Colors.red);
      print("Error de conexión al cargar personas: $e");
    }
  }

  void filterStudents(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredStudentsList = studentsList.where((student) {
        final nombre = '${student['alumno']['nombre']} ${student['alumno']['apellido']} ${student['grado']['nombre']}'.toLowerCase();
        return nombre.contains(lowerQuery);
      }).toList();

      _studentsDataSource = _StudentsDataSource(
        studentsList: filteredStudentsList,
        onEdit: _handleEditStudent,
        onDelete: deleteStudent,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getStudents();
    _studentsDataSource = _StudentsDataSource(
      studentsList: studentsList,
      onEdit: _handleEditStudent,
      onDelete: deleteStudent,
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
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: "Seleccionar Persona",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
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
                        height: 36, // Consistent height
                        child: GestureDetector(
                          onTap: () async => await showGradeSelection(context, gradeIdController, gradeDisplayController),
                          child: AbsorbPointer(
                            child: TextField(
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: "Seleccionar Grados",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              controller: gradeDisplayController,
                            ),
                          ),
                        ),
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
                    ElevatedButton(onPressed: saveStudent, child: const Text("Guardar")),
                    IconButton(onPressed: cancelUpdate, icon: const Icon(Icons.clear_all, color: Colors.deepOrange)),
                    ElevatedButton(onPressed: updateStudent, child: const Text("Actualizar")),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Estudiantes Registrados', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nombre',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    filterStudents(value);
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
                        DataColumn(label: Text('(ID) Grado')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Creado')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      source: _studentsDataSource,
                      rowsPerPage: 10,
                      onPageChanged: (int page) {
                        print('Page changed to: $page');
                      },
                      availableRowsPerPage: const [5, 10, 15, 20, 50],
                      showCheckboxColumn: false,
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

class _StudentsDataSource extends DataTableSource {
  final List<Map<String, dynamic>> studentsList;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  _StudentsDataSource({
    required this.studentsList,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= studentsList.length) {
      return null;
    }
    final student = studentsList[index];
    return DataRow(
      cells: [
        DataCell(Text(student['id'].toString())),
        DataCell(Text('(${student['alumno']['id']}) ${student['alumno']['nombre']} ${student['alumno']['apellido']}')),
        DataCell(Text('(${student['grado']['id']}) ${student['grado']['nombre']}')),
        DataCell(Text(student['estado'] == true ? 'Activo' : 'Inactivo')),
        DataCell(Text(student['createdAt'].toString())),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(student),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(student['id']),
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => studentsList.length;

  @override
  int get selectedRowCount => 0;
}