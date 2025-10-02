// frontend/lib/services/property_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PropertyService {
  final String _baseUrl = "http://192.168.31.107:3000/api/properties";

    // --- READ ---
    Future<List<dynamic>> getProperties({Map<String, String>? filters}) async {
    try {
      // Start with the base URL
      var uri = Uri.parse(_baseUrl);

      // If filters are provided, add them as query parameters
      if (filters != null && filters.isNotEmpty) {
        uri = uri.replace(queryParameters: filters);
      }

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<Map<String, dynamic>> getPropertyById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Property not found'};
      }
    } catch (e) {
      print(e);
      return {'error': 'Connection failed'};
    }
  }

  // --- CREATE ---
  Future<Map<String, dynamic>?> createProperty(Map<String, String> data, List<File> images, String token) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields.addAll(data);

      // Add image files
      for (var image in images) {
        request.files.add(await http.MultipartFile.fromPath('images', image.path));
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }


  // --- UPDATE ---
  Future<Map<String, dynamic>?> updateProperty(String id, Map<String, String> data, List<File> newImages, String token) async {
    try {
        var request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/$id'));

        request.headers['Authorization'] = 'Bearer $token';
        request.fields.addAll(data);

        for (var image in newImages) {
            request.files.add(await http.MultipartFile.fromPath('images', image.path));
        }

        var response = await request.send();
        if (response.statusCode == 200) {
            final responseBody = await response.stream.bytesToString();
            return jsonDecode(responseBody);
        }
        return null;
    } catch (e) {
        print(e);
        return null;
    }
  }

  // --- DELETE ---
  Future<bool> deleteProperty(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }
}