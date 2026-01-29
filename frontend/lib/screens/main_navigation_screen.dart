import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'home_screen.dart';
import 'inquiries_screen.dart';
import 'profile_screen.dart';
import 'announcements_screen.dart';
import 'events_list_screen.dart';
import '../providers/navigation_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final int currentIndex = navProvider.currentIndex;
    final user = Provider.of<AuthProvider>(context).user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isAdmin = user['role'] == 'admin';

    // Screens based on role
    final List<Widget> screens = isAdmin
        ? [
            const DashboardScreen(),
            const InquiriesScreen(),
            const Center(child: Text("Events Management")),
            const ProfileScreen(),
          ]
        : [
            const HomeScreen(),
            const AnnouncementsScreen(),
            const EventsListScreen(),
            const ProfileScreen(),
          ];

    final List<BottomNavigationBarItem> navItems = isAdmin
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum_outlined),
              label: "Inbox",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ]
        : const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              label: "Updates",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              label: "Events",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ];

    if (currentIndex >= navItems.length) {
      navProvider.setIndex(0);
      return const SizedBox();
    }

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => navProvider.setIndex(index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: navItems,
      ),
    );
  }
}
