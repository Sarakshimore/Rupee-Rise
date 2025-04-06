import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'goal_investing_screen.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import 'portfolio_recommendations_screen.dart';
import 'product_finder_screen.dart';
import 'profile_screen.dart';
import 'learning_screen.dart';
import 'realtime_index_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  bool _showLearning = false;
  String? userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        userName = snapshot.data()?['name'] ?? 'Friend'; // stores the user's name
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Text(
          'Rupee Rise',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Rupee Rise',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (userName != null)
                    const SizedBox(height: 5),
                  Text(
                    'Welcome, $userName!',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_outline, color: Colors.green),
              title: Text(
                'Your Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.show_chart_outlined, color: Colors.green),
              title: Text(
                'Market Indexes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RealTimeIndexScreen()),
              ),
            )

          ],
        ),
      ),

      body: _showLearning ? LoginScreen() : _buildHomeContent(context),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [

                const SizedBox(height: 10),
                Text(
                  'Get Started',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  'Get personalized insights and manage your finances with ease.',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildFeatureCard(
                  context: context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat with AI',
                  description: 'Ask questions and get financial advice',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  ),
                ),
                const SizedBox(height: 15),
                _buildFeatureCard(
                  context: context,
                  icon: Icons.school_outlined,
                  title: 'Start Learning',
                  description: 'Access educational content and resources',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LearningScreen()),
                  ),
                ),
                const SizedBox(height: 15),
                _buildFeatureCard(
                  context: context,
                  icon: Icons.currency_rupee_outlined,
                  title: 'Portfolio Suggestion',
                  description: 'Personalized suggestions based on risk profile and goals',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PortfolioRecommendationsScreen()),
                  ),
                ),
                const SizedBox(height: 15),
                _buildFeatureCard(
                  context: context,
                  icon: Icons.insert_chart_outlined,
                  title: 'Explore Investments',
                  description: 'Get investment recommendations',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductFinderScreen()),
                  ),
                ),
                const SizedBox(height: 15),
                _buildFeatureCard(
                  context: context,
                  icon: Icons.savings_outlined,
                  title: 'Goal-Based Investing',
                  description: 'Get an advice on monthly SIP',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GoalInvestingScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4CAF50),
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}