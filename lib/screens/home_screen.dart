import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Added import for GoogleFonts
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.white, // White app bar
        elevation: 0, // No shadow
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF4CAF50)), // Green hamburger icon
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Finance AI",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4CAF50), // Green
          ),
        ),
        centerTitle: true, // Center the title
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50), // Green header
              ),
              child: Text(
                "Menu",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
              title: Text(
                "Edit Profile",
                style: GoogleFonts.poppins(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF4CAF50)),
              title: Text(
                "Logout",
                style: GoogleFonts.poppins(color: Colors.black),
              ),
              onTap: () async {
                await _authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Your personal AI-powered financial assistant to manage money smarter.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          const Spacer(), // Pushes chat icon to center vertically
          Center(
            child: IconButton(
              icon: const Icon(
                Icons.chat_bubble_outline,
                size: 50,
                color: Color(0xFF4CAF50), // Green chat icon
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
            ),
          ),
          const Spacer(), // Balances the layout
        ],
      ),
    );
  }
}