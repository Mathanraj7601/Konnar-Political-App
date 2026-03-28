import 'package:flutter/material.dart';
import '../widgets/home_dashboard_module.dart';
import 'announcements_page.dart';
import 'updates_page.dart' as screens;
import 'profile_page.dart';
import '../services/navigation_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Register this screen with navigation service
    NavigationService().homeScreenState = this;
  }

  // Method to change tab index from outside
  void changeTabIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Method to go back to previous tab
  void goBackToPreviousTab() {
    if (_currentIndex != 0) {
      changeTabIndex(0);
    }
  }

  // The different tabs for the home screen
  final List<Widget> _tabs = [
    const _HomeDashboardTab(),
    const AnnouncementsPage(),
    const screens.UpdatesPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF1223B3), // Blue Theme Color
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Updates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// A dedicated Home Dashboard screen with screenshot-like mock data
class _HomeDashboardTab extends StatelessWidget {
  const _HomeDashboardTab();

  @override
  Widget build(BuildContext context) {
    return HomeDashboardModule(
      profileName: 'Arjun Kumar',
      profileDistrict: 'Chennai District',
      onNavigate: (index) {
        final homeScreenState = context.findAncestorStateOfType<HomeScreenState>();
        homeScreenState?.changeTabIndex(index);
      },
    );
  }
}



