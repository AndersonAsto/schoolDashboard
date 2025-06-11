import 'package:flutter/material.dart';
import 'package:schooldashboard/Global/global.dart';

class IncidentsScreenClass extends StatefulWidget{
  final int docenteId;
  final String userName;

  const IncidentsScreenClass({
    super.key,
    required this.docenteId,
    required this.userName
  });

  @override
  State<IncidentsScreenClass> createState() => _IncidentsScreenClassState();
}

class _IncidentsScreenClassState extends State<IncidentsScreenClass> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Incidencias", style: TextStyle(color: Colors.white),),backgroundColor: appColors[3], automaticallyImplyLeading: false,),
    );
  }
}