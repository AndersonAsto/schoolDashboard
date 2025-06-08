import 'package:flutter/material.dart';

class AssistancesScreenClass extends StatefulWidget{
  const AssistancesScreenClass({super.key});

  @override
  State<AssistancesScreenClass> createState() => _AssistancesScreenClassState();
}

class _AssistancesScreenClassState extends State<AssistancesScreenClass> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Asistencias", style: TextStyle(color: Colors.white),),backgroundColor: Colors.black, automaticallyImplyLeading: false,),
    );
  }
}