import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart'; // Add this import

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatScreen()),
                );
              },
              child: const Text("Start Chatting"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen()),
                );
              },
              child: const Text("Edit Profile"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}