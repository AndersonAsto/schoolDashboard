import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schooldashboard/Global/global.dart';
import 'package:schooldashboard/Utils/customTextFields.dart';
import 'package:schooldashboard/Utils/customNotifications.dart';

class AssistancesScreenClass extends StatefulWidget{
  final int docenteId;
  final String userName;

  const AssistancesScreenClass({
    super.key,
    required this.docenteId,
    required this.userName
  });

  @override
  State<AssistancesScreenClass> createState() => _AssistancesScreenClassState();
}

class _AssistancesScreenClassState extends State<AssistancesScreenClass> {
  TextEditingController idController = TextEditingController();
  TextEditingController studentIdController = TextEditingController();
  TextEditingController scheduleIdController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController hourController = TextEditingController();
  TextEditingController createdAtController = TextEditingController();
  TextEditingController updatedAtController = TextEditingController();
  TextEditingController studentDisplayController = TextEditingController();
  TextEditingController scheduleDisplayController = TextEditingController();

  int? gradeId;
  int? idToEdit; // ID del elemento que se está editando
  List<String> dias = [];
  String? diaSeleccionado;
  List<dynamic> horarios = [];
  String? horarioSeleccionado;
  Map<String, dynamic>? horarioSeleccionadoObj; // Objeto completo del horario seleccionado
  List<Map<String, dynamic>> assistancesList = []; // Lista de asistencias para la tabla
  late _AssistancesDataSource _assistancesDataSource; // Origen de datos para PaginatedDataTable

  Future<void> saveAssistance() async {
    if (
      studentIdController.text.isEmpty ||
      scheduleIdController.text.isEmpty ||
      statusController.text.isEmpty
    ) {
      Notificaciones.showNotification(context, "Por favor completa los campos obligatorios", color: appColors[0]);
      return;
    }

    if (idToEdit != null) {
      Notificaciones.showNotification(context, "Estás editando un registro. Cancela la edición para guardar uno nuevo.", color: appColors[0]);
      return;
    }

    // Auto-poblar fecha y hora con el momento actual
    final DateTime now = DateTime.now();
    dateController.text = DateFormat('yyyy-MM-dd').format(now);
    hourController.text = _formatTime(TimeOfDay.fromDateTime(now));

    final url = Uri.parse('${generalURL}api/assistance/register');
    final Map<String, dynamic> payload = {
      'alumno_id': int.parse(studentIdController.text),
      'horario_id': int.parse(scheduleIdController.text),
      'estado': statusController.text,
      'fecha': dateController.text,
      'hora': hourController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        Notificaciones.showNotification(context, "Asistencia registrada correctamente", color: Colors.teal);
        clearTextFields();
        // Después de guardar, refresca la lista con los filtros actuales (si los hay)
        if (diaSeleccionado != null && horarioSeleccionadoObj != null) {
          await getAssistances(day: diaSeleccionado, horarioId: horarioSeleccionadoObj!['id']);
        } else {
          await getAssistances(); // Si no hay filtros específicos, carga todas para el docente actual
        }
      } else {
        Notificaciones.showNotification(context, "Error al registrar: ${response.body}", color: Colors.red);
        print("Error al registrar: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión: $e", color: Colors.red);
      print("Error de conexión al registrar: $e");
    }
  }

  // Limpia todos los campos de texto del formulario (PERO MANTIENE LA SELECCIÓN DE DROPDOWNS)
  void clearTextFields() {
    idController.clear();
    studentIdController.clear();
    scheduleIdController.clear();
    statusController.clear(); // Se comenta si el estado se selecciona desde un picker
    dateController.clear();
    hourController.clear();
    createdAtController.clear();
    updatedAtController.clear();
    studentDisplayController.clear();
    scheduleDisplayController.clear();
    setState(() {
      idToEdit = null; // Asegura que no estemos en modo edición al limpiar campos
      // Las variables de estado de los Dropdowns NO se limpian aquí para mantener el filtro
    });
  }

  // Maneja la edición de una asistencia desde la tabla
  void _handleEditAssistance(Map<String, dynamic> assistance) {
    setState(() {
      idToEdit = assistance['id'];
      idController.text = assistance['id'].toString();
      studentIdController.text = assistance['estudiante']['id'].toString();
      studentDisplayController.text = '${assistance['estudiante']['id']} - ${assistance['estudiante']['alumno']['nombre']} ${assistance['estudiante']['alumno']['apellido']}';

      final Map<String, dynamic> originalHorario = assistance['horario'];
      final String selectedDay = originalHorario['fecha']?.toString() ?? '';
      diaSeleccionado = selectedDay;

      horarioSeleccionado = null;
      horarioSeleccionadoObj = null;
      gradeId = null;

      scheduleIdController.text = originalHorario['id'].toString();

      statusController.text = assistance['estado']?.toString() ?? ''; // Estado de la asistencia

      // AUTO-POBLAR FECHA Y HORA CON EL MOMENTO ACTUAL AL EDITAR
      final DateTime now = DateTime.now();
      dateController.text = DateFormat('yyyy-MM-dd').format(now);
      hourController.text = _formatTime(TimeOfDay.fromDateTime(now));

      createdAtController.text = assistance['createdAt']?.toString() ?? '';
      updatedAtController.text = assistance['updatedAt']?.toString() ?? '';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (diaSeleccionado != null) {
        await obtenerHorariosPorDia(diaSeleccionado!);

        setState(() {
          final int? targetScheduleId = int.tryParse(scheduleIdController.text);
          if (targetScheduleId != null) {
            horarioSeleccionadoObj = horarios.firstWhere(
                  (h) => h['id'] == targetScheduleId,
              orElse: () => null,
            );

            if (horarioSeleccionadoObj != null) {
              final String hCurso = horarioSeleccionadoObj!['curso']?.toString() ?? 'N/A';
              final String hGrado = horarioSeleccionadoObj!['grado']?.toString() ?? 'N/A';
              final String hHoraInicio = horarioSeleccionadoObj!['hora_inicio']?.substring(0,5) ?? 'N/A';
              final String hHoraFin = horarioSeleccionadoObj!['hora_fin']?.substring(0,5) ?? 'N/A';
              horarioSeleccionado = "$hCurso ($hHoraInicio - $hHoraFin) ($hGrado)";

              gradeId = int.tryParse(horarioSeleccionadoObj!['grado_id']?.toString() ?? '');
              scheduleDisplayController.text = horarioSeleccionado!;
            } else {
              horarioSeleccionado = null;
              gradeId = null;
              scheduleDisplayController.clear();
              Notificaciones.showNotification(context, "Horario asociado a la asistencia no encontrado para el día seleccionado.", color: Colors.orange);
            }
          } else {
            horarioSeleccionado = null;
            gradeId = null;
            scheduleDisplayController.clear();
            Notificaciones.showNotification(context, "ID de horario no válido para la asistencia.", color: Colors.orange);
          }
        });
        if (diaSeleccionado != null && horarioSeleccionadoObj != null) {
          getAssistances(day: diaSeleccionado, horarioId: horarioSeleccionadoObj!['id']);
        } else {
          getAssistances();
        }
      }
    });
  }

  // Obtiene los días con clases para el docente
  Future<void> obtenerDiasConClases() async {
    print("Docente ID para obtener días: ${widget.docenteId}");
    try {
      final response = await http.get(Uri.parse('${generalURL}api/schedule/days/${widget.docenteId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          dias = List<String>.from(data['dias']);
          if (dias.isNotEmpty) {
            diaSeleccionado = dias[0];
            obtenerHorariosPorDia(diaSeleccionado!);
          } else {
            dias = [];
            diaSeleccionado = null;
            horarios = [];
            horarioSeleccionado = null;
            horarioSeleccionadoObj = null;
          }
        });
      } else {
        Notificaciones.showNotification(context, "Error al obtener días con clases: ${response.body}", color: Colors.red);
        print("Error al obtener días: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión al obtener días: $e", color: Colors.red);
      print("Error de conexión: $e");
    }
  }

  // Obtiene los horarios para un día específico del docente
  Future<void> obtenerHorariosPorDia(String dia) async {
    try {
      final response = await http.get(Uri.parse('${generalURL}api/schedule/${widget.docenteId}/for-day?dia=$dia'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          horarios = data['horarios'] ?? [];
          if (horarios.isNotEmpty) {
            final cursoNombre = horarios[0]['curso']?.toString() ?? 'N/A';
            final horaInicio = horarios[0]['hora_inicio']?.substring(0,5) ?? 'N/A';
            final horaFin = horarios[0]['hora_fin']?.substring(0,5) ?? 'N/A';
            final gradoNombre = horarios[0]['grado']?.toString() ?? 'N/A';
            horarioSeleccionado = "$cursoNombre ($horaInicio - $horaFin) ($gradoNombre)";
            horarioSeleccionadoObj = horarios[0];
            scheduleIdController.text = horarioSeleccionadoObj?['id'].toString() ?? '';
            scheduleDisplayController.text = horarioSeleccionado ?? '';
            gradeId = int.tryParse(horarioSeleccionadoObj?['grado_id']?.toString() ?? '');
          } else {
            horarioSeleccionado = null;
            horarioSeleccionadoObj = null;
            scheduleIdController.clear();
            scheduleDisplayController.clear();
            gradeId = null;
          }
        });
        // Después de cargar los horarios, filtra la tabla de asistencias
        if (horarioSeleccionadoObj != null) {
          getAssistances(day: dia, horarioId: horarioSeleccionadoObj!['id']);
        } else {
          getAssistances(day: dia); // Si no hay horario específico, muestra todas para el día seleccionado
        }
      } else {
        Notificaciones.showNotification(context, "Error al obtener horarios por día: ${response.body}", color: Colors.red);
        print("Error al obtener horarios: ${response.body}");
        setState(() {
          horarios = [];
          horarioSeleccionado = null;
          horarioSeleccionadoObj = null;
          scheduleIdController.clear();
          scheduleDisplayController.clear();
          gradeId = null;
        });
        getAssistances(day: dia); // Si falla la carga de horarios, filtra solo por día (si es posible)
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión al obtener horarios: $e", color: Colors.red);
      print("Error de conexión: $e");
      setState(() {
        horarios = [];
        horarioSeleccionado = null;
        horarioSeleccionadoObj = null;
        scheduleIdController.clear();
        scheduleDisplayController.clear();
        gradeId = null;
      });
      getAssistances(day: dia); // Si hay error de conexión, filtra solo por día (si es posible)
    }
  }

  // Obtiene las asistencias, con filtros opcionales de día y horario
  Future<void> getAssistances({String? day, int? horarioId}) async {
    try {
      String url = '${generalURL}api/assistance/filter'; // URL de la API de filtro
      Map<String, String> queryParams = {};
      queryParams['docente_id'] = widget.docenteId.toString(); // Siempre incluir docente_id

      if (day != null && day.isNotEmpty) {
        queryParams['fecha_horario'] = day;
      }
      if (horarioId != null) {
        queryParams['horario_id'] = horarioId.toString();
      }
      if (queryParams.isNotEmpty) {
        url = Uri.parse('$url?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}').toString();
      }

      print("Obteniendo asistencias de la URL: $url"); // Para depuración
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          assistancesList = List<Map<String, dynamic>>.from(data);
          _assistancesDataSource.updateData(assistancesList); // Actualiza el origen de datos de la tabla
        });
      } else {
        Notificaciones.showNotification(context, "Error al obtener asistencias: ${response.body}", color: Colors.red);
        print("Error al obtener asistencias: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión al obtener asistencias: $e", color: Colors.red);
      print("Error de conexión al obtener asistencias: $e");
    }
  }

  // Muestra un diálogo para seleccionar estudiantes por grado
  Future<void> showStudentsByGradeDialog(BuildContext context, int gradeId) async {
    final url = Uri.parse('${generalURL}api/student/by-grade/$gradeId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> students = jsonDecode(response.body);

        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Seleccionar Estudiante'),
              content: SizedBox(
                width: double.maxFinite,
                child: students.isEmpty
                    ? const Text("No hay estudiantes en este grado")
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      child: ListTile(
                        title: Text('${student['id']} - ${student['nombre']} ${student['apellido']}'),
                        onTap: () {
                          studentIdController.text = student['id'].toString();
                          studentDisplayController.text =
                          '${student['id']} - ${student['nombre']} ${student['apellido']}';
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
        Notificaciones.showNotification(context, "Error al cargar estudiantes: ${response.body}", color: Colors.red);
        print("Error al cargar estudiantes: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión al cargar estudiantes: $e", color: Colors.red);
      print("Error de conexión: $e");
    }
  }

  // Muestra un diálogo para seleccionar el estado de la asistencia
  void showStatusSelection(BuildContext context) {
    final details = ['P', 'A', 'T']; // P: Presente, A: Ausente, T: Tarde

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Seleccionar Estado'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: details.length,
              itemBuilder: (context, index) {
                final detail = details[index];
                return Card(
                  child: ListTile(
                    title: Text(detail),
                    onTap: () {
                      statusController.text = detail;
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

  // Actualiza una asistencia existente
  Future<void> updateAssistance() async {
    if (idToEdit == null) {
      Notificaciones.showNotification(context, "Selecciona una asistencia para actualizar", color: appColors[0]);
      return;
    }
    if (
    // studentIdController.text.isEmpty // || // Puede que no necesites actualizar esto, depende del backend
        //scheduleIdController.text.isEmpty || // Puede que no necesites actualizar esto, depende del backend
        statusController.text.isEmpty //||
        //dateController.text.isEmpty ||
        //hourController.text.isEmpty
    ) {
      Notificaciones.showNotification(context, "Los campos de Estado, Fecha y Hora no pueden estar vacíos.", color: appColors[0]);
      return;
    }

    final url = Uri.parse('${generalURL}api/assistance/update/$idToEdit'); // Asumiendo esta ruta de actualización
    final Map<String, dynamic> payload = {
      // 'alumno_id': int.parse(studentIdController.text), // Considera si se debe actualizar
      // 'horario_id': int.parse(scheduleIdController.text), // Considera si se debe actualizar
      'estado': statusController.text,
      'fecha': dateController.text,
      'hora': hourController.text,
    };

    print("Actualizando URL: $url con payload: $payload"); // Impresión para depuración

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        Notificaciones.showNotification(context, "Asistencia actualizada correctamente", color: Colors.green);
        clearTextFields();
        idToEdit = null; // Limpia idToEdit después de una actualización exitosa
        // Después de actualizar, refresca con los filtros actuales (si los hay)
        if (diaSeleccionado != null && horarioSeleccionadoObj != null) {
          await getAssistances(day: diaSeleccionado, horarioId: horarioSeleccionadoObj!['id']);
        } else {
          await getAssistances(); // Retorno a todas las asistencias para el docente actual si no hay filtros específicos
        }
      } else {
        Notificaciones.showNotification(context, "Error al actualizar asistencia: ${response.body}", color: Colors.red);
        print("Error al actualizar asistencia: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión al actualizar: $e", color: Colors.red);
      print("Error de conexión al actualizar: $e");
    }
  }

  // Elimina una asistencia por su ID
  Future<void> deleteAssistance(int id) async {
    final url = Uri.parse('${generalURL}api/assistance/list/$id'); // Asumiendo esta ruta de eliminación
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        Notificaciones.showNotification(context, "Asistencia eliminada correctamente", color: Colors.green);
        // Después de eliminar, refresca con los filtros actuales (si los hay)
        if (diaSeleccionado != null && horarioSeleccionadoObj != null) {
          await getAssistances(day: diaSeleccionado, horarioId: horarioSeleccionadoObj!['id']);
        } else {
          await getAssistances(); // Retorno a todas las asistencias para el docente actual si no hay filtros específicos
        }
      } else {
        Notificaciones.showNotification(context, "Error al eliminar asistencia: ${response.body}", color: Colors.red);
        print("Error al eliminar asistencia: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión al eliminar: $e", color: Colors.red);
      print("Error de conexión al eliminar: $e");
    }
  }

  // Formatea un objeto TimeOfDay a una cadena HH:mm:ss
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = DateTime.now().second.toString().padLeft(2, '0');
    return "$hour:$minute:$second";
  }

  @override
  void initState() {
    super.initState();
    _assistancesDataSource = _AssistancesDataSource(
      assistancesList: assistancesList,
      onEdit: _handleEditAssistance,
      onDelete: deleteAssistance,
    );
    // Inicia la secuencia de carga de datos: días -> horarios (primer día) -> asistencias (filtradas)
    obtenerDiasConClases();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Asistencias", style: TextStyle(color: Colors.white),),backgroundColor: appColors[3], automaticallyImplyLeading: false,),
      body: SelectableRegion(
        focusNode: FocusNode(),
        selectionControls: materialTextSelectionControls,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: dias.isEmpty && diaSeleccionado == null
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: diaSeleccionado,
                        hint: const Text("Selecciona un día"),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: dias.map((dia) {
                          return DropdownMenuItem<String>(
                            value: dia,
                            child: Text(dia),
                          );
                        }).toList(),
                        onChanged: (nuevoDia) {
                          setState(() {
                            diaSeleccionado = nuevoDia;
                            horarioSeleccionado = null; // Limpia la selección previa
                            horarios = []; // Limpia horarios para forzar la recarga
                            horarioSeleccionadoObj = null;
                            scheduleIdController.clear();
                            scheduleDisplayController.clear();
                            gradeId = null;
                            studentIdController.clear();
                            studentDisplayController.clear();
                          });
                          if (nuevoDia != null) {
                            obtenerHorariosPorDia(nuevoDia);
                            getAssistances(day: nuevoDia); // Actualiza la tabla de asistencias por día
                          } else {
                            getAssistances(); // Si no hay día seleccionado, muestra todas para el docente actual
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: (horarios.isEmpty && horarioSeleccionado == null)
                          ? const Center(child: Text("Sin horarios disponibles"))
                          : DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: horarioSeleccionado,
                        hint: const Text("Selecciona horario"),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: horarios.map<DropdownMenuItem<String>>((horario) {
                          // Accede a las propiedades directamente como strings según la respuesta de la API
                          final cursoNombre = horario['curso']?.toString() ?? 'N/A';
                          final horaInicio = horario['hora_inicio']?.substring(0,5) ?? 'N/A';
                          final horaFin = horario['hora_fin']?.substring(0,5) ?? 'N/A';
                          final gradoNombre = horario['grado']?.toString() ?? 'N/A';
                          String descripcion = "$cursoNombre ($horaInicio - $horaFin) ($gradoNombre)";
                          return DropdownMenuItem<String>(
                            value: descripcion,
                            child: Text(descripcion),
                          );
                        }).toList(),
                        onChanged: (nuevoHorario) {
                          setState(() {
                            horarioSeleccionado = nuevoHorario;
                            // Encuentra el objeto horario que coincide con la descripción
                            horarioSeleccionadoObj = horarios.firstWhere((horario) {
                              final currentCursoNombre = horario['curso']?.toString() ?? 'N/A';
                              final currentHoraInicio = horario['hora_inicio']?.substring(0,5) ?? 'N/A';
                              final currentHoraFin = horario['hora_fin']?.substring(0,5) ?? 'N/A';
                              final currentGradoNombre = horario['grado']?.toString() ?? 'N/A';
                              String currentDescripcion = "$currentCursoNombre ($currentHoraInicio - $currentHoraFin) ($currentGradoNombre)";
                              return currentDescripcion == nuevoHorario;
                            }, orElse: () => null);

                            scheduleIdController.text = horarioSeleccionadoObj?['id'].toString() ?? '';
                            scheduleDisplayController.text = nuevoHorario ?? '';
                            gradeId = int.tryParse(horarioSeleccionadoObj?['grado_id']?.toString() ?? '');
                            studentIdController.clear(); // Limpia la selección de estudiante cuando cambia el horario
                            studentDisplayController.clear();
                          });
                          // Después de seleccionar un horario, filtra la tabla de asistencias por él
                          if (diaSeleccionado != null && horarioSeleccionadoObj != null) {
                            getAssistances(day: diaSeleccionado, horarioId: horarioSeleccionadoObj!['id']);
                          } else if (diaSeleccionado != null) {
                            getAssistances(day: diaSeleccionado); // Retorno a filtrar solo por día
                          } else {
                            getAssistances(); // Sin filtros
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CommonInfoFields(idController: idController, statusController: statusController),
                const SizedBox(height: 10),
                // Campo para seleccionar el estado de la asistencia
                SizedBox(
                  height: 36,
                  child: GestureDetector(
                    onTap: () => showStatusSelection(context),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: statusController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Seleccionar Estado",
                          labelText: "Estado",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: "Código de Estudiante", controller: studentIdController, enabled: false)),
                    const SizedBox(width: 10),
                    Expanded(child: CustomTextField(label: "Código de Horario", controller: scheduleIdController, enabled: false)),
                  ],
                ),
                const SizedBox(height: 10),
                CommonTimestampsFields(createdAtController: createdAtController, updatedAtController: updatedAtController),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: CustomTextField(
                          label: 'Fecha',
                          controller: dateController,
                          enabled: false, // NO editable directamente
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 36, // Ajustado a 50
                        child: CustomTextField(
                          label: 'Hora',
                          controller: hourController,
                          enabled: false,
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  horarioSeleccionadoObj != null
                      ? "Estudiantes de '${horarioSeleccionadoObj!['grado']?.toString() ?? 'N/A'}' / Asistencias del curso de '${horarioSeleccionadoObj!['curso']?.toString() ?? 'N/A'}'"
                      : "Seleccione un horario para ver detalles de asistencias",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: GestureDetector(
                          onTap: () {
                            if (gradeId != null) {
                              showStudentsByGradeDialog(context, gradeId!);
                            } else {
                              Notificaciones.showNotification(context, "Primero seleccione un horario", color: Colors.orange);
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: studentDisplayController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: "Seleccionar estudiante",
                                labelText: "Estudiante Asignado",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: saveAssistance, child: const Text("Guardar")),
                    IconButton(onPressed: clearTextFields, icon: const Icon(Icons.clear_all, color: Colors.deepOrange)),
                    ElevatedButton(onPressed: updateAssistance, child: const Text("Actualizar")),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Asistencias Registradas', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                    child: PaginatedDataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Estudiante')),
                        DataColumn(label: Text('Horario')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Fecha')),
                        DataColumn(label: Text('Hora')),
                        DataColumn(label: Text('Creado')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      source: _assistancesDataSource,
                      rowsPerPage: 10,
                      onPageChanged: (int page) {
                        print('Página cambiada a: $page');
                      },
                      availableRowsPerPage: const [5, 10, 15, 20, 50],
                      showCheckboxColumn: false,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssistancesDataSource extends DataTableSource {
  List<Map<String, dynamic>> assistancesList;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  _AssistancesDataSource({
    required this.assistancesList,
    required this.onEdit,
    required this.onDelete,
  });

  void updateData(List<Map<String, dynamic>> newData) {
    assistancesList = newData;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= assistancesList.length) {
      return null;
    }
    final assistance = assistancesList[index];
    final student = assistance['estudiante'];
    final alumno = student?['alumno'];
    final schedule = assistance['horario'];
    final course = schedule?['curso'];
    final courseName = (course is Map) ? (course['nombre'] ?? 'N/A') : (course?.toString() ?? 'N/A');
    final grade = schedule?['grado'];
    final gradeName = (grade is Map) ? (grade['nombre'] ?? 'N/A') : (grade?.toString() ?? 'N/A');

    return DataRow(
      cells: [
        DataCell(Text(assistance['id']?.toString() ?? 'N/A')),
        DataCell(Text('${student?['id'] ?? 'N/A'} - ${alumno?['nombre'] ?? 'N/A'} ${alumno?['apellido'] ?? ''}')),
        DataCell(Text('${schedule?['fecha'] ?? 'N/A'} - $courseName ($gradeName)')),
        DataCell(Text(assistance['estado']?.toString() ?? 'N/A')),
        DataCell(Text(assistance['fecha']?.toString() ?? 'N/A')),
        DataCell(Text(assistance['hora']?.toString() ?? 'N/A')),
        DataCell(Text(assistance['createdAt']?.toString() ?? 'N/A')),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(assistance),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(assistance['id']),
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => assistancesList.length;
  @override
  int get selectedRowCount => 0;
}