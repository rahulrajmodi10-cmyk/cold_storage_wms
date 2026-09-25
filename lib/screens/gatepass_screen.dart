// lib/screens/gatepass_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/gatepass_barcode_service.dart';
import '../services/inventory_service.dart';
import '../models/gatepass_barcode_models.dart';
import '../models/inventory_item.dart';

class GatepassScreen extends StatefulWidget {
  final GatepassBarcodeService gatepassService;
  final InventoryService inventoryService;

  const GatepassScreen({
    super.key,
    required this.gatepassService,
    required this.inventoryService,
  });

  @override
  State<GatepassScreen> createState() => _GatepassScreenState();
}

class _GatepassScreenState extends State<GatepassScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Gatepass> _gatepasses = [];
  List<GatepassType> _gatepassTypes = [];
  bool _loading = true;
  String _filterStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      widget.gatepassService.getGatepasses(status: _filterStatus == 'ALL' ? null : _filterStatus),
      widget.gatepassService.getGatepassTypes(),
    ]);
    setState(() {
      _gatepasses = results[0] as List<Gatepass>;
      _gatepassTypes = results[1] as List<GatepassType>;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gatepass Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'List', icon: Icon(Icons.list)),
            Tab(text: 'Create', icon: Icon(Icons.add)),
            Tab(text: 'Dispatch', icon: Icon(Icons.local_shipping)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _filterStatus,
            onSelected: (value) {
              setState(() => _filterStatus = value);
              _loadData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ALL', child: Text('All')),
              const PopupMenuItem(value: 'DRAFT', child: Text('Draft')),
              const PopupMenuItem(value: 'SUBMITTED', child: Text('Submitted')),
              const PopupMenuItem(value: 'APPROVED', child: Text('Approved')),
              const PopupMenuItem(value: 'ACTIVE', child: Text('Active')),
              const PopupMenuItem(value: 'COMPLETED', child: Text('Completed')),
              const PopupMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 8),
                  Text(_filterStatus),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGatepassList(),
                _buildCreateGatepass(),
                _buildDispatchSchedule(),
              ],
            ),
    );
  }

  Widget _buildGatepassList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _gatepasses.length,
        itemBuilder: (context, index) {
          final gp = _gatepasses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(gp.status).withOpacity(0.2),
                child: Icon(Icons.receipt_long, color: _getStatusColor(gp.status)),
              ),
              title: Text(gp.gatepassNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type: ${_getTypeName(gp.gatepassTypeId)} | Vehicle: ${gp.vehicleNumber ?? 'N/A'}'),
                  Text('Driver: ${gp.driverName ?? 'N/A'} | ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(gp.requestedDate ?? 0))}'),
                  Text('Items: ${gp.totalItems} | Qty: ${gp.totalQuantity} | Weight: ${gp.totalWeight?.toStringAsFixed(1) ?? '0'} kg'),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Chip(
                    label: Text(gp.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: _getStatusColor(gp.status),
                  ),
                  if (gp.status == 'DRAFT' || gp.status == 'SUBMITTED')
                    TextButton(
                      onPressed: () => _showGatepassActions(gp),
                      child: const Text('Actions'),
                    ),
                ],
              ),
              onTap: () => _showGatepassDetails(gp),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateGatepass() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _GatepassForm(
        gatepassService: widget.gatepassService,
        gatepassTypes: _gatepassTypes,
        inventoryService: widget.inventoryService,
        onSaved: _loadData,
      ),
    );
  }

  Widget _buildDispatchSchedule() {
    return _DispatchScheduleTab(gatepassService: widget.gatepassService);
  }

  void _showGatepassDetails(Gatepass gp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => _GatepassDetailSheet(
          gatepass: gp,
          gatepassService: widget.gatepassService,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showGatepassActions(Gatepass gp) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Submit for Approval'),
              onTap: () async {
                Navigator.pop(context);
                await widget.gatepassService.submitGatepass(gp.id!, 1);
                _loadData();
              },
            ),
            if (gp.status == 'SUBMITTED' || gp.status == 'APPROVED')
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Approve'),
                onTap: () async {
                  Navigator.pop(context);
                  await widget.gatepassService.approveGatepass(gp.id!, 1);
                  _loadData();
                },
              ),
            if (gp.status == 'SUBMITTED' || gp.status == 'APPROVED')
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Reject'),
                onTap: () => _showRejectDialog(gp),
              ),
            if (gp.status == 'APPROVED')
              ListTile(
                leading: const Icon(Icons.directions_car, color: Colors.blue),
                title: const Text('Activate (Vehicle Entry)'),
                onTap: () async {
                  Navigator.pop(context);
                  await widget.gatepassService.activateGatepass(gp.id!, 1);
                  _loadData();
                },
              ),
            if (gp.status == 'ACTIVE')
              ListTile(
                leading: const Icon(Icons.check, color: Colors.green),
                title: const Text('Complete (Vehicle Exit)'),
                onTap: () => _showCompleteDialog(gp),
              ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Generate QR Code'),
              onTap: () => _showQRCode(gp),
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print Gatepass'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(Gatepass gp) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Gatepass'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Rejection Reason'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.gatepassService.rejectGatepass(gp.id!, 1, controller.text);
              _loadData();
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(Gatepass gp) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Gatepass'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Completion Notes'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.gatepassService.completeGatepass(gp.id!, 1, notes: controller.text);
              _loadData();
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showQRCode(Gatepass gp) {
    final qrData = widget.gatepassService.generateGatepassQR(gp);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code: ${gp.gatepassNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR code would be displayed here using a QR code widget
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[200],
              child: const Center(child: Text('QR Code\n(Use qr_flutter package)')),
            ),
            const SizedBox(height: 16),
            SelectableText(qrData),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  String _getTypeName(int typeId) {
    return _gatepassTypes.firstWhere((t) => t.id == typeId, orElse: () => GatepassType(code: '', name: 'Unknown')).name;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green;
      case 'ACTIVE': return Colors.blue;
      case 'APPROVED': return Colors.purple;
      case 'SUBMITTED': return Colors.orange;
      case 'REJECTED': return Colors.red;
      case 'CANCELLED': return Colors.grey;
      default: return Colors.grey;
    }
  }
}

class _GatepassForm extends StatefulWidget {
  final GatepassBarcodeService gatepassService;
  final List<GatepassType> gatepassTypes;
  final InventoryService inventoryService;
  final VoidCallback onSaved;

  const _GatepassForm({
    required this.gatepassService,
    required this.gatepassTypes,
    required this.inventoryService,
    required this.onSaved,
  });

  @override
  State<_GatepassForm> createState() => _GatepassFormState();
}

class _GatepassFormState extends State<_GatepassForm> {
  final _formKey = GlobalKey<FormState>();
  GatepassType? _selectedType;
  String _referenceType = 'SALES_ORDER';
  int? _referenceId;
  int? _partyId;
  String _priority = 'NORMAL';
  int? _vehicleId;
  String _vehicleNumber = '';
  String _vehicleType = '';
  String _driverName = '';
  String _driverPhone = '';
  String _driverLicense = '';
  DateTime? _validFrom;
  DateTime? _validTo;
  int? _entryGateId;
  int? _exitGateId;
  String _originLocation = '';
  String _destinationLocation = '';
  final List<_GatepassItemForm> _items = [];

  @override
  void initState() {
    super.initState();
    _items.add(_GatepassItemForm(inventoryService: widget.inventoryService));
  }

  void _addItem() => setState(() => _items.add(_GatepassItemForm(inventoryService: widget.inventoryService)));
  void _removeItem(int index) => setState(() => _items.removeAt(index));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final gatepass = Gatepass(
      gatepassNumber: 'GP-${DateTime.now().millisecondsSinceEpoch}',
      gatepassTypeId: _selectedType!.id!,
      referenceType: _referenceType,
      referenceId: _referenceId,
      partyId: _partyId,
      priority: _priority,
      vehicleNumber: _vehicleNumber,
      vehicleType: _vehicleType,
      driverName: _driverName,
      driverPhone: _driverPhone,
      driverLicense: _driverLicense,
      requestedDate: DateTime.now().millisecondsSinceEpoch,
      validFrom: _validFrom?.millisecondsSinceEpoch,
      validTo: _validTo?.millisecondsSinceEpoch,
      entryGateId: _entryGateId,
      exitGateId: _exitGateId,
      originLocation: _originLocation,
      destinationLocation: _destinationLocation,
      totalItems: _items.length,
      totalQuantity: _items.fold(0, (sum, i) => sum + i.quantity),
      totalWeight: _items.fold(0, (sum, i) => sum + (i.totalWeight ?? 0)),
      totalPackages: _items.fold(0, (sum, i) => sum + i.packages),
      createdBy: 1,
    );

    final gatepassId = await widget.gatepassService.createGatepass(gatepass);

    for (var itemForm in _items) {
      if (itemForm.itemId != null) {
        await widget.gatepassService.addGatepassItem(GatepassItem(
          gatepassId: gatepassId,
          itemId: itemForm.itemId,
          description: itemForm.description,
          quantity: itemForm.quantity,
          unit: itemForm.unit,
          weightPerUnit: itemForm.weightPerUnit,
          totalWeight: itemForm.totalWeight,
          packages: itemForm.packages,
          packageType: itemForm.packageType,
        ));
      }
    }

    widget.onSaved();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gatepass created: ${gatepass.gatepassNumber}')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _items.clear();
        _items.add(_GatepassItemForm(inventoryService: widget.inventoryService));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create New Gatepass', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<GatepassType>(
            value: _selectedType,
            decoration: const InputDecoration(labelText: 'Gatepass Type *', border: OutlineInputBorder()),
            items: widget.gatepassTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
            onChanged: (v) => setState(() => _selectedType = v),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _referenceType,
            decoration: const InputDecoration(labelText: 'Reference Type', border: OutlineInputBorder()),
            items: ['SALES_ORDER', 'PURCHASE_ORDER', 'TRANSFER', 'RETURN', 'SCRAP', 'OTHER']
                .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _referenceType = v!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Reference ID', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            onChanged: (v) => _referenceId = int.tryParse(v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _priority,
            decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
            items: ['LOW', 'NORMAL', 'HIGH', 'URGENT'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _priority = v!),
          ),
          const SizedBox(height: 24),
          const Text('Vehicle Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Vehicle Number *', border: OutlineInputBorder()),
            onChanged: (v) => _vehicleNumber = v,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Vehicle Type', border: OutlineInputBorder()),
            onChanged: (v) => _vehicleType = v,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Driver Name *', border: OutlineInputBorder()),
            onChanged: (v) => _driverName = v,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Driver Phone', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
            onChanged: (v) => _driverPhone = v,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Driver License', border: OutlineInputBorder()),
            onChanged: (v) => _driverLicense = v,
          ),
          const SizedBox(height: 24),
          const Text('Validity & Locations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Valid From', border: OutlineInputBorder()),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (date != null) setState(() => _validFrom = date);
                  },
                  controller: TextEditingController(text: _validFrom != null ? DateFormat('yyyy-MM-dd').format(_validFrom!) : ''),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Valid To', border: OutlineInputBorder()),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (date != null) setState(() => _validTo = date);
                  },
                  controller: TextEditingController(text: _validTo != null ? DateFormat('yyyy-MM-dd').format(_validTo!) : ''),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Origin Location', border: OutlineInputBorder()),
            onChanged: (v) => _originLocation = v,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Destination Location', border: OutlineInputBorder()),
            onChanged: (v) => _destinationLocation = v,
          ),
          const SizedBox(height: 24),
          const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._items.asMap().entries.map((entry) {
            int index = entry.key;
            var itemForm = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Item ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600))),
                        if (_items.length > 1)
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removeItem(index)),
                      ],
                    ),
                    itemForm.buildForm(),
                  ],
                ),
              ),
            );
          }),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            onPressed: _addItem,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Create Gatepass'),
              onPressed: _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GatepassItemForm {
  final InventoryService inventoryService;
  int? itemId;
  String description = '';
  double quantity = 0;
  String unit = 'PCS';
  double? weightPerUnit;
  double? totalWeight;
  int packages = 1;
  String? packageType;

  _GatepassItemForm({required this.inventoryService});

  Widget buildForm() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Description / SKU', border: OutlineInputBorder()),
          onChanged: (v) => description = v,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (v) => quantity = double.tryParse(v) ?? 0,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                onChanged: (v) => unit = v,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Weight/Unit (kg)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (v) => weightPerUnit = double.tryParse(v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Packages', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (v) => packages = int.tryParse(v) ?? 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Package Type', border: OutlineInputBorder()),
          onChanged: (v) => packageType = v,
        ),
      ],
    );
  }
}

class _DispatchScheduleTab extends StatefulWidget {
  final GatepassBarcodeService gatepassService;

  const _DispatchScheduleTab({required this.gatepassService});

  @override
  State<_DispatchScheduleTab> createState() => _DispatchScheduleTabState();
}

class _DispatchScheduleTabState extends State<_DispatchScheduleTab> {
  List<DispatchSchedule> _schedules = [];
  List<LoadingBay> _loadingBays = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final today = DateTime.now().millisecondsSinceEpoch;
    final schedules = await widget.gatepassService.getDispatchSchedules(date: today);
    final bays = await widget.gatepassService.getLoadingBays();
    setState(() {
      _schedules = schedules;
      _loadingBays = bays;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Today\'s Dispatch Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Schedule Dispatch'),
                      onPressed: _showScheduleDialog,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    final s = _schedules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(s.status).withOpacity(0.2),
                          child: Icon(Icons.schedule, color: _getStatusColor(s.status)),
                        ),
                        title: Text(s.scheduleNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gatepass: ${s.gatepassId ?? 'N/A'} | Bay: ${s.loadingBayId ?? 'N/A'}'),
                            Text('${DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(s.scheduledStart ?? 0))} - ${DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(s.scheduledEnd ?? 0))}'),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(s.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: _getStatusColor(s.status),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Dispatch Schedule'),
        content: const Text('Dispatch scheduling form would go here'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Create')),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green;
      case 'IN_PROGRESS': return Colors.blue;
      case 'SCHEDULED': return Colors.orange;
      case 'DELAYED': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class _GatepassDetailSheet extends StatelessWidget {
  final Gatepass gatepass;
  final GatepassBarcodeService gatepassService;
  final ScrollController scrollController;

  const _GatepassDetailSheet({
    required this.gatepass,
    required this.gatepassService,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(gatepass.gatepassNumber, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Chip(label: Text(gatepass.status), backgroundColor: _getStatusColor(gatepass.status)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                _buildDetailRow('Type', 'N/A'),
                _buildDetailRow('Vehicle', gatepass.vehicleNumber ?? 'N/A'),
                _buildDetailRow('Driver', gatepass.driverName ?? 'N/A'),
                _buildDetailRow('Driver Phone', gatepass.driverPhone ?? 'N/A'),
                _buildDetailRow('Status', gatepass.status),
                _buildDetailRow('Priority', gatepass.priority),
                _buildDetailRow('Requested', DateFormat('MMM dd, yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(gatepass.requestedDate ?? 0))),
                if (gatepass.validFrom != null)
                  _buildDetailRow('Valid From', DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(gatepass.validFrom!))),
                if (gatepass.validTo != null)
                  _buildDetailRow('Valid To', DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(gatepass.validTo!))),
                if (gatepass.actualEntryTime != null)
                  _buildDetailRow('Entry Time', DateFormat('MMM dd, yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(gatepass.actualEntryTime!))),
                if (gatepass.actualExitTime != null)
                  _buildDetailRow('Exit Time', DateFormat('MMM dd, yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(gatepass.actualExitTime!))),
                _buildDetailRow('Origin', gatepass.originLocation),
                _buildDetailRow('Destination', gatepass.destinationLocation),
                _buildDetailRow('Total Items', gatepass.totalItems.toString()),
                _buildDetailRow('Total Quantity', gatepass.totalQuantity.toString()),
                _buildDetailRow('Total Weight', '${gatepass.totalWeight?.toStringAsFixed(1) ?? '0'} kg'),
                _buildDetailRow('Total Packages', gatepass.totalPackages.toString()),
                const Divider(),
                const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
                FutureBuilder<List<GatepassItem>>(
                  future: gatepassService.getGatepassItems(gatepass.id!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    return Column(
                      children: snapshot.data!.map((item) => ListTile(
                        title: Text(item.description ?? 'Item ${item.itemId}'),
                        subtitle: Text('Qty: ${item.quantity} ${item.unit} | Weight: ${item.totalWeight?.toStringAsFixed(1) ?? '0'} kg | Packages: ${item.packages}'),
                        trailing: Chip(
                          label: Text(item.verificationStatus, style: const TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: _getVerificationColor(item.verificationStatus),
                        ),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green;
      case 'ACTIVE': return Colors.blue;
      case 'APPROVED': return Colors.purple;
      case 'SUBMITTED': return Colors.orange;
      case 'REJECTED': return Colors.red;
      case 'CANCELLED': return Colors.grey;
      default: return Colors.grey;
    }
  }

  Color _getVerificationColor(String status) {
    switch (status) {
      case 'VERIFIED': return Colors.green;
      case 'SHORT': return Colors.orange;
      case 'EXCESS': return Colors.red;
      case 'DAMAGED': return Colors.red;
      default: return Colors.grey;
    }
  }
}