import 'package:flutter/material.dart';
import 'package:schooldashboard/Screens/coursesScreen.dart';
import 'package:schooldashboard/Screens/gradesScreen.dart';
import 'package:schooldashboard/Screens/personsScreen.dart';
import 'package:schooldashboard/Screens/schedulesScreen.dart';
import 'package:schooldashboard/Screens/studentsScreen.dart';
import 'package:schooldashboard/Screens/usersScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    GradesScreenClass(),
    CoursesScreenClass(),
    PersonsScreenClass(),
    UsersScreenClass(),
    StudentsScreenClass(),
    SchedulesScreenClass()
  ];

  @override
  Widget build(BuildContext context) {
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
                  icon: Icon(Icons.home),
                  label: Text('Grados'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Cursos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Personas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.work),
                  label: Text('Usuarios'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.group_add),
                  label: Text('Estudiantes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.table_chart),
                  label: Text('Horarios'),
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