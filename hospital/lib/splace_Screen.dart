import 'package:flutter/material.dart';
import 'package:hospital/bottombar.dart';
import 'package:hospital/services/session.dart';
import 'package:hospital/singup_Screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      // A patient who signed in before goes straight to the app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              Session.isLoggedIn ? bottom_screen() : const SingupScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              "Health Nova",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
