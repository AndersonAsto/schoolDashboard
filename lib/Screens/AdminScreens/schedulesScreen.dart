import 'package:schooldashboard/Global/global.dart';
import 'package:schooldashboard/Utils/customNotifications.dart';
import 'package:schooldashboard/Utils/customTextFields.dart';
import 'package:schooldashboard/Utils/showDataSelection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchedulesScreenClass extends StatefulWidget {
  const SchedulesScreenClass({super.key});

  @override
  State<SchedulesScreenClass> createState() => _SchedulesScreenClassState();
}

class _SchedulesScreenClassState extends State<SchedulesScreenClass> {
  TextEditingController idController = TextEditingController();
  TextEditingController teacherIdController = TextEditingController();
  TextEditingController courseIdController = TextEditingController();
  TextEditingController gradeIdController = TextEditingController();
  TextEditingController dayController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController createdAtController = TextEditingController();
  TextEditingController updatedAtController = TextEditingController();
  TextEditingController teacherDisplayController = TextEditingController();
  TextEditingController courseDisplayController = TextEditingController();
  TextEditingController gradeDisplayController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> filteredSchedulesList = [];
  late _SchedulesDataSource _schedulesDataSource;
  List<Map<String, dynamic>> schedulesList = [];
  Map<String,dynamic>? savedSchedules;
  int? idToEdit;

  Future<void> saveSchedule() async {
    if(
    teacherIdController.text.trim().isEmpty ||
        courseIdController.text.trim().isEmpty ||
        gradeIdController.text.trim().isEmpty ||
        dayController.text.trim().isEmpty ||
        startTimeController.text.trim().isEmpty ||
        endTimeController.text.trim().isEmpty
    ){
      Notificaciones.showNotification(context, "Algunos campos aún están vacíos.", color: Colors.red);
      return;
    }

    if (idToEdit != null) {
      Notificaciones.showNotification(context, "Estás editando un registro. Cancela la edición para guardar uno nuevo.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/schedule/register');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "docente_id": int.parse(teacherIdController.text),
          "curso_id": int.parse(courseIdController.text),
          "grado_id": int.parse(gradeIdController.text),
          "fecha": dayController.text,
          "hora_inicio": startTimeController.text,
          "hora_fin": endTimeController.text,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          savedSchedules = data;
          idController.text = data['id'].toString();
          statusController.text = data['estado'].toString();
          createdAtController.text = data['createdAt'].toString();
          updatedAtController.text = data['updatedAt'].toString();
        });
        clearTextFields();
        idToEdit = null;
        await getSchedules(); // Await to ensure schedules are reloaded before notification
        Notificaciones.showNotification(context, "Horario guardado correctamente", color: Colors.teal);
      } else {
        Notificaciones.showNotification(context, "Error al guardar horario", color: Colors.red);
        print("Error al guardar horario: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al guardar horario: $e");
    }
  }

  Future<void> getSchedules() async {
    final url = Uri.parse('${generalURL}api/schedule/list');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          schedulesList = List<Map<String, dynamic>>.from(data);
          // Update the DataTableSource with the new data
          filteredSchedulesList = schedulesList;
          _schedulesDataSource = _SchedulesDataSource(
            schedulesList: filteredSchedulesList,
            onEdit: _handleEditSchedule,
            onDelete: deleteSchedule,
          );
        });
      } else {
        Notificaciones.showNotification(context, "Error al obtener datos de horarios", color: Colors.red);
        print("Error al obtener datos de horarios: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al obtener datos de horarios: $e");
    }
  }

  Future<void> updateSchedule () async {
    if (idToEdit == null) {
      Notificaciones.showNotification(context, "Selecciona un horario para actualizar", color: Colors.red);
      return;
    }
    if(
    teacherIdController.text.trim().isEmpty ||
        courseIdController.text.trim().isEmpty ||
        gradeIdController.text.trim().isEmpty ||
        dayController.text.trim().isEmpty ||
        startTimeController.text.trim().isEmpty ||
        endTimeController.text.trim().isEmpty
    ){
      Notificaciones.showNotification(context, "Algunos campos aún están vacíos.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/schedule/update/$idToEdit');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "docente_id": int.parse(teacherIdController.text),
          "curso_id": int.parse(courseIdController.text),
          "grado_id": int.parse(gradeIdController.text),
          "fecha": dayController.text,
          "hora_inicio": startTimeController.text,
          "hora_fin": endTimeController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          clearTextFields();
          idToEdit = null;
        });
        await getSchedules();
        Notificaciones.showNotification(context, "Horario actualizado correctamente", color: Colors.teal);
      } else {
        Notificaciones.showNotification(context, "Error al actualizar horario", color: Colors.red);
        print("Error al actualizar horario: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al actualizar horario: $e");
    }
  }

  Future<void> deleteSchedule(int id) async {
    final url = Uri.parse('${generalURL}api/schedule/delete/$id');
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("Horario eliminado: $id");
        await getSchedules();
        Notificaciones.showNotification(context, "Horario eliminado correctamente", color: Colors.teal);
      } else {
        Notificaciones.showNotification(context, "Error al eliminar horario", color: Colors.red);
        print("Error al eliminar horario: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al eliminar horario: $e");
    }
  }

  void clearTextFields (){
    idController.clear();
    teacherIdController.clear();
    courseIdController.clear();
    gradeIdController.clear();
    dayController.clear();
    startTimeController.clear();
    endTimeController.clear();
    statusController.clear();
    createdAtController.clear();
    updatedAtController.clear();
    teacherDisplayController.clear();
    courseDisplayController.clear();
    gradeDisplayController.clear();
    filterSchedules("");
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

  void _handleEditSchedule(Map<String, dynamic> schedule) {
    setState(() {
      idToEdit = schedule['id'];
      idController.text = schedule['id'].toString();
      teacherIdController.text = schedule['docente']['id'].toString();
      teacherDisplayController.text = '${schedule['docente']['id']} - ${schedule['docente']['persona']['nombre']} ${schedule['docente']['persona']['apellido']}';
      courseIdController.text = schedule['curso']['id'].toString();
      courseDisplayController.text = '${schedule['curso']['id']} - ${schedule['curso']['nombre']}';
      gradeIdController.text = schedule['grado']['id'].toString();
      gradeDisplayController.text = '${schedule['grado']['id']} - ${schedule['grado']['nombre']}';
      dayController.text = schedule['fecha']; // Assuming 'fecha' is the day
      startTimeController.text = schedule['hora_inicio'];
      endTimeController.text = schedule['hora_fin'];
      statusController.text = schedule['estado'].toString();
      createdAtController.text = schedule['createdAt'].toString();
      updatedAtController.text = schedule['updatedAt'].toString();
    });
  }

  Future<void> showTeacherSelection(BuildContext context) async {
    final url = Uri.parse('${generalURL}api/user/teachers');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> teachers = jsonDecode(response.body);

        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Seleccionar Docente'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];
                    return Card(
                      child: ListTile(
                        title: Text('${teacher['id']} - ${teacher['nombre']} ${teacher['apellido']}'),
                        onTap: () {
                          teacherIdController.text = teacher['id'].toString();
                          teacherDisplayController.text = '${teacher['id']} - ${teacher['nombre']} ${teacher['apellido']}';
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
        Notificaciones.showNotification(context, "Error al cargar docentes disponibles", color: Colors.red);
        print("Error al cargar docentes disponibles: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión al cargar docentes: $e", color: Colors.red);
      print("Error de conexión al cargar docentes: $e");
    }
  }

  void showDaySelection(BuildContext context) {
    final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Seleccionar Día'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                return Card(
                  child: ListTile(
                    title: Text(day),
                    onTap: () {
                      dayController.text = day;
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

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00";
  }

  void filterSchedules(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredSchedulesList = schedulesList;
      } else {
        filteredSchedulesList = schedulesList.where((schedule) {
          final fullName = '${schedule['docente']['persona']['nombre']} ${schedule['docente']['persona']['apellido']} ${schedule['curso']['nombre']} ${schedule['grado']['nombre']} ${schedule['fecha']} ${schedule['hora_inicio']} ${schedule['hora_fin']}'.toLowerCase();
          return fullName.contains(lowerQuery);
        }).toList();
      }

      _schedulesDataSource = _SchedulesDataSource(
        schedulesList: filteredSchedulesList,
        onEdit: _handleEditSchedule,
        onDelete: deleteSchedule,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getSchedules();
    _schedulesDataSource = _SchedulesDataSource(
      schedulesList: schedulesList,
      onEdit: _handleEditSchedule,
      onDelete: deleteSchedule,
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Horarios", style: TextStyle(color: Colors.white),),backgroundColor: Colors.black, automaticallyImplyLeading: false,),
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
                    Expanded(child: CustomTextField(label: "Código de Docente", controller: teacherIdController, enabled: false,)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 36, // Consistent height
                        child: GestureDetector(
                          onTap: () => showTeacherSelection(context),
                          child: AbsorbPointer(
                            child: TextField(
                              style: const TextStyle(fontSize: 13), // Use const TextStyle
                              decoration: InputDecoration(
                                hintText: "Seleccionar Docentes",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              controller: teacherDisplayController,
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
                    Expanded(child: CustomTextField(label: "Código de Curso", controller: courseIdController, enabled: false,)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 36, // Consistent height
                        child: GestureDetector(
                          onTap: () async => await showCourseSelection(context, courseIdController, courseDisplayController),
                          child: AbsorbPointer(
                            child: TextField(
                              style: const TextStyle(fontSize: 13), // Use const TextStyle
                              decoration: InputDecoration(
                                hintText: "Seleccionar Cursos",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              controller: courseDisplayController,
                            ),
                          ),
                        ),
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: "Código de Grado", controller: gradeIdController, enabled: false,)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 36, // Consistent height
                        child: GestureDetector(
                          onTap: () async => await showGradeSelection(context, gradeIdController, gradeDisplayController),
                          child: AbsorbPointer(
                            child: TextField(
                              style: const TextStyle(fontSize: 13), // Use const TextStyle
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
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: "Día", controller: dayController, enabled: false)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 36, // Consistent height
                        child: GestureDetector(
                          onTap: () => showDaySelection(context),
                          child: AbsorbPointer(
                            child: TextField(
                              style: const TextStyle(fontSize: 13), // Use const TextStyle
                              decoration: InputDecoration(
                                hintText: "Seleccionar Días",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              controller: dayController,
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
                    Expanded(
                      child: SizedBox(
                        height: 36, // Consistent height
                        child: TextField(
                          controller: startTimeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Hora de Inicio",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          style: const TextStyle(fontSize: 13),
                          onTap: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              startTimeController.text = _formatTime(picked);
                            }
                          },
                        ),
                      )
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: endTimeController,
                          style: const TextStyle(fontSize: 13),
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Hora de Finalización",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onTap: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              endTimeController.text = _formatTime(picked);
                            }
                          },
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
                    ElevatedButton(onPressed: saveSchedule, child: const Text("Guardar")),
                    IconButton(onPressed: cancelUpdate, icon: const Icon(Icons.clear_all, color: Colors.deepOrange)),
                    ElevatedButton(onPressed: updateSchedule, child: const Text("Actualizar")),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Horarios Registrados', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nombre',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    filterSchedules(value);
                  },
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                    child: PaginatedDataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('(ID) Docente')),
                        DataColumn(label: Text('Curso')),
                        DataColumn(label: Text('Grado')),
                        DataColumn(label: Text('Día')),
                        DataColumn(label: Text('Hora Inicio')),
                        DataColumn(label: Text('Hora Fin')),
                        DataColumn(label: Text('Estado')),
                        //DataColumn(label: Text('Creado')),
                        DataColumn(label: Text('Acciones'))
                      ],
                      source: _schedulesDataSource,
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

class _SchedulesDataSource extends DataTableSource {
  final List<Map<String, dynamic>> schedulesList;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  _SchedulesDataSource({
    required this.schedulesList,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= schedulesList.length) {
      return null;
    }
    final schedule = schedulesList[index];
    return DataRow(
      cells: [
        DataCell(Text(schedule['id'].toString())),
        DataCell(Text('(${schedule['docente']['id']}) ${schedule['docente']['persona']['nombre']} ${schedule['docente']['persona']['apellido']}')),
        DataCell(Text('(${schedule['curso']['id']}) ${schedule['curso']['nombre']}')),
        DataCell(Text('(${schedule['grado']['id']}) ${schedule['grado']['nombre']}')),
        DataCell(Text(schedule['fecha'])),
        DataCell(Text(schedule['hora_inicio'])),
        DataCell(Text(schedule['hora_fin'])),
        DataCell(Text(schedule['estado'] == true ? 'Activo' : 'Inactivo')),
        //DataCell(Text(schedule['createdAt'].toString())),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(schedule), // Call the onEdit callback
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(schedule['id']), // Call the onDelete callback
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false; // We know the exact row count

  @override
  int get rowCount => schedulesList.length; // Total number of rows

  @override
  int get selectedRowCount => 0; // No rows are selected by default
}
