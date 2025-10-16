// frontend/lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import 'property_detail_screen.dart';
import 'filter_screen.dart'; // Import the new filter screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch all properties when the screen first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyProvider>(context, listen: false).fetchProperties();
    });
  }

  // Function to open the filter screen and handle the result
  void _openFilterScreen() async {
    final selectedFilters = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(builder: (ctx) => const FilterScreen()),
    );

    // If the user applied filters (didn't just press back),
    // fetch the properties with those filters.
    if (selectedFilters != null && selectedFilters.isNotEmpty) {
      Provider.of<PropertyProvider>(context, listen: false).fetchProperties(filters: selectedFilters);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.user?['name'] ?? 'User';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Real Estate', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
              TextButton(
                onPressed: () {},
                child: const Text('Post Property'),
              ),
            ],
            floating: true,
          ),
          
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hi $userName, let's find your dream home!", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  
                  // This GestureDetector now opens the filter screen
                  GestureDetector(
                    onTap: _openFilterScreen,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search),
                          SizedBox(width: 8),
                          Text('Search by city, location, or project...'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Recommended for You', style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          
          Consumer<PropertyProvider>(
            builder: (context, propertyProvider, child) {
              if (propertyProvider.isLoading) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              if (propertyProvider.properties.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text('No properties found.')));
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final property = propertyProvider.properties[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(property['title']),
                        subtitle: Text(property['location']),
                        trailing: Text('₹${property['price']}'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => PropertyDetailScreen(propertyId: property['_id']),
                          ));
                        },
                      ),
                    );
                  },
                  childCount: propertyProvider.properties.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}