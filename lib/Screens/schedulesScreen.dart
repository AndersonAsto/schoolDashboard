import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:schooldashboard/Global/global.dart';

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

  Map<String,dynamic>? savedSchedules;

  Future<void> _saveSchedule() async {
    final url = Uri.parse('http://localhost:3000/api/schedule/register');
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
      setState(() {
        _listSchedules();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horario guardado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el horario')),
      );
    }
  }

  List<dynamic> schedulesList = [];

  Future<void> _listSchedules() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/schedule/list'));
    if (response.statusCode == 200) {
      setState(() {
        schedulesList = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _listSchedules();
  }

  Future<void> _showTeacherSelection(BuildContext context) async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/user/teachers'));
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
                return ListTile(
                  title: Text('${teacher['id']} - ${teacher['nombre']} ${teacher['apellido']}'),
                  onTap: () {
                    teacherIdController.text = teacher['id'].toString();
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

  Future<void> _showCourseSelection(BuildContext context) async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/course/list'));
    final List<dynamic> courses = jsonDecode(response.body);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Seleccionar Curso'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return ListTile(
                  title: Text('${course['id']} - ${course['nombre']}'),
                  onTap: () {
                    courseIdController.text = course['id'].toString();
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

  void _showDaySelection(BuildContext context) {
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
                return ListTile(
                  title: Text(day),
                  onTap: () {
                    dayController.text = day;
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

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00";
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Horarios", style: TextStyle(color: Colors.white),),backgroundColor: Colors.black,),
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
                  controller: teacherIdController,
                  enabled: false,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Código de Curso"),
                  controller: courseIdController,
                  enabled: false,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Código de Grado"),
                  controller: gradeIdController,
                  enabled: false,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Código de Grado"),
                  controller: dayController,
                  enabled: false,
                ),
                TextField(
                  controller: startTimeController,
                  readOnly: true,
                  decoration: const InputDecoration(hintText: "Hora de Inicio"),
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      final formatted = picked.format(context); // "8:00 AM"
                      final parsed = TimeOfDay(hour: picked.hour, minute: picked.minute);
                      startTimeController.text = _formatTime(parsed);
                    }
                  },
                ),
                TextField(
                  controller: endTimeController,
                  readOnly: true,
                  decoration: const InputDecoration(hintText: "Hora de Finalización"),
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
                  onTap: () => _showTeacherSelection(context),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: const InputDecoration(hintText: "Seleccionar Docentes"),
                      controller: teacherIdController,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showCourseSelection(context),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: const InputDecoration(hintText: "Seleccionar Cursos"),
                      controller: courseIdController,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async => await showGradeSelectionDialog(context, gradeIdController),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: const InputDecoration(hintText: "Seleccionar Grados"),
                      controller: gradeIdController,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showDaySelection(context),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: const InputDecoration(hintText: "Seleccionar Días"),
                      controller: dayController,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(onPressed: _saveSchedule, child: Text("Guardar")),
                const SizedBox(height: 30),
                const Text('Lista de Horarios Registrados'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: schedulesList.length,
                  itemBuilder: (context, index) {
                    final schedule = schedulesList[index];
                    return ListTile(
                      title: Text('ID: ${schedule['id']}. ${schedule['fecha']} \n'
                          '${schedule['hora_inicio']} - ${schedule['hora_fin']}'),
                      subtitle: Text('${schedule['docente']['id']}: (${schedule['docente']['rol'].toString().contains('docente') ? 'Docente' : 'Administrador'})  ${schedule['docente']['username']} \n'
                          '${schedule['docente']['persona']['nombre']} ${schedule['docente']['persona']['apellido']} \n'
                          'Curso: ${schedule['curso']['id']}. ${schedule['curso']['nombre']} \n'
                          'Grado: ${schedule['grado']['id']}. ${schedule['grado']['nombre']} \n'
                          'Estado: ${schedule['estado'] ? 'Activo' : 'Inactivo'}'),
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