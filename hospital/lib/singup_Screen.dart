import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hospital/Login_screen.dart';

class SingupScreen extends StatefulWidget {
  const SingupScreen({super.key});

  @override
  State<SingupScreen> createState() => _SingupScreenState();
}

class _SingupScreenState extends State<SingupScreen> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: Text("Sign Up"),
        backgroundColor: Colors.green,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: "Phobne Number",

                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.phone, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter phone number";
                    }

                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return "Enter a valid 10-digit phone number";
                    }

                    return null;
                  },
                  keyboardType: TextInputType
                      .phone, // Set the keyboard type to email.emailAddress(),),
                  maxLength: 10,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",

                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.email, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
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

                  keyboardType: TextInputType
                      .emailAddress, // Set the keyboard type to email.emailAddress(),),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter password";
                    }

                    if (value.length < 6) {
                      return "Password must be at least 8 characters";
                    }

                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return "Password needs an uppercase letter";
                    }

                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return "Password needs a number";
                    }

                    if (!RegExp(r'[!@#$%^&*]').hasMatch(value)) {
                      return "Password needs a special character";
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.lock, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // All validation successful
                      print("Signup successful");

                      print("Email: ${emailController.text}");
                      print("Phone: ${phoneController.text}");
                      print("Password: ${passwordController.text}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }
                    ;
                  },
                  child: Text("SingUp"),
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: "Already have an account? "),
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          },
                        text: "Login",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
