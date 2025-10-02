// frontend/lib/screens/submit_lead_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/inquiry_service.dart';

class SubmitLeadFormScreen extends StatefulWidget {
  final List<String> brokerIds;
  const SubmitLeadFormScreen({super.key, required this.brokerIds});

  @override
  State<SubmitLeadFormScreen> createState() => _SubmitLeadFormScreenState();
}

class _SubmitLeadFormScreenState extends State<SubmitLeadFormScreen> {
  // All the same controllers and state variables as AddPropertyScreen
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaController = TextEditingController();
  String _propertyType = 'flat';
  bool _isLoading = false;

  final InquiryService _inquiryService = InquiryService();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  // The main difference is this function
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final propertyDetails = {
      'title': _titleController.text,
      'description': _descController.text,
      'price': int.parse(_priceController.text),
      'location': _locationController.text,
      'bedrooms': int.parse(_bedroomsController.text),
      'bathrooms': int.parse(_bathroomsController.text),
      'area': int.parse(_areaController.text),
      'propertyType': _propertyType,
    };

    final success = await _inquiryService.submitPropertyLead(
      propertyDetails: propertyDetails,
      brokerIds: widget.brokerIds,
      token: authProvider.token!,
    );

    if (mounted) {
      // Pop all the way back to the home screen
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Lead submitted to broker(s)!' : 'Failed to submit lead.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Property Details'),
        // The save button now calls _submitForm
        actions: [IconButton(icon: const Icon(Icons.send), onPressed: _submitForm)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          // The form fields are exactly the same as AddPropertyScreen
          child: ListView(
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Description'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _bedroomsController, decoration: const InputDecoration(labelText: 'Bedrooms'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _bathroomsController, decoration: const InputDecoration(labelText: 'Bathrooms'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _areaController, decoration: const InputDecoration(labelText: 'Area (sq ft)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
              DropdownButtonFormField<String>(
                value: _propertyType,
                items: ['flat', 'house', 'office', 'villa'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) => setState(() => _propertyType = newValue!),
                decoration: const InputDecoration(labelText: 'Property Type'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}