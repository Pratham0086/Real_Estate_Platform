// frontend/lib/screens/submit_lead_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/inquiry_service.dart';

class SubmitLeadScreen extends StatefulWidget {
  const SubmitLeadScreen({super.key});
  @override
  State<SubmitLeadScreen> createState() => _SubmitLeadScreenState();
}

class _SubmitLeadScreenState extends State<SubmitLeadScreen> {
  final _messageController = TextEditingController();
  final InquiryService _inquiryService = InquiryService();
  bool _isLoading = false;

  void _submitLead() async {
    if (_messageController.text.isEmpty) return;
    setState(() { _isLoading = true; });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await _inquiryService.createInquiry(
      null, // No propertyId for a listing request
      _messageController.text,
      authProvider.token!,
      inquiryType: 'listing_request', // Specify the type
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Request sent to brokers!' : 'Failed to send request.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Your Property')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Describe the property you want to list (e.g., location, size, price, details). A broker will contact you.', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Property Details',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    onPressed: _submitLead,
                    child: const Text('Submit to Brokers'),
                  ),
          ],
        ),
      ),
    );
  }
}