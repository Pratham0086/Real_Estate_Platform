// frontend/lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'add_property_screen.dart';
import 'broker_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // This index will now be either 0 for Home or 1 for Profile
  int _selectedIndex = 0;

  // The list of screens that the bottom bar will swap between.
  // Notice it only has two items now.
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    // If the middle button is tapped, it's a special action
    if (index == 1) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Customers go to the broker list, brokers go to the add property form
      if (authProvider.userRole == 'broker') {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const AddPropertyScreen()));
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const BrokerListScreen()));
      }
    } else {
      // For Home (index 0) and You (index 2), we update the state
      // We map the tab index to our list index (0 -> 0, 2 -> 1)
      setState(() {
        _selectedIndex = (index == 0) ? 0 : 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This maps our state index back to the correct visual tab index (0 -> 0, 1 -> 2)
    final int currentTabIndex = (_selectedIndex == 0) ? 0 : 2;

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Iconsax.add_square), label: 'Post Ad'),
          BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'You'),
        ],
        currentIndex: currentTabIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}