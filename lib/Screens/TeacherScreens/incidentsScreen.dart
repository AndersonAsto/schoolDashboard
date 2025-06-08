import 'package:flutter/material.dart';

class IncidentsScreenClass extends StatefulWidget{
  const IncidentsScreenClass({super.key});

  @override
  State<IncidentsScreenClass> createState() => _IncidentsScreenClassState();
}

class _IncidentsScreenClassState extends State<IncidentsScreenClass> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Incidencias", style: TextStyle(color: Colors.white),),backgroundColor: Colors.black, automaticallyImplyLeading: false,),
    );
  }
}