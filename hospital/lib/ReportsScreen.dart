import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.blue,
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
      ),

      body: Center(child: Text('Reports Screen')),
    );
  }
}
