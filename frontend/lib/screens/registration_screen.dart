// frontend/lib/screens/registration_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_screen.dart';
import '../services/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  final String role;
  const RegistrationScreen({super.key, required this.role});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  bool _isLoading = false;
  String _userSubType = 'buyer';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is invalid, stop.
    }
    setState(() { _isLoading = true; });

    final phoneNumber = "+91${_phoneController.text.trim()}";

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() { _isLoading = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send OTP: ${e.message}')),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          final registrationData = {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text.trim(),
            'phoneNumber': phoneNumber,
            'role': widget.role,
            if (widget.role == 'customer') 'userSubType': _userSubType,
            if (widget.role == 'broker') 'companyName': _companyController.text.trim(),
          };

          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => OtpScreen(
              verificationId: verificationId,
              registrationData: registrationData,
            ),
          ));
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register as ${widget.role == 'broker' ? 'Broker' : 'Customer'}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Mobile Number (10 digits)'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.length != 10 ? 'Please enter a valid 10-digit number' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
              ),

              if (widget.role == 'customer')
                DropdownButtonFormField<String>(
                  value: _userSubType,
                  items: ['buyer', 'renter', 'both'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value[0].toUpperCase() + value.substring(1)));
                  }).toList(),
                  onChanged: (newValue) => setState(() => _userSubType = newValue!),
                  decoration: const InputDecoration(labelText: 'I am a...'),
                ),
              
              if (widget.role == 'broker')
                TextFormField(controller: _companyController, decoration: const InputDecoration(labelText: 'Company Name (Optional)')),

              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _sendOtp,
                      child: const Text('Send OTP'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}