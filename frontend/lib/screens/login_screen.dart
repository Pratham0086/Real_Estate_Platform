// frontend/lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'role_selection_screen.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  List<bool> _isSelected = [true, false]; // [Customer, Broker]

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    // ... your existing _login function, no changes needed ...
    setState(() { _isLoading = true; });
    final role = _isSelected[0] ? 'customer' : 'broker';
    final success = await Provider.of<AuthProvider>(context, listen: false).login(
      _loginIdController.text.trim(),
      _passwordController.text.trim(),
      role,
    );
    if (!success && mounted) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please check credentials and selected role.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      // Wrap the body in a SingleChildScrollView
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40), // Added some space at the top
              ToggleButtons(
                isSelected: _isSelected,
                onPressed: (index) {
                  setState(() {
                    _isSelected = [false, false];
                    _isSelected[index] = true;
                  });
                },
                borderRadius: BorderRadius.circular(8.0),
                constraints: BoxConstraints(minWidth: 100, minHeight: 40),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Customer')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Broker')),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _loginIdController,
                decoration: const InputDecoration(labelText: 'Email or Mobile Number'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,

              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    print("Forgot Password tapped!");
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        textStyle: const TextStyle(fontSize: 18)
                      ),
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const RoleSelectionScreen()),
                  );
                },
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}