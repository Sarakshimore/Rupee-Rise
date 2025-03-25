import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Add this import
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    User? user = await _authService.loginWithEmail(emailController.text, passwordController.text);
    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed")));
    }
  }

  void loginWithGoogle() async {
    User? user = await _authService.signInWithGoogle();
    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text("Login")),
            ElevatedButton(onPressed: loginWithGoogle, child: Text("Login with Google")),
            TextButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
            }, child: Text("Don't have an account? Sign Up")),
          ],
        ),
      ),
    );
  }
}
