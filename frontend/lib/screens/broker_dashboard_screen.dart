// frontend/lib/screens/broker_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../services/user_service.dart';
import '../services/inquiry_service.dart';
import 'property_detail_screen.dart';
import 'add_property_screen.dart';
import 'inquiry_detail_screen.dart';

class BrokerDashboardScreen extends StatefulWidget {
  const BrokerDashboardScreen({super.key});
  @override
  State<BrokerDashboardScreen> createState() => _BrokerDashboardScreenState();
}

class _BrokerDashboardScreenState extends State<BrokerDashboardScreen> {
  final UserService _userService = UserService();
  final InquiryService _inquiryService = InquiryService();
  List<dynamic> _customers = [];
  List<dynamic> _inquiries = [];
  bool _isCustomerLoading = true;
  bool _isInquiriesLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCustomers();
      _fetchInquiries();
    });
  }

  Future<void> _fetchCustomers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      final customersData = await _userService.getCustomers(authProvider.token!);
      if (mounted) {
        setState(() {
          _customers = customersData;
          _isCustomerLoading = false;
        });
      }
    }
  }
  
  Future<void> _fetchInquiries() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      final inquiriesData = await _inquiryService.getMyInquiries(authProvider.token!);
      if (mounted) {
        setState(() {
          _inquiries = inquiriesData;
          _isInquiriesLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Broker Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authProvider.logout(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.business_center), text: 'Properties'),
              Tab(icon: Icon(Icons.people_alt), text: 'Customers'),
              Tab(icon: Icon(Icons.inbox), text: 'Inquiries'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- Properties Tab ---
            Consumer<PropertyProvider>(
              builder: (context, propertyProvider, child) {
                if (propertyProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (propertyProvider.properties.isEmpty) {
                  return const Center(child: Text('No properties found.'));
                }
                return ListView.builder(
                  itemCount: propertyProvider.properties.length,
                  itemBuilder: (ctx, i) {
                    final property = propertyProvider.properties[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(property['title']),
                        subtitle: Text('Owned by: ${property['owner']?['name'] ?? 'N/A'}'),
                        trailing: Text('₹${property['price']}'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PropertyDetailScreen(propertyId: property['_id']),
                          ));
                        },
                      ),
                    );
                  },
                );
              },
            ),
            
            // --- Customers Tab ---
            _isCustomerLoading
                ? const Center(child: CircularProgressIndicator())
                : _customers.isEmpty
                    ? const Center(child: Text('No customers found.'))
                    : ListView.builder(
                        itemCount: _customers.length,
                        itemBuilder: (ctx, i) {
                          final customer = _customers[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(child: Text(customer['name'][0].toUpperCase())),
                              title: Text(customer['name']),
                              subtitle: Text(customer['email']),
                            ),
                          );
                        },
                      ),

            // --- Inquiries Tab ---
            _isInquiriesLoading
                ? const Center(child: CircularProgressIndicator())
                : _inquiries.isEmpty
                    ? const Center(child: Text('No inquiries received yet.'))
                    : ListView.builder(
                        itemCount: _inquiries.length,
                        itemBuilder: (ctx, i) {
                          final inquiry = _inquiries[i];
                          if (inquiry['inquiryType'] == 'listing_request') {
                            return Card(
                              color: Colors.blue[50],
                              margin: const EdgeInsets.all(8),
                              child: ListTile(
                                leading: const Icon(Icons.add_home_work, color: Colors.blue),
                                title: Text('New Listing Request from ${inquiry['inquirer']['name']}'),
                                subtitle: Text('Property: ${inquiry['propertyDetails']?['title'] ?? 'Details unavailable'}'),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => InquiryDetailScreen(inquiry: inquiry),
                                  ));
                                },
                              ),
                            );
                          } else {
                            return Card(
                              margin: const EdgeInsets.all(8),
                              child: ListTile(
                                title: Text('Inquiry for: ${inquiry['property']?['title'] ?? 'Deleted Property'}'),
                                subtitle: Text('From: ${inquiry['inquirer']?['name'] ?? 'N/A'}'),
                                trailing: Chip(label: Text(inquiry['status'])),
                              ),
                            );
                          }
                        },
                      ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const AddPropertyScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}