// lib/screens/barcode_scanner_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/gatepass_barcode_service.dart';
import '../models/gatepass_barcode_models.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final GatepassBarcodeService barcodeService;

  const BarcodeScannerScreen({super.key, required this.barcodeService});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BarcodeDefinition> _definitions = [];
  List<BatchScanSession> _batchSessions = [];
  List<LabelPrintJob> _printJobs = [];
  List<PrinterConfig> _printers = [];
  bool _loading = true;

  // Single scan
  String _lastScannedValue = '';
  BarcodeScan? _lastScanResult;
  String _scanType = 'RECEIVING';
  int? _scanLocationId;

  // Batch scan
  BatchScanSession? _activeBatchSession;
  List<BatchScanItem> _batchItems = [];
  String _batchSessionType = 'RECEIVING';
  int? _batchReferenceId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      widget.barcodeService.getBarcodeDefinitions(),
      widget.barcodeService.getBatchScanSessions(),
      widget.barcodeService.getLabelPrintJobs(),
      widget.barcodeService.getPrinterConfigs(),
    ]);
    setState(() {
      _definitions = results[0] as List<BarcodeDefinition>;
      _batchSessions = results[1] as List<BatchScanSession>;
      _printJobs = results[2] as List<LabelPrintJob>;
      _printers = results[3] as List<PrinterConfig>;
      _loading = false;
    });
  }

  Future<void> _simulateScan(String value) async {
    // In real app, this would use mobile_scanner or similar package
    final barcode = await widget.barcodeService.getBarcodeByValue(value);

    final scan = BarcodeScan(
      barcodeValue: value,
      barcodeId: barcode?.id,
      entityType: barcode?.entityType,
      entityId: barcode?.entityId,
      scanType: _scanType,
      locationId: _scanLocationId,
      scannedBy: 1,
      deviceId: 'mobile_scanner_001',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      status: barcode != null ? 'SUCCESS' : 'NOT_FOUND',
    );

    await widget.barcodeService.logBarcodeScan(scan);

    setState(() {
      _lastScannedValue = value;
      _lastScanResult = scan;
    });

    if (barcode != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned: ${barcode.entityType} - ${barcode.barcodeValue}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barcode not found in system'), backgroundColor: Colors.orange),
      );
    }
  }

  Future<void> _startBatchSession() async {
    final session = BatchScanSession(
      sessionNumber: 'BATCH-${DateTime.now().millisecondsSinceEpoch}',
      sessionType: _batchSessionType,
      referenceId: _batchReferenceId,
      locationId: _scanLocationId,
      operatorId: 1,
      totalExpected: 0, // Will be updated as items are added
    );

    final id = await widget.barcodeService.createBatchScanSession(session);
    final created = await widget.barcodeService.getBatchScanSession(id);
    setState(() => _activeBatchSession = created);
  }

  Future<void> _addToBatchScan(String value) async {
    if (_activeBatchSession == null) return;

    final barcode = await widget.barcodeService.getBarcodeByValue(value);
    final item = BatchScanItem(
      sessionId: _activeBatchSession!.id!,
      barcodeValue: value,
      barcodeId: barcode?.id,
      itemId: barcode?.entityId,
      expectedQuantity: 1,
      status: barcode != null ? 'SCANNED' : 'EXCEPTION',
      mismatchReason: barcode == null ? 'NOT_FOUND' : null,
      scannedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await widget.barcodeService.addBatchScanItem(item);

    setState(() {
      _batchItems.add(item);
      _activeBatchSession = BatchScanSession(
        id: _activeBatchSession!.id,
        sessionNumber: _activeBatchSession!.sessionNumber,
        sessionType: _activeBatchSession!.sessionType,
        referenceType: _activeBatchSession!.referenceType,
        referenceId: _activeBatchSession!.referenceId,
        locationId: _activeBatchSession!.locationId,
        operatorId: _activeBatchSession!.operatorId,
        status: _activeBatchSession!.status,
        totalExpected: _activeBatchSession!.totalExpected,
        totalScanned: _activeBatchSession!.totalScanned + 1,
        totalMatched: _activeBatchSession!.totalMatched + (barcode != null ? 1 : 0),
        totalMismatched: _activeBatchSession!.totalMismatched + (barcode == null ? 1 : 0),
        startedAt: _activeBatchSession!.startedAt,
        completedAt: _activeBatchSession!.completedAt,
        notes: _activeBatchSession!.notes,
      );
    });
  }

  Future<void> _completeBatchSession() async {
    if (_activeBatchSession == null) return;

    await widget.barcodeService.updateBatchScanSession(BatchScanSession(
      id: _activeBatchSession!.id,
      sessionNumber: _activeBatchSession!.sessionNumber,
      sessionType: _activeBatchSession!.sessionType,
      referenceType: _activeBatchSession!.referenceType,
      referenceId: _activeBatchSession!.referenceId,
      locationId: _activeBatchSession!.locationId,
      operatorId: _activeBatchSession!.operatorId,
      status: 'COMPLETED',
      totalExpected: _activeBatchSession!.totalExpected,
      totalScanned: _activeBatchSession!.totalScanned,
      totalMatched: _activeBatchSession!.totalMatched,
      totalMismatched: _activeBatchSession!.totalMismatched,
      startedAt: _activeBatchSession!.startedAt,
      completedAt: DateTime.now().millisecondsSinceEpoch,
      notes: _activeBatchSession!.notes,
    ));

    setState(() => _activeBatchSession = null);
    _batchItems.clear();
    _loadData();
  }

  Future<void> _createPrintJob() async {
    // Show dialog to select definition and entities
    showDialog(
      context: context,
      builder: (context) => _PrintJobDialog(
        barcodeService: widget.barcodeService,
        definitions: _definitions,
        printers: _printers,
        onCreated: _loadData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Scan', icon: Icon(Icons.qr_code_scanner)),
            Tab(text: 'Batch', icon: Icon(Icons.inventory_2)),
            Tab(text: 'Print Labels', icon: Icon(Icons.print)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSingleScanTab(),
                _buildBatchScanTab(),
                _buildPrintLabelsTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  Widget _buildSingleScanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scan Area
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('Scan Barcode / QR Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Camera Preview Area', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 8),
                          Text('Use mobile_scanner package', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Simulated scan input for demo
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Enter Barcode Value (Demo)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.input),
                    ),
                    onFieldSubmitted: _simulateScan,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _scanType,
                    decoration: const InputDecoration(labelText: 'Scan Type', border: OutlineInputBorder()),
                    items: ['RECEIVING', 'PICKING', 'PACKING', 'DISPATCH', 'TRANSFER', 'CYCLE_COUNT', 'GATEPASS_VERIFY']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _scanType = v!),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Last Scan Result
          if (_lastScanResult != null)
            Card(
              color: _lastScanResult!.status == 'SUCCESS' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _lastScanResult!.status == 'SUCCESS' ? Icons.check_circle : Icons.warning,
                          color: _lastScanResult!.status == 'SUCCESS' ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text('Last Scan Result', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Barcode', _lastScanResult!.barcodeValue),
                    _buildDetailRow('Status', _lastScanResult!.status),
                    if (_lastScanResult!.entityType != null)
                      _buildDetailRow('Entity Type', _lastScanResult!.entityType!),
                    if (_lastScanResult!.entityId != null)
                      _buildDetailRow('Entity ID', _lastScanResult!.entityId.toString()),
                    _buildDetailRow('Scan Type', _lastScanResult!.scanType ?? 'N/A'),
                    _buildDetailRow('Time', DateFormat('HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(_lastScanResult!.timestamp))),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Quick Actions
          const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton('Generate Barcode', Icons.add, () {}),
              _buildActionButton('Print Labels', Icons.print, _createPrintJob),
              _buildActionButton('View Definitions', Icons.list, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchScanTab() {
    return Column(
      children: [
        if (_activeBatchSession == null) ...[
          // Start new batch session
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start New Batch Scan Session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _batchSessionType,
                    decoration: const InputDecoration(labelText: 'Session Type', border: OutlineInputBorder()),
                    items: ['RECEIVING', 'DISPATCH', 'TRANSFER', 'INVENTORY', 'GATEPASS']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _batchSessionType = v!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Reference ID (Gatepass/Shipment ID)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _batchReferenceId = int.tryParse(v),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Batch Session'),
                      onPressed: _startBatchSession,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Active batch session
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.blue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Session: ${_activeBatchSession!.sessionNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Type: ${_activeBatchSession!.sessionType} | Scanned: ${_activeBatchSession!.totalScanned} | Matched: ${_activeBatchSession!.totalMatched} | Mismatched: ${_activeBatchSession!.totalMismatched}'),
                        ],
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Complete'),
                        onPressed: _completeBatchSession,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Scan input for batch
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Scan Barcode',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code_scanner),
                    ),
                    onFieldSubmitted: _addToBatchScan,
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  // Scanned items list
                  const Text('Scanned Items', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _batchItems.length,
                      itemBuilder: (context, index) {
                        final item = _batchItems[index];
                        return ListTile(
                          leading: Icon(
                            item.matched == 1 ? Icons.check_circle : Icons.error,
                            color: item.matched == 1 ? Colors.green : Colors.red,
                          ),
                          title: Text(item.barcodeValue ?? 'N/A'),
                          subtitle: Text('Expected: ${item.expectedQuantity} | Scanned: ${item.scannedQuantity}'),
                          trailing: Chip(
                            label: Text(item.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                            backgroundColor: item.matched == 1 ? Colors.green : Colors.red,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Past sessions
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Recent Batch Sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _batchSessions.length,
                    itemBuilder: (context, index) {
                      final s = _batchSessions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getBatchStatusColor(s.status).withOpacity(0.2),
                          child: Icon(Icons.inventory_2, color: _getBatchStatusColor(s.status)),
                        ),
                        title: Text(s.sessionNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${s.sessionType} | Scanned: ${s.totalScanned}/${s.totalExpected} | ${DateFormat('MMM dd, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(s.startedAt ?? 0))}'),
                        trailing: Chip(
                          label: Text(s.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: _getBatchStatusColor(s.status),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrintLabelsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Label Printing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New Print Job'),
                onPressed: _createPrintJob,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _printJobs.length,
            itemBuilder: (context, index) {
              final job = _printJobs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getPrintJobStatusColor(job.status).withOpacity(0.2),
                    child: Icon(Icons.print, color: _getPrintJobStatusColor(job.status)),
                  ),
                  title: Text(job.jobNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${job.entityType} | Copies: ${job.copies} | Printer: ${job.printerName ?? 'Default'}'),
                      Text('Printed: ${job.printedCount} | Failed: ${job.failedCount}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(job.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: _getPrintJobStatusColor(job.status),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            value: _scanType,
            decoration: const InputDecoration(labelText: 'Filter by Scan Type', border: OutlineInputBorder()),
            items: ['ALL', 'RECEIVING', 'PICKING', 'PACKING', 'DISPATCH', 'TRANSFER', 'CYCLE_COUNT', 'GATEPASS_VERIFY']
                .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _scanType = v!),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<BarcodeScan>>(
            future: widget.barcodeService.getBarcodeScans(
              scanType: _scanType == 'ALL' ? null : _scanType,
              fromDate: DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch,
              toDate: DateTime.now().millisecondsSinceEpoch,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final scans = snapshot.data!;
              return ListView.builder(
                itemCount: scans.length,
                itemBuilder: (context, index) {
                  final scan = scans[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scan.status == 'SUCCESS' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      child: Icon(Icons.qr_code, color: scan.status == 'SUCCESS' ? Colors.green : Colors.red),
                    ),
                    title: Text(scan.barcodeValue, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                    subtitle: Text('${scan.entityType ?? 'N/A'} | ${scan.scanType ?? 'N/A'} | ${DateFormat('MMM dd, HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(scan.timestamp))}'),
                    trailing: Chip(
                      label: Text(scan.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                      backgroundColor: scan.status == 'SUCCESS' ? Colors.green : Colors.red,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontFamily: 'monospace'))),
        ],
      ),
    );
  }

  Color _getBatchStatusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green;
      case 'IN_PROGRESS': return Colors.blue;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getPrintJobStatusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green;
      case 'PRINTING': return Colors.blue;
      case 'QUEUED': return Colors.orange;
      case 'FAILED': return Colors.red;
      case 'CANCELLED': return Colors.grey;
      default: return Colors.grey;
    }
  }
}

class _PrintJobDialog extends StatefulWidget {
  final GatepassBarcodeService barcodeService;
  final List<BarcodeDefinition> definitions;
  final List<PrinterConfig> printers;
  final VoidCallback onCreated;

  const _PrintJobDialog({
    required this.barcodeService,
    required this.definitions,
    required this.printers,
    required this.onCreated,
  });

  @override
  State<_PrintJobDialog> createState() => _PrintJobDialogState();
}

class _PrintJobDialogState extends State<_PrintJobDialog> {
  BarcodeDefinition? _selectedDefinition;
  String _entityType = 'ITEM';
  String _entityIds = '[]'; // JSON array
  int _copies = 1;
  PrinterConfig? _selectedPrinter;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Print Job'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<BarcodeDefinition>(
              value: _selectedDefinition,
              decoration: const InputDecoration(labelText: 'Label Template', border: OutlineInputBorder()),
              items: widget.definitions.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
              onChanged: (v) => setState(() => _selectedDefinition = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _entityType,
              decoration: const InputDecoration(labelText: 'Entity Type', border: OutlineInputBorder()),
              items: ['ITEM', 'GATEPASS', 'SHIPMENT', 'LOCATION', 'PALLET', 'BATCH', 'VEHICLE']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _entityType = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Entity IDs (JSON Array)',
                border: OutlineInputBorder(),
                hintText: '[1, 2, 3]',
              ),
              onChanged: (v) => _entityIds = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Copies', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              initialValue: '1',
              onChanged: (v) => _copies = int.tryParse(v) ?? 1,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PrinterConfig>(
              value: _selectedPrinter,
              decoration: const InputDecoration(labelText: 'Printer', border: OutlineInputBorder()),
              items: widget.printers.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
              onChanged: (v) => setState(() => _selectedPrinter = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (_selectedDefinition == null) return;
            await widget.barcodeService.createLabelPrintJob(LabelPrintJob(
              jobNumber: 'PRINT-${DateTime.now().millisecondsSinceEpoch}',
              barcodeDefinitionId: _selectedDefinition!.id!,
              entityType: _entityType,
              entityIds: _entityIds,
              copies: _copies,
              printerName: _selectedPrinter?.name,
              printerType: _selectedPrinter?.printerType,
              status: 'QUEUED',
              requestedBy: 1,
            ));
            widget.onCreated();
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}