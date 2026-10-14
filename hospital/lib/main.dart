import 'package:flutter/material.dart';
import 'package:hospital/Login_screen.dart';
import 'package:hospital/services/api_client.dart';
import 'package:hospital/services/session.dart';
import 'package:hospital/splace_Screen.dart';

/// Lets code outside the widget tree (the API client) move to the login
/// screen when the session expires.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore a saved login before the first screen decides where to go
  await Session.load();

  ApiClient.onUnauthorized = () {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthNova',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        // Every screen uses Colors.blue; seeding the scheme with it keeps
        // dialogs, date pickers and progress indicators in the same colour.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
