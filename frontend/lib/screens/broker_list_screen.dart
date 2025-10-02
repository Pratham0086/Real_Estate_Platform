// frontend/lib/screens/broker_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import 'submit_lead_form_screen.dart';

class BrokerListScreen extends StatefulWidget {
  const BrokerListScreen({super.key});

  @override
  State<BrokerListScreen> createState() => _BrokerListScreenState();
}

class _BrokerListScreenState extends State<BrokerListScreen> {
  final UserService _userService = UserService();
  List<dynamic> _brokers = [];
  bool _isLoading = true;
  final List<String> _selectedBrokerIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBrokers();
    });
  }

  Future<void> _fetchBrokers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      final brokersData = await _userService.getBrokers(authProvider.token!);
      if (mounted) {
        setState(() {
          _brokers = brokersData;
          _isLoading = false;
        });
      }
    }
  }

  void _toggleBrokerSelection(String brokerId) {
    setState(() {
      if (_selectedBrokerIds.contains(brokerId)) {
        _selectedBrokerIds.remove(brokerId);
      } else {
        _selectedBrokerIds.add(brokerId);
      }
    });
  }

  // This is the single, correct version of this function
  void _navigateToNextStep() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => SubmitLeadFormScreen(brokerIds: _selectedBrokerIds),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Broker')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _brokers.isEmpty
              ? const Center(child: Text('No brokers available.'))
              : ListView.builder(
                  itemCount: _brokers.length,
                  itemBuilder: (ctx, i) {
                    final broker = _brokers[i];
                    final isSelected = _selectedBrokerIds.contains(broker['_id']);
                    return CheckboxListTile(
                      title: Text(broker['name']),
                      subtitle: Text(broker['companyName'] ?? 'Independent Agent'),
                      value: isSelected,
                      onChanged: (bool? value) {
                        _toggleBrokerSelection(broker['_id']);
                      },
                    );
                  },
                ),
      floatingActionButton: _selectedBrokerIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _navigateToNextStep,
              label: const Text('Next'),
              icon: const Icon(Icons.arrow_forward),
            )
          : null,
    );
  }
}