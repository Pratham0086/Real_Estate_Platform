// frontend/lib/screens/filter_screen.dart
import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? _propertyType;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  String? _bedrooms;

  void _applyFilters() {
    final filters = <String, String>{};

    if (_propertyType != null) {
      filters['propertyType'] = _propertyType!;
    }
    if (_minPriceController.text.isNotEmpty) {
      filters['minPrice'] = _minPriceController.text;
    }
    if (_maxPriceController.text.isNotEmpty) {
      filters['maxPrice'] = _maxPriceController.text;
    }
    if (_bedrooms != null) {
      // --- THIS IS THE FIX ---
      // This removes the '+' from "5+" before sending to the backend.
      final bedroomsValue = _bedrooms!.replaceAll('+', '');
      filters['bedrooms'] = bedroomsValue;
    }

    Navigator.of(context).pop(filters);
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(
            onPressed: _applyFilters,
            child: const Text('Apply', style: TextStyle(color: Color.fromARGB(255, 7, 7, 7), fontSize: 16)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Property Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _propertyType,
            hint: const Text('Select property type'),
            isExpanded: true,
            items: ['flat', 'house', 'office', 'villa'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value[0].toUpperCase() + value.substring(1)));
            }).toList(),
            onChanged: (newValue) {
              setState(() { _propertyType = newValue; });
            },
          ),
          const SizedBox(height: 24),

          const Text('Budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  decoration: const InputDecoration(labelText: 'Min Price'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  decoration: const InputDecoration(labelText: 'Max Price'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text('Bedrooms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8.0,
            children: ['1', '2', '3', '4', '5+'].map((bed) {
              return ChoiceChip(
                label: Text('$bed BHK'),
                selected: _bedrooms == bed,
                onSelected: (selected) {
                  setState(() {
                    _bedrooms = selected ? bed : null;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}