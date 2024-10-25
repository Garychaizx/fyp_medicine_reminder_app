import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:medicine_reminder/pages/medications_page.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavBarState();
}

class _NavBarState extends State<Navbar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // Replace with your home page
    const Text('Home Page'),
    // Replace with your updates page
    const Text('Updates Page'),
    // The new medications page
    MedicationsPage(),
    // Replace with your manage page
    const Text('Manage Page'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              text: 'Manage',
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
