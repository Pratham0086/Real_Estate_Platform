// frontend/lib/screens/add_property_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';

class AddPropertyScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const AddPropertyScreen({super.key, this.initialData});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _areaController;
  String _propertyType = 'flat';

  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData?['title'] ?? '');
    _descController = TextEditingController(text: widget.initialData?['description'] ?? '');
    _priceController = TextEditingController(text: widget.initialData?['price']?.toString() ?? '');
    _locationController = TextEditingController(text: widget.initialData?['location'] ?? '');
    _bedroomsController = TextEditingController(text: widget.initialData?['bedrooms']?.toString() ?? '');
    _bathroomsController = TextEditingController(text: widget.initialData?['bathrooms']?.toString() ?? '');
    _areaController = TextEditingController(text: widget.initialData?['area']?.toString() ?? '');
    _propertyType = widget.initialData?['propertyType'] ?? 'flat';
  }

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

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(imageQuality: 50, maxWidth: 800);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final newPropertyData = {
        'title': _titleController.text,
        'description': _descController.text,
        'price': _priceController.text,
        'location': _locationController.text,
        'bedrooms': _bedroomsController.text,
        'bathrooms': _bathroomsController.text,
        'area': _areaController.text,
        'propertyType': _propertyType,
      };

      final success = await Provider.of<PropertyProvider>(context, listen: false)
          .createProperty(newPropertyData, _images, authProvider.token!);

      if (success && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create property. Please try again.'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Property'),
        actions: [
          if (_isLoading) const Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: Colors.white)),
          if (!_isLoading) IconButton(icon: const Icon(Icons.save), onPressed: _saveForm)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image_search),
                label: const Text('Select Images'),
              ),
              const SizedBox(height: 10),
              if (_images.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.file(_images[i], fit: BoxFit.cover, width: 100, height: 100),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}