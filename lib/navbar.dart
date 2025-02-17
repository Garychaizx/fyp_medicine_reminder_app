import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:medicine_reminder/pages/login_page.dart';
import 'package:medicine_reminder/pages/medications_page.dart';
import 'package:medicine_reminder/pages/profile_page.dart';
import 'package:medicine_reminder/pages/task_visualization_page.dart';
import 'package:medicine_reminder/services/auth_service.dart';

Future<Map<String, dynamic>> fetchUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("No logged-in user found");

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!userDoc.exists) throw Exception("User data not found");

  return userDoc.data()!;
}

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavBarState();
}

class _NavBarState extends State<Navbar> {
  int _currentIndex = 0;

  final AuthService _authService = AuthService();

  void handleLogout(BuildContext context) async {
    await _authService.logOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  final List<Widget> _pages = [
    // Replace with your home page
    TaskVisualizationPage(),
    // Replace with your updates page
    const Text('Updates Page'),
    // The new medications page
    MedicationsPage(),
    // Replace with your manage page
    FutureBuilder<Map<String, dynamic>>(
    future: fetchUserData(), // Create a function to fetch user data
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else {
        return ProfilePage(userData: snapshot.data ?? {});
      }
    },
  ),
  ];

    final List<String> _titles = [
    'Home',
    'Updates',
    'Medications',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  title: Text(
    _titles[_currentIndex],
    style: TextStyle(
      fontSize: 20,  // Adjust font size as needed
      fontWeight: FontWeight.bold, // Make it bold
      color: Colors.white, // Change color to white
    ),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () => handleLogout(context),
    ),
  ],
  backgroundColor: const Color.fromARGB(255, 2, 3, 47),
),
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        child: GNav(
          backgroundColor: Colors.black,
          color: Colors.white,
          activeColor: Colors.white,
          tabBackgroundColor: const Color.fromARGB(66, 150, 147, 147),
          gap: 8,
          padding: const EdgeInsets.all(16),
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.tips_and_updates,
              text: 'Updates',
            ),
            GButton(
              icon: Icons.medication,
              text: 'Medications',
            ),
            GButton(
              icon: Icons.format_list_bulleted,
              text: 'Profile',
            ),
          ],
          onTabChange: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

