// frontend/lib/screens/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'registration_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'How would you like to join?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('I am a Customer (Buyer/Owner)'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const RegistrationScreen(role: 'customer'),
                ));
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('I am a Broker/Agent'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const RegistrationScreen(role: 'broker'),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}