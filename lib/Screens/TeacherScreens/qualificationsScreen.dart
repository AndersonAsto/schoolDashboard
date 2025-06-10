import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:schooldashboard/Global/global.dart';
import 'package:schooldashboard/Utils/customTextFields.dart';
import 'package:schooldashboard/Utils/customNotifications.dart';

class QualificationsScreenClass extends StatefulWidget {
  final int docenteId;
  final String userName;

  const QualificationsScreenClass({
    super.key,
    required this.docenteId,
    required this.userName
  });

  @override
  State<QualificationsScreenClass> createState() => _QualificationsScreenClassState();
}

class _QualificationsScreenClassState extends State<QualificationsScreenClass> {
  TextEditingController idController = TextEditingController();
  TextEditingController studentIdController = TextEditingController();
  TextEditingController scheduleIdController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController createdAtController = TextEditingController();
  TextEditingController updatedAtController = TextEditingController();
  TextEditingController studentDisplayController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController hourController = TextEditingController();
  TextEditingController scheduleDisplayController = TextEditingController();

  int? gradeId;
  int? idToEdit;
  List<String> dias = [];
  String? diaSeleccionado;
  List<dynamic> horarios = [];
  String? horarioSeleccionado;
  Map<String, dynamic>? horarioSeleccionadoObj; // Objeto completo del horario seleccionado
  List<Map<String, dynamic>> qualificationsList = [];
  late _QualificationsDataSource _qualificationsDataSource;

  Future<void> saveQualification() async {
    if (
    studentIdController.text.isEmpty ||
        scheduleIdController.text.isEmpty ||
        noteController.text.isEmpty ||
        detailController.text.isEmpty ||
        dateController.text.isEmpty ||
        hourController.text.isEmpty
    ) {
      Notificaciones.showNotification(context, "Por favor completa todos los campos obligatorios", color: Colors.red);
      return;
    }

    if (idToEdit != null) {
      Notificaciones.showNotification(context, "Estás editando un registro. Cancela la edición para guardar uno nuevo.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/qualification/register');
    final Map<String, dynamic> payload = {
      'alumno_id': int.parse(studentIdController.text),
      'horario_id': int.parse(scheduleIdController.text),
      'nota': double.parse(noteController.text),
      'detalle': detailController.text,
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
        Notificaciones.showNotification(context, "Calificación registrada correctamente", color: Colors.teal);
        clearTextFields();
        // Después de guardar, refresca la lista con los filtros actuales (si los hay)
        if (diaSeleccionado != null && horarioSeleccionadoObj != null) {
          await getQualifications(day: diaSeleccionado, horarioId: horarioSeleccionadoObj!['id']);
        } else {
          await getQualifications(); // Si no hay filtros específicos, carga todas para el docente actual
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

  // Obtiene las calificaciones, con filtros opcionales de día y horario
  Future<void> getQualifications({String? day, int? horarioId}) async {
    try {
      String url = '${generalURL}api/qualification/filter'; // URL de la API de filtro
      Map<String, String> queryParams = {};

      // Siempre incluir el ID del docente actual
      queryParams['docente_id'] = widget.docenteId.toString();

      if (day != null && day.isNotEmpty) {
        queryParams['fecha_horario'] = day;
      }
      if (horarioId != null) {
        queryParams['horario_id'] = horarioId.toString();
      }

      // Construye la URL con parámetros de consulta
      if (queryParams.isNotEmpty) {
        url = Uri.parse('$url?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}').toString();
      }
      // print("Obteniendo calificaciones de la URL: $url"); // Para depuración

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          qualificationsList = List<Map<String, dynamic>>.from(data);
          _qualificationsDataSource.updateData(qualificationsList); // Actualiza el origen de datos de la tabla
        });
      } else {
        Notificaciones.showNotification(context, "Error al obtener calificaciones: ${response.body}", color: Colors.red);
        print("Error al obtener calificaciones: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión al obtener calificaciones: $e", color: Colors.red);
      print("Error de conexión al obtener calificaciones: $e");
    }
  }

  // Actualiza una calificación existente
  Future<void> updateQualification() async {
    if (idToEdit == null) {
      Notificaciones.showNotification(context, "Selecciona una calificación para actualizar", color: Colors.red);
      return;
    }
    if (
    noteController.text.isEmpty ||
        detailController.text.isEmpty ||
        dateController.text.isEmpty ||
        hourController.text.isEmpty
    ) {
      Notificaciones.showNotification(context, "Los campos de Nota, Detalle, Fecha y Hora no pueden estar vacíos.", color: Colors.red);
      return;
    }

    final url = Uri.parse('${generalURL}api/qualification/update/$idToEdit');
    final Map<String, dynamic> payload = {
      'nota': double.parse(noteController.text),
      'detalle': detailController.text,
      'fecha': dateController.text,
      'hora': hourController.text,
    };

    print("Actualizando URL: $url con payload: $payload");

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        Notificaciones.showNotification(context, "Calificación actualizada correctamente", color: Colors.teal);
        clearTextFields();
        idToEdit = null;
        if (diaSeleccionado != null && horarioSeleccionadoObj != null) {
          await getQualifications(day: diaSeleccionado, horarioId: horarioSeleccionadoObj!['id']);
        } else {
          await getQualifications(); // Retorno a todas las calificaciones para el docente actual si no hay filtros específicos
        }
      } else {
        Notificaciones.showNotification(context, "Error al actualizar calificación: ${response.body}", color: Colors.red);
        print("Error al actualizar calificación: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión al actualizar: $e", color: Colors.red);
      print("Error de conexión al actualizar: $e");
    }
  }

  Future<void> deleteQualification(int id) async {
    final url = Uri.parse('${generalURL}api/qualification/list/$id');
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        Notificaciones.showNotification(context, "Calificación eliminada correctamente", color: Colors.teal);
        // Después de eliminar, refresca con los filtros actuales (si los hay)
        if (diaSeleccionado != null && horarioSeleccionadoObj != null) {
          await getQualifications(day: diaSeleccionado, horarioId: horarioSeleccionadoObj!['id']);
        } else {
          await getQualifications(); // Retorno a todas las calificaciones para el docente actual si no hay filtros específicos
        }
      } else {
        Notificaciones.showNotification(context, "Error al eliminar calificación: ${response.body}", color: Colors.red);
        print("Error al eliminar calificación: ${response.body}");
      }
    } catch (e) {
      Notificaciones.showNotification(context, "Error de conexión al eliminar: $e", color: Colors.red);
      print("Error de conexión al eliminar: $e");
    }
  }

  // Limpia todos los campos del formulario y restablece los filtros de la tabla
  void clearTextFields() {
    idController.clear();
    studentIdController.clear();
    scheduleIdController.clear();
    noteController.clear();
    detailController.clear();
    studentDisplayController.clear();
    dateController.clear();
    hourController.clear();
    statusController.clear();
    createdAtController.clear();
    updatedAtController.clear();
    scheduleDisplayController.clear(); // Limpia la visualización del horario también
    setState(() { // Envuelve las asignaciones de variables de estado en setState
      // Las variables de estado de los Dropdowns NO se limpian aquí para mantener el filtro
      idToEdit = null; // Asegura que no estemos en modo edición al limpiar campos
      // diaSeleccionado = null;
      // horarioSeleccionado = null;
      // horarioSeleccionadoObj = null;
      // gradeId = null;
    });
    // La recarga de calificaciones se manejará por las funciones de guardar/actualizar/eliminar
    // para mantener el filtro actual. Si solo se llama clearTextFields directamente (ej: botón),
    // la tabla mantendrá el último filtro aplicado.
    // Después de limpiar, recarga las calificaciones sin filtros de día/horario
    // getQualifications(); // Carga todas las calificaciones para el docente actual
  }

  // Maneja la edición de una calificación desde la tabla
  void _handleEditQualification(Map<String, dynamic> qualification) {
    setState(() {
      idToEdit = qualification['id'];
      idController.text = qualification['id'].toString();
      // Rellena campos del estudiante. studentIdController debe contener el ID de la tabla 'alumnos'.
      studentIdController.text = qualification['estudiante']['id'].toString();
      // studentDisplayController muestra el ID de persona y nombre para claridad del usuario.
      studentDisplayController.text = '${qualification['estudiante']['id']} - ${qualification['estudiante']['alumno']['nombre']} ${qualification['estudiante']['alumno']['apellido']}';

      final Map<String, dynamic> originalHorario = qualification['horario'];
      final String selectedDay = originalHorario['fecha']?.toString() ?? '';
      diaSeleccionado = selectedDay; // Establece el valor del dropdown del día

      // Limpia selecciones de horario inicialmente, se establecerán después de la obtención
      horarioSeleccionado = null;
      horarioSeleccionadoObj = null;
      gradeId = null;

      scheduleIdController.text = originalHorario['id'].toString(); // Aún establece el ID para el envío del formulario
      // Nota: scheduleDisplayController se actualizará cuando se encuentre el horario más tarde.

      // Rellena otros campos de la calificación
      noteController.text = qualification['nota'].toString();
      detailController.text = qualification['detalle'] ?? '';
      dateController.text = qualification['fecha'];
      hourController.text = qualification['hora'];
      statusController.text = qualification['estado'].toString();
      createdAtController.text = qualification['createdAt'].toString();
      updatedAtController.text = qualification['updatedAt'].toString();
    });

    // Programa una devolución de llamada post-frame para obtener horarios del día seleccionado
    // y luego actualizar horarioSeleccionadoObj y controladores relacionados.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (diaSeleccionado != null) {
        await obtenerHorariosPorDia(diaSeleccionado!); // Esto llena la lista `horarios`

        setState(() {
          // Ahora, encuentra el horario específico de la lista `horarios` *recién cargada*
          // basado en su ID (que es confiable).
          final int? targetScheduleId = int.tryParse(scheduleIdController.text);
          if (targetScheduleId != null) {
            horarioSeleccionadoObj = horarios.firstWhere(
                  (h) => h['id'] == targetScheduleId,
              orElse: () => null,
            );

            if (horarioSeleccionadoObj != null) {
              // Reconstruye la cadena de visualización del objeto encontrado,
              // asegurándose de que coincida con el formato de los DropdownMenuItems
              final String hCurso = horarioSeleccionadoObj!['curso']?.toString() ?? 'N/A';
              final String hGrado = horarioSeleccionadoObj!['grado']?.toString() ?? 'N/A';
              final String hHoraInicio = horarioSeleccionadoObj!['hora_inicio']?.substring(0,5) ?? 'N/A';
              final String hHoraFin = horarioSeleccionadoObj!['hora_fin']?.substring(0,5) ?? 'N/A';
              horarioSeleccionado = "$hCurso ($hHoraInicio - $hHoraFin) ($hGrado)";

              gradeId = int.tryParse(horarioSeleccionadoObj!['grado_id']?.toString() ?? '');
              scheduleDisplayController.text = horarioSeleccionado!;
            } else {
              // Si el horario no se encontró en la lista del día actual,
              // significa inconsistencia de datos o que el horario se movió.
              horarioSeleccionado = null;
              gradeId = null;
              scheduleDisplayController.clear();
              Notificaciones.showNotification(context, "Horario asociado a la calificación no encontrado para el día seleccionado.", color: Colors.orange);
            }
          } else {
            // Si targetScheduleId es nulo, significa que scheduleIdController.text no era válido
            horarioSeleccionado = null;
            gradeId = null;
            scheduleDisplayController.clear();
            Notificaciones.showNotification(context, "ID de horario no válido para la calificación.", color: Colors.orange);
          }
        });
        // Después de actualizar los dropdowns de horario, filtra la tabla de calificaciones.
        if (diaSeleccionado != null && horarioSeleccionadoObj != null) {
          getQualifications(day: diaSeleccionado, horarioId: horarioSeleccionadoObj!['id']);
        } else {
          getQualifications(); // Retorno a todas las calificaciones para el docente actual
        }
      }
    });
  }

  Future<void> obtenerDiasConClases() async {
    try {
      final response = await http.get(Uri.parse('${generalURL}api/schedule/days/${widget.docenteId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          dias = List<String>.from(data['dias']);
          if (dias.isNotEmpty) {
            diaSeleccionado = dias[0]; // Selecciona automáticamente el primer día
            obtenerHorariosPorDia(diaSeleccionado!); // Carga horarios para el primer día
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

  Future<void> obtenerHorariosPorDia(String dia) async {
    try {
      final response = await http.get(Uri.parse('${generalURL}api/schedule/${widget.docenteId}/for-day?dia=$dia'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          horarios = data['horarios'] ?? [];
          if (horarios.isNotEmpty) {
            // Accede a las propiedades directamente como strings según la respuesta de la API /for-day
            final cursoNombre = horarios[0]['curso']?.toString() ?? 'N/A';
            final horaInicio = horarios[0]['hora_inicio']?.substring(0,5) ?? 'N/A';
            final horaFin = horarios[0]['hora_fin']?.substring(0,5) ?? 'N/A';
            final gradoNombre = horarios[0]['grado']?.toString() ?? 'N/A';

            horarioSeleccionado = "$cursoNombre ($horaInicio - $horaFin) ($gradoNombre)"; // Establece la selección predeterminada para nueva entrada
            horarioSeleccionadoObj = horarios[0]; // Establece el primer objeto como predeterminado
            scheduleIdController.text = horarioSeleccionadoObj?['id'].toString() ?? '';
            scheduleDisplayController.text = horarioSeleccionado ?? '';
            gradeId = int.tryParse(horarioSeleccionadoObj?['grado_id']?.toString() ?? ''); // Accede a grado_id directamente
          } else {
            horarioSeleccionado = null;
            horarioSeleccionadoObj = null;
            scheduleIdController.clear();
            scheduleDisplayController.clear();
            gradeId = null;
          }
        });
        // Después de cargar los horarios, filtra la tabla de calificaciones
        if (horarioSeleccionadoObj != null) {
          getQualifications(day: dia, horarioId: horarioSeleccionadoObj!['id']);
        } else {
          getQualifications(day: dia); // Si no hay horario específico, muestra todos para el día seleccionado
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
        getQualifications(day: dia); // Si falla la carga de horarios, filtra solo por día (si es posible)
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
      getQualifications(day: dia);
    }
  }

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

  void showDetailSelection(BuildContext context) {
    final details = [
      'Actividad Diaria',
      'Revisión de Tarea',
      'Exposición',
      'Examen',
      'Promedio Bimestre 1',
      'Promedio Bimestre 2',
      'Promedio Bimestre 3',
      'Promedio Bimestre 4',
      'Promedio General'
    ];

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Seleccionar Detalle'),
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
                      detailController.text = detail;
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
    final second = DateTime.now().second.toString().padLeft(2, '0');
    return "$hour:$minute:$second";
  }

  @override
  void initState() {
    super.initState();
    _qualificationsDataSource = _QualificationsDataSource(
      qualificationsList: qualificationsList,
      onEdit: _handleEditQualification,
      onDelete: deleteQualification,
    );
    obtenerDiasConClases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Calificaciones", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
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
                            // También actualiza la tabla de calificaciones para mostrar todos los del día seleccionado
                            getQualifications(day: nuevoDia);
                          } else {
                            getQualifications(); // Si no hay día seleccionado, muestra todas para el docente actual
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
                          // Después de seleccionar un horario, filtra la tabla de calificaciones por él
                          if (diaSeleccionado != null && horarioSeleccionadoObj != null) {
                            getQualifications(day: diaSeleccionado, horarioId: horarioSeleccionadoObj!['id']);
                          } else if (diaSeleccionado != null) {
                            getQualifications(day: diaSeleccionado); // Retorno a filtrar solo por día
                          } else {
                            getQualifications(); // Sin filtros
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CommonInfoFields(idController: idController, statusController: statusController),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: "Código de Estudiante", controller: studentIdController, enabled: false)),
                    const SizedBox(width: 10),
                    Expanded(child: CustomTextField(label: "Código de Horario", controller: scheduleIdController, enabled: false)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: "Nota (0-20)",
                        controller: noteController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                          LengthLimitingTextInputFormatter(5),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: GestureDetector(
                          onTap: () => showDetailSelection(context),
                          child: AbsorbPointer(
                            child: TextField(
                              controller: detailController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: "Seleccionar Detalle",
                                labelText: "Detalle",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
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
                      child: SizedBox(
                        height: 36,
                        child: GestureDetector(
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: dateController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Fecha',
                                hintText: 'Seleccionar Fecha',
                                suffixIcon: const Icon(Icons.calendar_today),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: GestureDetector(
                          onTap: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              hourController.text = _formatTime(pickedTime);
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: hourController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Hora',
                                hintText: 'Seleccionar Hora',
                                suffixIcon: const Icon(Icons.access_time),
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
                const SizedBox(height: 10),
                CommonTimestampsFields(createdAtController: createdAtController, updatedAtController: updatedAtController),
                const SizedBox(height: 20),
                Text(
                  horarioSeleccionadoObj != null
                      ? "Estudiantes de '${horarioSeleccionadoObj!['grado']?.toString() ?? 'N/A'}' / Notas del curso de '${horarioSeleccionadoObj!['curso']?.toString() ?? 'N/A'}'"
                      : "Seleccione un horario para ver detalles",
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
                    ElevatedButton(onPressed: saveQualification, child: const Text("Guardar")),
                    IconButton(onPressed: clearTextFields, icon: const Icon(Icons.clear_all, color: Colors.deepOrange)),
                    ElevatedButton(onPressed: updateQualification, child: const Text("Actualizar")),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Calificaciones Registradas', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                    child: PaginatedDataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Estudiante')),
                        DataColumn(label: Text('Horario')),
                        DataColumn(label: Text('Nota')),
                        DataColumn(label: Text('Detalle')),
                        DataColumn(label: Text('Fecha')),
                        DataColumn(label: Text('Hora')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Creado')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      source: _qualificationsDataSource,
                      rowsPerPage: 15,
                      onPageChanged: (int page) {
                        print('Página cambiada a: $page');
                      },
                      availableRowsPerPage: const [5, 10, 15, 20, 50],
                      showCheckboxColumn: false,
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

// Origen de datos personalizado para PaginatedDataTable para Calificaciones
class _QualificationsDataSource extends DataTableSource {
  List<Map<String, dynamic>> qualificationsList; // No final para permitir actualizaciones
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  _QualificationsDataSource({
    required this.qualificationsList,
    required this.onEdit,
    required this.onDelete,
  });

  // Método para actualizar datos y notificator a los oyentes
  void updateData(List<Map<String, dynamic>> newData) {
    qualificationsList = newData;
    notifyListeners(); // Notifica a PaginatedDataTable que los datos han cambiado
  }

  @override
  DataRow? getRow(int index) {
    if (index >= qualificationsList.length) {
      return null;
    }
    final qualification = qualificationsList[index];
    final student = qualification['estudiante'];
    final alumno = student?['alumno'];
    final schedule = qualification['horario'];
    // Accede a propiedades anidadas de forma segura, comprobando si son Map primero
    final course = schedule?['curso'];
    final courseName = (course is Map) ? (course['nombre'] ?? 'N/A') : (course?.toString() ?? 'N/A');

    final grade = schedule?['grado']; // Obtiene el grado del horario
    final gradeName = (grade is Map) ? (grade['nombre'] ?? 'N/A') : (grade?.toString() ?? 'N/A');

    return DataRow(
      cells: [
        DataCell(Text(qualification['id'].toString())),
        DataCell(Text('${alumno?['nombre'] ?? 'N/A'} ${alumno?['apellido'] ?? ''}')),
        DataCell(Text('${schedule?['fecha'] ?? 'N/A'} - $courseName ($gradeName)')),
        DataCell(Text(double.tryParse(qualification['nota'].toString())?.toStringAsFixed(2) ?? 'N/A')), // Arreglo: Parsea de forma segura a double antes de formatear
        DataCell(Text(qualification['detalle'] ?? 'N/A')),
        DataCell(Text(qualification['fecha'] ?? 'N/A')),
        DataCell(Text(qualification['hora']?.substring(0, 5) ?? 'N/A')), // Muestra HH:mm
        DataCell(Text(qualification['estado'] == true ? 'Activo' : 'Inactivo')),
        DataCell(Text(qualification['createdAt']?.toString().substring(0, 10) ?? 'N/A')), // Muestra solo la fecha
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(qualification),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(qualification['id']),
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => qualificationsList.length;
  @override
  int get selectedRowCount => 0;
}
