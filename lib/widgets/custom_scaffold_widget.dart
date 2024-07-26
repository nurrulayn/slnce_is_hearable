import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget{
  const CustomScaffold({super.key, this.child,});

  final Widget? child;


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme:  const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset("assets/images/IMG_9765.jpg",
            fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,),

          SafeArea(
            child: child!,
          ),
        ],
      ),
    );
  }
}