import 'package:flutter/material.dart';

class QualificationsScreenClass extends StatefulWidget{
  const QualificationsScreenClass({super.key});

  @override
  State<QualificationsScreenClass> createState() => _QualificationsScreenClassState();
}

class _QualificationsScreenClassState extends State<QualificationsScreenClass> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Calificaciones", style: TextStyle(color: Colors.white),),backgroundColor: Colors.black, automaticallyImplyLeading: false,),
    );
  }
}