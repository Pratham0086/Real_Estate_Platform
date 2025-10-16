// frontend/lib/screens/property_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the new package
import 'edit_property_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../services/property_service.dart';
import '../services/inquiry_service.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final PropertyService _propertyService = PropertyService();
  final InquiryService _inquiryService = InquiryService();
  Map<String, dynamic>? _property;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPropertyDetails();
  }

  Future<void> _fetchPropertyDetails() async {
    final propertyData = await _propertyService.getPropertyById(widget.propertyId);
    if (mounted) {
      setState(() {
        _property = propertyData;
        _isLoading = false;
      });
    }
  }

  Widget _buildImageGallery(List<dynamic> imageUrls) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 250,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width * 0.8,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 50);
              },
            ),
          );
        },
      ),
    );
  }

  void _showInquiryDialog(BuildContext context, String token) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Inquiry Message'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(hintText: 'Type your message here...'),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Send'),
            onPressed: () async {
              final success = await _inquiryService.createInquiry(
                widget.propertyId,
                messageController.text,
                token,
              );
              if (mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Inquiry sent successfully!' : 'Failed to send inquiry.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // New helper widget for instant contact buttons
  Widget _buildContactButtons(Map<String, dynamic> owner) {
    final String? phoneNumber = owner['phoneNumber'];

    if (phoneNumber == null || phoneNumber.isEmpty) {
      return const SizedBox.shrink();
    }

    void _launchURL(String url) async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.call),
            label: const Text('Call Now'),
            onPressed: () => _launchURL('tel:$phoneNumber'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.message),
            label: const Text('WhatsApp'),
            onPressed: () => _launchURL('https://wa.me/$phoneNumber'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Loading...' : _property?['title'] ?? 'Details'),
        actions: [
          if (!_isLoading && _property != null && authProvider.isAuthenticated && _property!['owner']['_id'] == authProvider.userId)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => EditPropertyScreen(property: _property!),
                ));
                _fetchPropertyDetails();
              },
            ),
          if (!_isLoading && _property != null && authProvider.isAuthenticated && _property!['owner']['_id'] == authProvider.userId)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content: const Text('Do you want to permanently delete this property?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Yes')),
                    ],
                  ),
                );
                if (confirm == true) {
                  final success = await Provider.of<PropertyProvider>(context, listen: false)
                      .deleteProperty(widget.propertyId, authProvider.token!);
                  if (success && mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _property == null || _property!.containsKey('error')
              ? const Center(child: Text('Could not load property details.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageGallery(_property!['imageUrls']),
                      Text(_property!['title'], style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text('₹${_property!['price']}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.green)),
                      const SizedBox(height: 16),
                      Text(_property!['location'], style: Theme.of(context).textTheme.titleMedium),
                      const Divider(height: 32),
                      
                      _buildContactButtons(_property!['owner']),
                      
                      const Divider(height: 32),
                      
                      Text('Description:', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(_property!['description']),
                      const SizedBox(height: 16),
                      const Divider(),

                      Text('Details:', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Bedrooms: ${_property!['bedrooms']}'),
                      Text('Bathrooms: ${_property!['bathrooms']}'),
                      Text('Area: ${_property!['area']} sq ft'),
                      const SizedBox(height: 16),
                      const Divider(),
                      
                      Text('Listed by:', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Owner: ${_property!['owner']['name']}'),
                    ],
                  ),
                ),
      floatingActionButton: (authProvider.isAuthenticated && authProvider.userRole == 'customer' && !_isLoading)
          ? FloatingActionButton.extended(
              onPressed: () => _showInquiryDialog(context, authProvider.token!),
              label: const Text('Send Message'),
              icon: const Icon(Icons.email_outlined),
            )
          : null,
    );
  }
}