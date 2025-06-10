import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:schooldashboard/Screens/TeacherScreens/incidentsScreen.dart';
import 'package:schooldashboard/Screens/TeacherScreens/assistancesScreen.dart';
import 'package:schooldashboard/Screens/TeacherScreens/qualificationsScreen.dart';

class TeacherNavigationRail extends StatefulWidget {
  final int docenteId;
  final String userName;

  const TeacherNavigationRail({
    super.key,
    required this.docenteId,
    required this.userName
  });

  @override
  State<TeacherNavigationRail> createState() => _TeacherNavigationRailState();
}

class _TeacherNavigationRailState extends State<TeacherNavigationRail> {
  final SidebarXController _controller = SidebarXController(selectedIndex: 0, extended: true);

  @override
  Widget build(BuildContext context) {
    final pages = [
      AssistancesScreenClass(),
      QualificationsScreenClass(docenteId: widget.docenteId, userName: widget.userName),
      IncidentsScreenClass(),
    ];

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
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  hoverColor: Colors.white,
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
                    ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bienvenid@,',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                  SidebarXItem(
                    icon: Icons.assignment_outlined,
                    label: 'Asistencias',
                  ),
                  SidebarXItem(
                    icon: Icons.check_box_outlined,
                    label: 'Calificaciones',
                  ),
                  SidebarXItem(
                    icon: Icons.dangerous_outlined,
                    label: 'Incidencias',
                  ),
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