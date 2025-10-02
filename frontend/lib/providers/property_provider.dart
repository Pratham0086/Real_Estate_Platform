// frontend/lib/providers/property_provider.dart
import 'dart:io'; 
import 'package:flutter/material.dart';
import '../services/property_service.dart';

class PropertyProvider with ChangeNotifier {
  final PropertyService _propertyService = PropertyService();
  List<dynamic> _properties = [];
  bool _isLoading = false;

  List<dynamic> get properties => _properties;
  bool get isLoading => _isLoading;

  PropertyProvider() {
    fetchProperties();
  }

  Future<void> fetchProperties({Map<String, String>? filters}) async {
    _isLoading = true;
    notifyListeners();

    _properties = await _propertyService.getProperties(filters: filters);

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProperty(String id, Map<String, String> data, List<File> newImages, String token) async {
    final updatedProperty = await _propertyService.updateProperty(id, data, newImages, token);
    if (updatedProperty != null) {
        final index = _properties.indexWhere((prop) => prop['_id'] == id);
        if (index != -1) {
            _properties[index] = updatedProperty;
            notifyListeners();
        }
        return true;
    }
    return false;
  }

  // This function goes INSIDE the class
  Future<bool> deleteProperty(String id, String token) async {
    final success = await _propertyService.deleteProperty(id, token);
    if (success) {
      _properties.removeWhere((prop) => prop['_id'] == id);
      notifyListeners();
    }
    return success;
  }

  // in frontend/lib/providers/property_provider.dart

// ... your other methods are here ...

  Future<bool> createProperty(Map<String, String> data, List<File> images, String token) async {
    final newProperty = await _propertyService.createProperty(data, images, token);
    if (newProperty != null) {
      _properties.insert(0, newProperty);
      notifyListeners();
      return true;
    }
    return false;
  }
}
