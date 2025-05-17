import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schooldashboard/Utils/allNotifications.dart';

class GradesScreenClass extends StatefulWidget {
  const GradesScreenClass({super.key});

  @override
  State<GradesScreenClass> createState() => _GradesScreenClassState();
}

class _GradesScreenClassState extends State<GradesScreenClass> {
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController createdAtController = TextEditingController();
  TextEditingController updatedAtController = TextEditingController();

  Map<String, dynamic>? gradoGuardado;

  Future<void> guardarGrado() async {
    if (nameController.text.trim().isEmpty) {
      Notificaciones.mostrarMensaje(context, "El nombre del grado no puede estar vacío.", color: Colors.red);
      return;
    }

    if (idEditando != null) {
      Notificaciones.mostrarMensaje(context, "Estás editando un grado. Cancela la edición para guardar uno nuevo.", color: Colors.red);
      return;
    }

    final url = Uri.parse('http://localhost:3000/api/grades/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nombre": nameController.text}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      setState(() {
        gradoGuardado = data;
        idController.text = data['id'].toString();
        stateController.text = data['estado'].toString();
        createdAtController.text = data['createdAt'].toString();
        updatedAtController.text = data['updatedAt'].toString();
      });
      idController.clear();
      nameController.clear();
      stateController.clear();
      createdAtController.clear();
      updatedAtController.clear();
      idEditando = null;
      obtenerGrados();
      Notificaciones.mostrarMensaje(context, "Grado guardado correctamente", color: Colors.green);
    } else {
      print("Error al guardar grado: ${response.body}");
    }
  }

  List<Map<String, dynamic>> grados = [];

  Future<void> obtenerGrados() async {
    final url = Uri.parse('http://localhost:3000/api/grades/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        grados = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print("Error al obtener grados: ${response.body}");
    }
  }

  Future<void> eliminarGrado(int id) async {
    final url = Uri.parse('http://localhost:3000/api/grades/delete/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print("Grado eliminado: $id");
      obtenerGrados();
    } else {
      print("Error al eliminar grado: ${response.body}");
    }
  }

  int? idEditando;
  
  Future<void> updateGrado () async {
    if (idEditando == null) {
      Notificaciones.mostrarMensaje(context, "Selecciona un grado para actualizar", color: Colors.red);
      return;
    }
    final url = Uri.parse('http://localhost:3000/api/grades/update/$idEditando');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nombre": nameController.text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        idController.clear();
        nameController.clear();
        stateController.clear();
        createdAtController.clear();
        updatedAtController.clear();
        idEditando = null;
      });
      obtenerGrados();
    } else {
      print("Error al actualizar grado: ${response.body}");
    }
  }

  Future<void> cancelUpdate () async{
    if (idEditando != null) {
      setState(() {
        idController.clear();
        nameController.clear();
        stateController.clear();
        createdAtController.clear();
        updatedAtController.clear();
        idEditando = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerGrados();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Grados", style: TextStyle(color: Colors.white),),backgroundColor: Colors.black,),
      body: SelectableRegion(
        focusNode: FocusNode(),
        selectionControls: materialTextSelectionControls,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(hintText: "Código"),
                        controller: idController,
                        enabled: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(hintText: "Estado"),
                        controller: stateController,
                        enabled: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(hintText: "Grado"),
                        controller: nameController,
                        enabled: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(hintText: "Creado el..."),
                        controller: createdAtController,
                        enabled: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: TextField(
                          decoration: const InputDecoration(hintText: "Actualizado el..."),
                          controller: updatedAtController,
                          enabled: false,
                        ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: guardarGrado, child: const Text("Guardar")),
                    IconButton(onPressed: cancelUpdate, icon: const Icon(Icons.edit_off)),
                    ElevatedButton(onPressed: updateGrado, child: const Text("Actualizar")),
                  ],
                ),
                const SizedBox(height: 30),
                // Lista de grados
                const Text("Grados registrados:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: grados.length,
                  itemBuilder: (context, index) {
                    final g = grados[index];
                    return ListTile(
                      title: Text("ID: ${g['id']} - ${g['nombre']}"),
                      subtitle: Text("Estado: ${g['estado'] == true ? 'Activo' : 'Inactivo'} | Creado: ${g['createdAt']}"),
                      trailing: SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  idEditando = g['id'];
                                  idController.text = g['id'].toString();
                                  nameController.text = g['nombre'];
                                  stateController.text = g['estado'].toString();
                                  createdAtController.text = g['createdAt'].toString();
                                  updatedAtController.text = g['updatedAt'].toString();
                                });
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => eliminarGrado(g['id']),
                              icon: const Icon(Icons.delete),
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
        ),
      ),
    );
  }
}
