import 'package:flutter/material.dart';
import 'package:schooldashboard/Navigation/adminNavigationRail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'schoolDashboard',
      debugShowCheckedModeBanner: false,
      home: AdminNavigationRail(),
    );
  }
}


