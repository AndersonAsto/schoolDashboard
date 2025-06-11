import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schooldashboard/Global/global.dart';
import 'package:schooldashboard/Utils/customTextFields.dart';
import 'package:schooldashboard/Utils/customNotifications.dart';

class CoursesScreenClass extends StatefulWidget {
  const CoursesScreenClass({super.key});

  @override
  State<CoursesScreenClass> createState() => _CoursesScreenClassState();
}

class _CoursesScreenClassState extends State<CoursesScreenClass> {
  TextEditingController idController = TextEditingController();
  TextEditingController courseController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController createdAtController = TextEditingController();
  TextEditingController updatedAtController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> filteredCoursesList = [];
  List<Map<String,dynamic>> coursesList = [];
  late _CoursesDataSource _coursesDataSource;
  Map<String, dynamic>? savedCourses;
  int? idToEdit;

  Future<void> saveCourse() async {
    if(courseController.text.trim().isEmpty){
      Notificaciones.showNotification(context, "El nombre del curso no puede estar vacío.", color: Colors.red);
      return;
    }
    if (idToEdit != null) {
      Notificaciones.showNotification(context, "Estás editando un grado. Cancela la edición para guardar uno nuevo.", color: Colors.red);
      return;
    }
    final url = Uri.parse('${generalURL}api/course/register');
    try{
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nombre": courseController.text}),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          savedCourses = data;
          idController.text = data['id'].toString();
          statusController.text = data['estado'].toString();
          createdAtController.text = data['createdAt'].toString();
          updatedAtController.text = data['updatedAt'].toString();
        });
        clearTextFields();
        idToEdit = null;
        getCourses();
        Notificaciones.showNotification(context, "Curso guardado correctamente", color: Colors.teal);
      } else {
        Notificaciones.showNotification(context, "Error al guardar curso", color: Colors.red);
        print("Error al guardar grado: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al guardar curso: $e");
    }
  }

  Future<void> getCourses() async {
    final url = Uri.parse('${generalURL}api/course/list');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          coursesList = List<Map<String, dynamic>>.from(data);
          filteredCoursesList = coursesList;
          _coursesDataSource = _CoursesDataSource(
            coursesList: filteredCoursesList,
            onEdit: _handleEditCourse,
            onDelete: deleteCourse,
          );
        });
      } else {
        Notificaciones.showNotification(context, "Error al obtener cursos", color: Colors.red);
        print("Error al obtener cursos: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al obtener curso: $e");
    }
  }

  Future<void> updateCourse () async {
    if (idToEdit == null) {
      Notificaciones.showNotification(context, "Selecciona un curso para actualizar", color: Colors.red);
      return;
    }
    if (courseController.text.trim().isEmpty) {
      Notificaciones.showNotification(context, "El nombre del grado no puede estar vacío.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/course/update/$idToEdit');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nombre": courseController.text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          clearTextFields();
          idToEdit = null;
        });
        await getCourses();
        Notificaciones.showNotification(context, "Curso actualizado correctamente", color: Colors.teal);
      } else {
        Notificaciones.showNotification(context, "Error al actualizar curso", color: Colors.red);
        print("Error al actualizar curso: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al actualizar curso: $e");
    }
  }

  Future<void> deleteCourse(int id) async {
    final url = Uri.parse('${generalURL}api/course/delete/$id');
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("Curso eliminado: $id");
        await getCourses();
        Notificaciones.showNotification(context, "Curso eliminado correctamente", color: Colors.teal);
      } else {
        Notificaciones.showNotification(context, "Error al eliminar curso", color: Colors.red);
        print("Error al eliminar curso: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al eliminar curso: $e");
    }
  }
  void clearTextFields (){
    idController.clear();
    courseController.clear();
    statusController.clear();
    createdAtController.clear();
    updatedAtController.clear();
    filterCourses("");
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

  void _handleEditCourse(Map<String, dynamic> course) {
    setState(() {
      idToEdit = course['id'];
      idController.text = course['id'].toString();
      courseController.text = course['nombre'];
      statusController.text = course['estado'].toString();
      createdAtController.text = course['createdAt'].toString();
      updatedAtController.text = course['updatedAt'].toString();
    });
  }

  void filterCourses(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredCoursesList = coursesList.where((course) {
        final nombre = course['nombre']?.toLowerCase() ?? '';
        return nombre.contains(lowerQuery);
      }).toList();

      _coursesDataSource = _CoursesDataSource(
        coursesList: filteredCoursesList,
        onEdit: _handleEditCourse,
        onDelete: deleteCourse,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getCourses();
    _coursesDataSource = _CoursesDataSource(
      coursesList: coursesList,
      onEdit: _handleEditCourse,
      onDelete: deleteCourse,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Grados", style: TextStyle(color: Colors.white),),backgroundColor: appColors[3], automaticallyImplyLeading: false,),
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
                    Expanded(
                      child: CustomTextField(label: "Curso", controller: courseController, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]"))]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CommonTimestampsFields(createdAtController: createdAtController, updatedAtController: updatedAtController),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: saveCourse, child: const Text("Guardar")),
                    IconButton(onPressed: cancelUpdate, icon: const Icon(Icons.clear_all, color: Colors.deepOrange)),
                    ElevatedButton(onPressed: updateCourse, child: const Text("Actualizar")),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Cursos Registrados", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre',
                    prefixIcon: const Icon(Icons.search, color: Colors.teal,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    filterCourses(value);
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
                      source: _coursesDataSource,
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

class _CoursesDataSource extends DataTableSource{
  final List<Map<String, dynamic>> coursesList;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  _CoursesDataSource({
    required this.coursesList,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= coursesList.length) {
      return null;
    }
    final course = coursesList[index];
    return DataRow(
      cells: [
        DataCell(Text(course['id'].toString())),
        DataCell(Text(course['nombre'])),
        DataCell(Text(course['estado'] == true ? 'Activo' : 'Inactivo')),
        DataCell(Text(course['createdAt'].toString())),
        DataCell(Text(course['updatedAt'].toString())),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(course),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(course['id']),
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => coursesList.length;

  @override
  int get selectedRowCount => 0;
}
