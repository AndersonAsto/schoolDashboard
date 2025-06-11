import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:schooldashboard/Screens/AdminScreens/usersScreen.dart';
import 'package:schooldashboard/Screens/AdminScreens/gradesScreen.dart';
import 'package:schooldashboard/Screens/AdminScreens/personsScreen.dart';
import 'package:schooldashboard/Screens/AdminScreens/coursesScreen.dart';
import 'package:schooldashboard/Screens/AdminScreens/studentsScreen.dart';
import 'package:schooldashboard/Screens/AdminScreens/schedulesScreen.dart';

const sidebarCanvasColor = Color(0xff3b7861); // Color de fondo del sidebar
const sidebarAccentCanvasColor = Color(0xff256d7b); // Un color más claro para el gradiente del item seleccionado
const sidebarActionColor = Color(0xff204760); // Color para el borde del item seleccionado (sin opacidad aquí)
final sidebarDivider = Divider(color: Colors.white.withOpacity(0.3), height: 1); // Divisor sutil para sidebar

class AdminNavigationRail extends StatefulWidget {
  const AdminNavigationRail({super.key});

  @override
  State<AdminNavigationRail> createState() => _AdminNavigationRailState();
}

class _AdminNavigationRailState extends State<AdminNavigationRail> {
  final SidebarXController _controller = SidebarXController(selectedIndex: 0, extended: true);

  final List<Widget> pages = [
    GradesScreenClass(),
    CoursesScreenClass(),
    PersonsScreenClass(),
    UsersScreenClass(),
    StudentsScreenClass(),
    SchedulesScreenClass(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarX(
            controller: _controller,
            theme: SidebarXTheme(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: sidebarCanvasColor,
                borderRadius: BorderRadius.circular(20),
              ),
              hoverColor: Colors.white.withOpacity(0.1),
              hoverTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              hoverIconTheme: const IconThemeData(
                color: Colors.white,
                size: 20,
              ),
              textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              iconTheme: IconThemeData(
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white),
              selectedIconTheme: const IconThemeData(
                color: Colors.white,
                size: 20,
              ),
              selectedItemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sidebarActionColor.withOpacity(0.37),
                ),
                gradient: const LinearGradient(
                  colors: [sidebarAccentCanvasColor, sidebarCanvasColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 30,
                  )
                ],
              ),
              itemTextPadding: const EdgeInsets.only(left: 16),
              selectedItemTextPadding: const EdgeInsets.only(left: 16),
              itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sidebarCanvasColor),
              ),
              padding: const EdgeInsets.all(0),
            ),
            extendedTheme: const SidebarXTheme(
              width: 200,
              decoration: BoxDecoration(
                color: sidebarCanvasColor,
              ),
            ),
            headerDivider: sidebarDivider,
            footerDivider: sidebarDivider,
            headerBuilder: (context, extended) {
              return SizedBox(
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: extended
                      ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(child: Text(
                        'Bienvenid@,',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),),
                    ],
                  )
                      : const Icon(Icons.person, color: Colors.white, size: 32),
                ),
              );
            },
            items: const [
              SidebarXItem(icon: Icons.list, label: 'Grados'),
              SidebarXItem(icon: Icons.book, label: 'Cursos'),
              SidebarXItem(icon: Icons.group, label: 'Personas'),
              SidebarXItem(icon: Icons.supervised_user_circle_outlined, label: 'Usuarios'),
              SidebarXItem(icon: Icons.group_add, label: 'Estudiantes'),
              SidebarXItem(icon: Icons.table_chart, label: 'Horarios'),
            ],
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return pages[_controller.selectedIndex];
              },
            ),
          ),
        ],
      ),
    );
  }
}