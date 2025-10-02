// frontend/lib/services/inquiry_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class InquiryService {
  final String _baseUrl = "http://192.168.31.107:3000/api/inquiries"; // Use your local IP

  // For a customer to create an inquiry
  Future<bool> createInquiry(String? propertyId, String message, String token, {String inquiryType = 'property_contact'}) async {
    try {
        final body = {
            'message': message,
            'inquiryType': inquiryType,
        };
        if (propertyId != null) {
            body['propertyId'] = propertyId;
        }

        final response = await http.post(
            Uri.parse(_baseUrl),
            headers: { /* ... same as before ... */ },
            body: jsonEncode(body),
        );
        return response.statusCode == 201;
    } catch (e) {
        print(e);
        return false;
    }
}

  // For a broker to get their inquiries
  Future<List<dynamic>> getMyInquiries(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/my-inquiries'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }
  // For a customer to submit a property lead request to multiple brokers
    Future<bool> submitPropertyLead({
    required Map<String, dynamic> propertyDetails,
    required List<String> brokerIds,
    required String token,
  }) async {
    try {
      final body = {
        'inquiryType': 'listing_request',
        'propertyDetails': propertyDetails,
        'brokerIds': brokerIds,
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      return response.statusCode == 201;
    } catch (e) {
      print(e);
      return false;
    }
  }
}