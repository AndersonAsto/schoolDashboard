import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return MaterialApp(
      title: 'schoolDashboard',
      debugShowCheckedModeBanner: false,
      home: AdminNavigationRail(),
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            fontSizeFactor: 0.9,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal),
          ),
            floatingLabelStyle: TextStyle(color: Colors.teal)
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
      ),
    );
  }
}


