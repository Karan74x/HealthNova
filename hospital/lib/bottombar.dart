import 'package:flutter/material.dart';
import 'package:hospital/AppointmentScreen.dart';
import 'package:hospital/DoctorListScreen.dart';
import 'package:hospital/Home_screen.dart';
import 'package:hospital/ProfileScreen.dart';
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

  @override
  Widget build(BuildContext context) {
    // Built on each switch, so a tab shows fresh data when it is opened
    // (for example a new booking on the Appointments tab).
    final List<Widget> screen = [
      HomeScreen(onOpenTab: indexChange),
      const DoctorListScreen(),
      const AppointmentScreen(),
      const ReportsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screen[currentI],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentI,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue[200],
        selectedIconTheme: const IconThemeData(color: Colors.blue),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,

        onTap: indexChange,
        iconSize: 25,

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',

            activeIcon: Icon(Icons.home_filled),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            label: 'Report',

            activeIcon: Icon(Icons.monitor_heart),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
