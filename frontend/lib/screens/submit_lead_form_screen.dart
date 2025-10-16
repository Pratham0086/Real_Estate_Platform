// frontend/lib/screens/submit_lead_form_screen.dart
import 'package:flutter/material.dart';
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

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing.
    }
    setState(() { _isLoading = true; });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final propertyDetails = {
      'title': _titleController.text,
      'description': _descController.text,
      'price': int.tryParse(_priceController.text) ?? 0,
      'location': _locationController.text,
      'bedrooms': int.tryParse(_bedroomsController.text) ?? 0,
      'bathrooms': int.tryParse(_bathroomsController.text) ?? 0,
      'area': int.tryParse(_areaController.text) ?? 0,
      'propertyType': _propertyType,
    };

    final success = await _inquiryService.submitPropertyLead(
      propertyDetails: propertyDetails,
      brokerIds: widget.brokerIds,
      token: authProvider.token!,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lead submitted successfully!'), backgroundColor: Colors.green),
        );
      } else {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit lead. Please try again.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Property Details'),
        actions: [
          if (_isLoading) const Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: Colors.white)),
          if (!_isLoading) IconButton(icon: const Icon(Icons.send), onPressed: _submitForm)
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Description'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Expected Price'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
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
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: _submitForm,
                child: const Text("Submit Lead to Broker(s)"),
              )
            ],
          ),
        ),
      ),
    );
  }
}