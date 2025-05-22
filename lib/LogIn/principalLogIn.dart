import 'package:flutter/material.dart';

class PrincipalLogInScreen extends StatefulWidget {
  @override
  State<PrincipalLogInScreen> createState() => _PrincipalLogInScreenState();
}

class _PrincipalLogInScreenState extends State<PrincipalLogInScreen> {
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context){
    double screenX = MediaQuery.of(context).size.width;
    double screenY = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            height: screenY * 0.5,
            width: screenX * 0.5,
            child: Column(),
          ),
        ),
      ),
    );
  }
}