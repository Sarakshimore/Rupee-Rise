import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Add this import
import '../services/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signUp() async {
    User? user = await _authService.signUpWithEmail(emailController.text, passwordController.text);
    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: signUp, child: Text("Sign Up")),
            TextButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            }, child: Text("Already have an account? Login")),
          ],
        ),
      ),
    );
  }
}
