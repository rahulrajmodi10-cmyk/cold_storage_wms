// lib/screens/parties_screen.dart

import 'package:flutter/material.dart';
import '../services/finance_service.dart';
import '../models/finance_models.dart';
import 'party_form.dart';

class PartiesScreen extends StatefulWidget {
  final FinanceService financeService;

  const PartiesScreen({Key? key, required this.financeService})
      : super(key: key);

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  late FinanceService _service;
  List<Party> _parties = [];
  bool _loading = false;
  String? _filterType; // null = all, CUSTOMER, VENDOR, BOTH

  @override
  void initState() {
    super.initState();
    _service = widget.financeService;
    _loadParties();
  }

  Future<void> _loadParties() async {
    setState(() => _loading = true);
    try {
      _parties = await _service.getParties(type: _filterType);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _showPartyForm([Party? party]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartyForm(financeService: _service, party: party),
      ),
    );
    if (result == true) _loadParties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showPartyForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              value: _filterType,
              decoration: const InputDecoration(
                  labelText: 'Filter by Type', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem<String?>(value: null, child: Text('All')),
                DropdownMenuItem<String?>(value: 'CUSTOMER', child: Text('Customer')),
                DropdownMenuItem<String?>(value: 'VENDOR', child: Text('Vendor')),
                DropdownMenuItem<String?>(value: 'BOTH', child: Text('Both')),
              ],
              onChanged: (v) {
                setState(() => _filterType = v);
                _loadParties();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _parties.isEmpty
                    ? const Center(child: Text('No parties found'))
                    : RefreshIndicator(
                        onRefresh: _loadParties,
                        child: ListView.separated(
                          itemCount: _parties.length,
                          separatorBuilder: (_, __) => const Divider(height: 0),
                          itemBuilder: (context, i) {
                            final p = _parties[i];
                            return ListTile(
                              leading: Icon(
                                p.type == 'VENDOR'
                                    ? Icons.local_shipping
                                    : p.type == 'BOTH'
                                        ? Icons.swap_horiz
                                        : Icons.storefront,
                              ),
                              title: Text(p.name),
                              subtitle: Text([
                                p.type,
                                if (p.phone != null && p.phone!.isNotEmpty)
                                  p.phone!,
                                if (p.city != null && p.city!.isNotEmpty) p.city!,
                              ].join(' • ')),
                              trailing: const Icon(Icons.edit),
                              onTap: () => _showPartyForm(p),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
