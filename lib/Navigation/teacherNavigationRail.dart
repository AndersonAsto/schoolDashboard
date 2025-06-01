import 'package:flutter/material.dart';
import 'package:schooldashboard/Screens/StudentScreens/assistancesScreen.dart';
import 'package:schooldashboard/Screens/StudentScreens/incidentsScreen.dart';
import 'package:schooldashboard/Screens/StudentScreens/qualificationsScreen.dart';

class TeacherNavigationRail extends StatefulWidget {
  const TeacherNavigationRail({super.key});

  @override
  State<TeacherNavigationRail> createState() => _TeacherNavigationRailState();
}

class _TeacherNavigationRailState extends State<TeacherNavigationRail> {

  int selectedIndex = 0;

  final List<Widget> pages = [
    AssistancesScreenClass(),
    QualificationsScreenClass(),
    IncidentsScreenClass()
  ];

  @override
  Widget build(BuildContext context){
    final isCollapsed = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      body: Row(
        children: [
          Container(
            color: Colors.black,
            child: NavigationRail(
              backgroundColor: Colors.black,
              extended: !isCollapsed,
              selectedIndex: selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              selectedIconTheme: IconThemeData(color: Colors.black),
              unselectedIconTheme: IconThemeData(color: Colors.white),
              selectedLabelTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              unselectedLabelTextStyle: TextStyle(color: Colors.white),
              indicatorColor: Colors.white,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined),
                  label: Text('Asistencias'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.check_box_outlined),
                  label: Text('Calificaciones'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.dangerous_outlined),
                  label: Text('Incidencias'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: pages[selectedIndex],
            ),
          )
        ],
      ),
    );
  }
}