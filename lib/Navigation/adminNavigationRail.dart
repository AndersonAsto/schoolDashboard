import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:schooldashboard/Screens/AdminScreens/usersScreen.dart';
import 'package:schooldashboard/Screens/AdminScreens/gradesScreen.dart';
import 'package:schooldashboard/Screens/AdminScreens/personsScreen.dart';
import 'package:schooldashboard/Screens/AdminScreens/coursesScreen.dart';
import 'package:schooldashboard/Screens/AdminScreens/studentsScreen.dart';
import 'package:schooldashboard/Screens/AdminScreens/schedulesScreen.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCollapsed = constraints.maxWidth < 700;
        _controller.setExtended(!isCollapsed);

        return Scaffold(
          body: Row(
            children: [
              SidebarX(
                controller: _controller,
                theme: SidebarXTheme(
                  margin: const EdgeInsets.all(0),
                  decoration: const BoxDecoration(color: Colors.black),
                  hoverColor: Colors.grey[800],
                  textStyle: const TextStyle(color: Colors.white),
                  selectedTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedItemDecoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                  selectedIconTheme: const IconThemeData(color: Colors.black),
                ),
                extendedTheme: SidebarXTheme(
                  width: 250,
                  decoration: const BoxDecoration(color: Colors.black),
                ),
                headerBuilder: (context, extended) => extended
                    ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenid@,',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(height: 5,),
                      Divider(color: Colors.white, height: 3,)
                    ],
                  ),
                )
                    : const Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
                items: const [
                  SidebarXItem(icon: Icons.home, label: 'Grados'),
                  SidebarXItem(icon: Icons.people, label: 'Cursos'),
                  SidebarXItem(icon: Icons.settings, label: 'Personas'),
                  SidebarXItem(icon: Icons.work, label: 'Usuarios'),
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
      },
    );
  }
}