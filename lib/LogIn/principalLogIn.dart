import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:schooldashboard/Global/global.dart';
import 'package:schooldashboard/Navigation/adminNavigationRail.dart';
import 'package:http/http.dart' as http;
import 'package:schooldashboard/Navigation/teacherNavigationRail.dart';
import 'package:schooldashboard/Utils/customNotifications.dart';
import 'package:schooldashboard/Utils/customTextFields.dart';

class PrincipalLogInScreen extends StatefulWidget {
  const PrincipalLogInScreen({super.key});

  @override
  State<PrincipalLogInScreen> createState() => _PrincipalLogInScreenState();
}

class _PrincipalLogInScreenState extends State<PrincipalLogInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final List<String> items = [
    'Administrador',
    'Docente',
    'Apoderado'
  ];

  String? selectedValue;

  Future<void> loginUsuario(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final rol = selectedValue;

    if (rol == null) {
      showMessage(context, 'Seleccione un rol');
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      showMessage(context, 'Ingrese el correo y la contraseña');
      return;
    }

    /*
    * final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email)) {
      showMessage(context, 'Correo no válido');
      return;
    }*/

    try {
      final response = await http.post(
        Uri.parse('${generalURL}api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email,
          'password': password,
          'rol': rol,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (rol == 'Administrador') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminNavigationRail()),
          );
          Notificaciones.showNotification(context, "Inicio de sesión exitoso", color: Colors.teal);
        } else if (rol == 'Docente'){
          final docenteId = data['user']['id'];
          final userName = data['user']['username'];
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TeacherNavigationRail(docenteId: docenteId, userName: userName)),
          );
          Notificaciones.showNotification(context, "Inicio de sesión exitoso", color: Colors.teal);
        } else {
          showMessage(context, 'Rol válido pero aún no implementado');
        }
      } else {
        final data = jsonDecode(response.body);
        showMessage(context, data['message'] ?? 'Error de autenticación');
      }
    } catch (e) {
      showMessage(context, 'Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context){
    double screenX = MediaQuery.of(context).size.width;
    double screenY = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/bg/bg002.webp', fit: BoxFit.cover,),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                height: screenY * 0.8,
                width: screenX * 0.8,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 10),
                      blurRadius: 50,
                      spreadRadius: 3,
                    ),
                  ],
                  color: const Color(0xf2e5eaf6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: screenX < 600
                    ? Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildLoginForm(),
                    ],
                  ),
                )
                    : Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildLoginForm(),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/card/card1.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ],
                ),

              ),
            ),
          ),
        ],
      )
    );
  }
  Widget buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: const Row(
                children: [
                  Icon(Icons.list, size: 16, color: Colors.white,),
                  SizedBox(width: 4,),
                  Expanded(
                    child: Text('Seleccionar Rol',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              items: items
                  .map((String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )).toList(),
              value: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              },
              buttonStyleData: ButtonStyleData(
                height: 50,
                width: 160,
                padding: const EdgeInsets.only(left: 14, right: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.black26,
                  ),
                  color: Colors.teal,
                ),
                elevation: 2,
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.arrow_forward_ios_outlined,
                ),
                iconSize: 14,
                iconEnabledColor: Colors.white,
                iconDisabledColor: Colors.grey,
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.teal,
                ),
                offset: const Offset(-20, 0),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(40),
                  thickness: MaterialStateProperty.all(6),
                  thumbVisibility: MaterialStateProperty.all(true),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 40,
                padding: EdgeInsets.only(left: 14, right: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(label: "Usuario", controller: emailController),
        const SizedBox(height: 20),
        CustomTextField(label: "Contraseña", controller: passwordController),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => loginUsuario(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
          ),
          child: const Text(
            "Iniciar Sesión",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: appColors[0],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}