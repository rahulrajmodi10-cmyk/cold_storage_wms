// lib/screens/party_form.dart

import 'package:flutter/material.dart';
import '../services/finance_service.dart';
import '../models/finance_models.dart';

class PartyForm extends StatefulWidget {
  final FinanceService financeService;
  final Party? party;

  const PartyForm({Key? key, required this.financeService, this.party})
      : super(key: key);

  @override
  State<PartyForm> createState() => _PartyFormState();
}

class _PartyFormState extends State<PartyForm> {
  late FinanceService _service;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _gstinController;
  late TextEditingController _panController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _contactPersonController;
  late TextEditingController _creditLimitController;
  late TextEditingController _paymentTermsController;
  late TextEditingController _openingBalanceController;
  String _type = 'CUSTOMER';

  @override
  void initState() {
    super.initState();
    _service = widget.financeService;
    final p = widget.party;
    _nameController = TextEditingController(text: p?.name ?? '');
    _gstinController = TextEditingController(text: p?.gstin ?? '');
    _panController = TextEditingController(text: p?.pan ?? '');
    _addressController = TextEditingController(text: p?.address ?? '');
    _cityController = TextEditingController(text: p?.city ?? '');
    _stateController = TextEditingController(text: p?.state ?? '');
    _pincodeController = TextEditingController(text: p?.pincode ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _contactPersonController = TextEditingController(text: p?.contactPerson ?? '');
    _creditLimitController =
        TextEditingController(text: p != null ? p.creditLimit.toString() : '');
    _paymentTermsController =
        TextEditingController(text: p != null ? p.paymentTerms.toString() : '30');
    _openingBalanceController =
        TextEditingController(text: p != null ? p.openingBalance.toString() : '');
    _type = p?.type ?? 'CUSTOMER';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _contactPersonController.dispose();
    _creditLimitController.dispose();
    _paymentTermsController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.party != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Party' : 'Add Party'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Name *', border: OutlineInputBorder()),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                  labelText: 'Type *', border: OutlineInputBorder()),
              items: const ['CUSTOMER', 'VENDOR', 'BOTH']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _gstinController,
              decoration: const InputDecoration(
                  labelText: 'GSTIN', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _panController,
              decoration: const InputDecoration(
                  labelText: 'PAN', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contactPersonController,
              decoration: const InputDecoration(
                  labelText: 'Contact Person', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                  labelText: 'Phone', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                  labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                  labelText: 'Address', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                        labelText: 'City', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                        labelText: 'State', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pincodeController,
              decoration: const InputDecoration(
                  labelText: 'Pincode', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _creditLimitController,
                    decoration: const InputDecoration(
                        labelText: 'Credit Limit', border: OutlineInputBorder()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _paymentTermsController,
                    decoration: const InputDecoration(
                        labelText: 'Payment Terms (days)',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (int.tryParse(v ?? '') ?? -1) < 0 ? 'Must be >= 0' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _openingBalanceController,
              decoration: const InputDecoration(
                  labelText: 'Opening Balance', border: OutlineInputBorder()),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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

    String? emptyToNull(TextEditingController c) {
      final v = c.text.trim();
      return v.isEmpty ? null : v;
    }

    final party = Party(
      id: widget.party?.id,
      name: _nameController.text.trim(),
      type: _type,
      gstin: emptyToNull(_gstinController),
      pan: emptyToNull(_panController),
      address: emptyToNull(_addressController),
      city: emptyToNull(_cityController),
      state: emptyToNull(_stateController),
      pincode: emptyToNull(_pincodeController),
      phone: emptyToNull(_phoneController),
      email: emptyToNull(_emailController),
      contactPerson: emptyToNull(_contactPersonController),
      creditLimit: double.tryParse(_creditLimitController.text) ?? 0,
      paymentTerms: int.tryParse(_paymentTermsController.text) ?? 30,
      openingBalance: double.tryParse(_openingBalanceController.text) ?? 0,
      isActive: widget.party?.isActive ?? 1,
      createdAt: widget.party?.createdAt,
    );

    try {
      if (widget.party == null) {
        await _service.createParty(party);
      } else {
        await _service.updateParty(party);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
