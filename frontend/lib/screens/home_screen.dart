// frontend/lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import 'broker_list_screen.dart';
import 'add_property_screen.dart';
import 'property_detail_screen.dart';
import 'submit_lead_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch all properties when the screen first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyProvider>(context, listen: false).fetchProperties();
    });
  }

  void _performSearch() {
    final filters = <String, String>{};
    if (_searchController.text.isNotEmpty) {
      filters['location'] = _searchController.text;
    }
    Provider.of<PropertyProvider>(context, listen: false).fetchProperties(filters: filters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Location',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          Expanded(
            child: Consumer<PropertyProvider>(
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

                    // --- DEBUG DISPLAY LOGIC ---
                    if (property['_id'] == 'DEBUG_MODE') {
                      return Card(
                        color: Colors.yellow[100],
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(property['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(property['location']),
                          trailing: Text('${property['owner']['name']}: ${property['price']}'),
                        ),
                      );
                    }
                    // -----------------------------

                    // Normal display for real properties
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(property['title']),
                        subtitle: Text(property['location']),
                        trailing: Text('₹${property['price']}'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PropertyDetailScreen(
                                propertyId: property['_id'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          // This now goes to the broker selection screen
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const BrokerListScreen()),
          );
        },
        child: const Icon(Icons.add_home_work), // New icon
        tooltip: 'List Your Property with a Broker',
      ),
    );
  }
}