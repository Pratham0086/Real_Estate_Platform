// frontend/lib/widgets/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/main_screen.dart';
import '../screens/login_screen.dart';
import '../screens/broker_dashboard_screen.dart'; // Import the new screen

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      // Check the user's role
      if (authProvider.userRole == 'broker') {
        return const BrokerDashboardScreen(); // Show broker dashboard
      } else {
        return const MainScreen(); // Show customer home screen
      }
    } else {
      return const LoginScreen();
    }
  }
}