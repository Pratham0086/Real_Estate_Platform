// frontend/lib/screens/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final Map<String, dynamic> registrationData;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.registrationData,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final AuthService _authService = AuthService();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  void _verifyOtpAndRegister() async {
    setState(() { _isLoading = true; });

    try {
      // 1. Create a credential with the OTP code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      // 2. Sign in the user with the credential on Firebase (this verifies the OTP)
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 3. If OTP is correct, proceed to register the user in our own backend
      final result = await _authService.registerWithDetails(widget.registrationData);

      if (mounted) {
        if (result.containsKey('userId')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please log in.')),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          // Handle backend registration failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Backend registration failed.')),
          );
        }
      }

    } catch (e) {
      // Handle exceptions (e.g., invalid OTP)
      if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid OTP or error: ${e.toString()}')),
          );
      }
    } finally {
        if (mounted) {
            setState(() { _isLoading = false; });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter the 6-digit code sent to ${widget.registrationData['phoneNumber']}'),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'OTP Code'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyOtpAndRegister,
                    child: const Text('Verify & Register'),
                  ),
          ],
        ),
      ),
    );
  }
}