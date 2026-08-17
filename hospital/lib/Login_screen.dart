import 'package:flutter/material.dart';
import 'package:hospital/Home_screen.dart';
import 'package:hospital/bottombar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight(500),
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Login",
                style: TextStyle(fontSize: 28, color: Colors.white),
              ),
              TextFormField(
                controller: emailcontroller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter email";
                  }

                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return "Enter a valid email";
                  }

                  return null;
                },

                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Colors.white),
                  prefixIcon: const Icon(Icons.email, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Colors.purple),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 20),

              TextFormField(
                controller: passwordcontroller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter password";
                  }

                  if (value.length < 8) {
                    return "Password must be at least 8 characters";
                  }

                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return "Password must contain an uppercase letter";
                  }

                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return "Password must contain a number";
                  }

                  if (!RegExp(r'[!@#$%^&*]').hasMatch(value)) {
                    return "Password must contain a special character";
                  }

                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.white),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Colors.purple),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button background color
                  foregroundColor: Colors.white, // Text/Icon color
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    print("Login successful");

                    print("Email: ${emailcontroller.text}");
                    print("Password: ${passwordcontroller.text}");

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => bottom_screen()),
                    );
                  }
                },
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
