// frontend/lib/screens/inquiry_detail_screen.dart
import 'package:flutter/material.dart';
import 'add_property_screen.dart';

class InquiryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> inquiry;
  const InquiryDetailScreen({super.key, required this.inquiry});

  @override
  Widget build(BuildContext context) {
    // Extract the nested details for easier access
    final details = inquiry['propertyDetails'];
    final inquirer = inquiry['inquirer'];

    return Scaffold(
      appBar: AppBar(title: Text('Lead from ${inquirer['name']}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Property Details:', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ListTile(title: const Text('Title'), subtitle: Text(details['title'] ?? 'N/A')),
            ListTile(title: const Text('Location'), subtitle: Text(details['location'] ?? 'N/A')),
            ListTile(title: const Text('Price'), subtitle: Text('₹${details['price'] ?? 0}')),
            ListTile(title: const Text('Type'), subtitle: Text(details['propertyType'] ?? 'N/A')),
            ListTile(title: const Text('Bedrooms'), subtitle: Text(details['bedrooms']?.toString() ?? 'N/A')),
            const SizedBox(height: 20),
            Text('Customer Information:', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ListTile(title: const Text('Name'), subtitle: Text(inquirer['name'] ?? 'N/A')),
            ListTile(title: const Text('Email'), subtitle: Text(inquirer['email'] ?? 'N/A')),
            ListTile(title: const Text('Phone'), subtitle: Text(inquirer['phoneNumber'] ?? 'N/A')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to the AddPropertyScreen and pass the details
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => AddPropertyScreen(initialData: details),
          ));
        },
        label: const Text('Create Listing from this Lead'),
        icon: const Icon(Icons.add_home_work),
      ),
    );
  }
}