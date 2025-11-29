import 'package:flutter/material.dart';

class MyGoalScreen extends StatelessWidget {
  const MyGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Моя цель")),
      body: const Center(child: Text("Экран цели")),
    );
  }
}
