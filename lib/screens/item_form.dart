// lib/screens/item_form.dart

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../services/inventory_service.dart';
import '../models/inventory_item.dart';

class ItemForm extends StatefulWidget {
  final Database db;
  final InventoryItem? item;

  const ItemForm({Key? key, required this.db, this.item}) : super(key: key);

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  late InventoryService _service;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _skuController;
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _locationIdController;
  late TextEditingController _expiryDateController;
  late TextEditingController _minTempController;
  late TextEditingController _maxTempController;
  late TextEditingController _currentTempController;
  late TextEditingController _humidityController;
  String _status = 'IN_STOCK';

  @override
  void initState() {
    super.initState();
    _service = InventoryService(widget.db);
    _skuController = TextEditingController(text: widget.item?.sku ?? '');
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _categoryController = TextEditingController(text: widget.item?.category ?? '');
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '');
    _unitController = TextEditingController(text: widget.item?.unit ?? '');
    _locationIdController = TextEditingController(text: widget.item?.locationId?.toString() ?? '');
    _expiryDateController = TextEditingController(text: widget.item?.expiryDate?.toString() ?? '');
    _minTempController = TextEditingController(text: widget.item?.minTemp?.toString() ?? '');
    _maxTempController = TextEditingController(text: widget.item?.maxTemp?.toString() ?? '');
    _currentTempController = TextEditingController(text: widget.item?.currentTemp?.toString() ?? '');
    _humidityController = TextEditingController(text: widget.item?.humidity?.toString() ?? '');
    _status = widget.item?.status ?? 'IN_STOCK';
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _locationIdController.dispose();
    _expiryDateController.dispose();
    _minTempController.dispose();
    _maxTempController.dispose();
    _currentTempController.dispose();
    _humidityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Item' : 'Add Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(labelText: 'SKU *', border: OutlineInputBorder()),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category *', border: OutlineInputBorder()),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity *', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => (int.tryParse(v ?? '') ?? -1) < 0 ? 'Must be >= 0' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Unit *', border: OutlineInputBorder()),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationIdController,
              decoration: const InputDecoration(labelText: 'Location ID', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _expiryDateController,
              decoration: const InputDecoration(labelText: 'Expiry Date (ms since epoch)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minTempController,
                    decoration: const InputDecoration(labelText: 'Min Temp (°C)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxTempController,
                    decoration: const InputDecoration(labelText: 'Max Temp (°C)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _currentTempController,
                    decoration: const InputDecoration(labelText: 'Current Temp (°C)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _humidityController,
                    decoration: const InputDecoration(labelText: 'Humidity (%)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: ['IN_STOCK', 'IN_TRANSIT', 'QUARANTINED', 'EXPIRED', 'DISPATCHED']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final item = InventoryItem(
      id: widget.item?.id,
      sku: _skuController.text.trim(),
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      quantity: int.parse(_quantityController.text),
      unit: _unitController.text.trim(),
      locationId: _locationIdController.text.isNotEmpty ? int.parse(_locationIdController.text) : null,
      expiryDate: _expiryDateController.text.isNotEmpty ? int.parse(_expiryDateController.text) : null,
      minTemp: _minTempController.text.isNotEmpty ? double.parse(_minTempController.text) : null,
      maxTemp: _maxTempController.text.isNotEmpty ? double.parse(_maxTempController.text) : null,
      currentTemp: _currentTempController.text.isNotEmpty ? double.parse(_currentTempController.text) : null,
      humidity: _humidityController.text.isNotEmpty ? double.parse(_humidityController.text) : null,
      status: _status,
    );

    try {
      if (widget.item == null) {
        await _service.createItem(item);
      } else {
        await _service.updateItem(item);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}