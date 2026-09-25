// lib/screens/inventory_dashboard.dart

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../services/inventory_service.dart';
import '../models/inventory_item.dart';
import 'item_form.dart';

class InventoryDashboard extends StatefulWidget {
  final Database db;

  const InventoryDashboard({Key? key, required this.db}) : super(key: key);

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  late InventoryService _service;
  List<InventoryItem> _items = [];
  String _searchQuery = '';
  String? _filterCategory;
  String? _filterStatus;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _service = InventoryService(widget.db);
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);
    try {
      _items = await _service.searchItems(
        query: _searchQuery,
        category: _filterCategory,
        status: _filterStatus,
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showItemForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search SKU/Name',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    _searchQuery = v;
                    _loadItems();
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterCategory,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: ['Produce', 'Meat', 'Dairy', 'Frozen', 'Other']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) {
                          _filterCategory = v;
                          _loadItems();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: ['IN_STOCK', 'IN_TRANSIT', 'QUARANTINED', 'EXPIRED', 'DISPATCHED']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          _filterStatus = v;
                          _loadItems();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('No items found'))
                    : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _statusColor(item.status),
                                child: Text(item.status.substring(0, 1)),
                              ),
                              title: Text('${item.name} (${item.sku})'),
                              subtitle: Text('${item.quantity} ${item.unit} • ${item.status} • ${item.category}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showItemForm(item: item),
                              ),
                              onTap: () => _showItemDetail(item),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'IN_STOCK': return Colors.green;
      case 'QUARANTINED': return Colors.red;
      case 'EXPIRED': return Colors.grey;
      case 'DISPATCHED': return Colors.blue;
      default: return Colors.orange;
    }
  }

  void _showItemForm({InventoryItem? item}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ItemForm(db: widget.db, item: item)),
    );
    if (result == true) _loadItems();
  }

  void _showItemDetail(InventoryItem item) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.name} (${item.sku})', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Category: ${item.category}'),
            Text('Quantity: ${item.quantity} ${item.unit}'),
            Text('Status: ${item.status}'),
            if (item.locationId != null) Text('Location: ${item.locationId}'),
            if (item.expiryDate != null) Text('Expiry: ${DateTime.fromMillisecondsSinceEpoch(item.expiryDate!)}'),
            if (item.currentTemp != null) Text('Temp: ${item.currentTemp}°C'),
            if (item.humidity != null) Text('Humidity: ${item.humidity}%'),
          ],
        ),
      ),
    );
  }
}