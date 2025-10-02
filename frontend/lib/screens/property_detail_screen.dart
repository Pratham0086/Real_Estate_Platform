// frontend/lib/screens/property_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        title: const Text('Send Inquiry'),
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
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text('Details:', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Bedrooms: ${_property!['bedrooms']}'),
                      Text('Bathrooms: ${_property!['bathrooms']}'),
                      Text('Area: ${_property!['area']} sq ft'),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text('Description:', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(_property!['description']),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text('Listed by:', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Owner: ${_property!['owner']['name']} (${_property!['owner']['email']})'),
                    ],
                  ),
                ),
      floatingActionButton: (authProvider.isAuthenticated && authProvider.userRole == 'customer' && !_isLoading)
          ? FloatingActionButton.extended(
              onPressed: () {
                _showInquiryDialog(context, authProvider.token!);
              },
              label: const Text('Inquire Now'),
              icon: const Icon(Icons.email_outlined),
            )
          : null,
    );
  }
}