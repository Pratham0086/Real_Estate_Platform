// frontend/lib/screens/edit_property_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';

class EditPropertyScreen extends StatefulWidget {
  final Map<String, dynamic> property;
  const EditPropertyScreen({super.key, required this.property});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  // ... add other controllers

  List<File> _newImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.property['title']);
    // ... initialize other controllers
  }

  @override
  void dispose() {
    _titleController.dispose();
    // ... dispose other controllers
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _newImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final updatedData = {
        'title': _titleController.text,
        // ... add other text fields
      };

      final success = await Provider.of<PropertyProvider>(context, listen: false)
          .updateProperty(widget.property['_id'], updatedData, _newImages, authProvider.token!);

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Property'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _titleController, /* ... */),
              // ... other text form fields ...

              const SizedBox(height: 20),
              const Text('Existing Images', style: TextStyle(fontWeight: FontWeight.bold)),
              // Display existing images
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.property['imageUrls'].length,
                  itemBuilder: (ctx, i) => Image.network(widget.property['imageUrls'][i]),
                ),
              ),

              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text('Add More Images'),
              ),
              // Display newly picked images
               if (_newImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _newImages.length,
                    itemBuilder: (ctx, i) => Image.file(_newImages[i]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}