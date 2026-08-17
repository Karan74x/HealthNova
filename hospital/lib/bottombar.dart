import 'package:flutter/material.dart';
import 'package:hospital/DoctorListScreen.dart';
import 'package:hospital/Home_screen.dart';
import 'package:hospital/ReportsScreen.dart';

class bottom_screen extends StatefulWidget {
  bottom_screen({super.key});

  @override
  State<bottom_screen> createState() => _bottom_screenState();
}

class _bottom_screenState extends State<bottom_screen> {
  int currentI = 0;

  void indexChange(int index) {
    setState(() {
      currentI = index;
    });
  }

  List screen = [HomeScreen(), DoctorListScreen(), ReportsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen[currentI],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentI,
        backgroundColor: Colors.blue[200],
        selectedIconTheme: IconThemeData(color: Colors.blue),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,

        onTap: indexChange,
        iconSize: 25,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',

            activeIcon: Icon(Icons.home_filled),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            activeIcon: Icon(Icons.group_outlined),
            label: 'doctor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Report',

            activeIcon: Icon(Icons.report_outlined),
          ),
        ],
      ),
    );
  }
}
