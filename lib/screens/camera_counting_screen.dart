// lib/screens/camera_counting_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/camera_ai_service.dart';
import '../services/gatepass_barcode_service.dart';
import '../models/camera_ai_models.dart';
import '../models/gatepass_barcode_models.dart';

class CameraCountingScreen extends StatefulWidget {
  final CameraAIService cameraService;
  final GatepassBarcodeService gatepassService;

  const CameraCountingScreen({
    super.key,
    required this.cameraService,
    required this.gatepassService,
  });

  @override
  State<CameraCountingScreen> createState() => _CameraCountingScreenState();
}

class _CameraCountingScreenState extends State<CameraCountingScreen> {
  List<CameraDevice> _cameras = [];
  List<CountingSession> _sessions = [];
  CameraDevice? _selectedCamera;
  CountingSession? _activeSession;
  StreamSubscription<int>? _countSubscription;
  bool _loading = true;
  String _sessionType = 'LOADING';
  String? _referenceType;
  int? _referenceId;
  int? _expectedCount;
  int _currentCount = 0;
  Map<String, dynamic> _sessionStats = {};

  @override
  void initState() {
    super.initState();
    _loadCameras();
    _loadSessions();
  }

  @override
  void dispose() {
    _countSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCameras() async {
    final cameras = await widget.cameraService.getCameras();
    setState(() => _cameras = cameras);
  }

  Future<void> _loadSessions() async {
    final sessions = await widget.cameraService.getCountingSessions();
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  Future<void> _startSession() async {
    if (_selectedCamera == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a camera')),
      );
      return;
    }

    final session = await widget.cameraService.startCountingSession(
      camera: _selectedCamera!,
      sessionType: _sessionType,
      referenceType: _referenceType,
      referenceId: _referenceId,
      expectedCount: _expectedCount,
      operatorId: 1, // Current user ID
    );

    setState(() {
      _activeSession = session;
      _currentCount = 0;
    });

    _subscribeToCountStream(session.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Started session: ${session.sessionNumber}')),
    );
  }

  void _subscribeToCountStream(int sessionId) {
    _countSubscription?.cancel();
    _countSubscription = widget.cameraService.getCountStream(sessionId).listen(
      (count) {
        setState(() => _currentCount = count);
      },
      onError: (error) {
        print('Count stream error: $error');
      },
    );
  }

  Future<void> _completeSession() async {
    if (_activeSession == null) return;

    final verifiedCount = await _showVerificationDialog();
    if (verifiedCount != null) {
      await widget.cameraService.completeCountingSession(
        _activeSession!.id!,
        verifiedCount: verifiedCount,
        verifiedBy: 1, // Current user ID
      );
      setState(() => _activeSession = null);
      _countSubscription?.cancel();
      _loadSessions();
    }
  }

  Future<int?> _showVerificationDialog() async {
    final controller = TextEditingController(text: _currentCount.toString());
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Count'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AI Count: $_currentCount'),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Verified Count'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSessionStats(int sessionId) async {
    final stats = await widget.cameraService.getSessionStats(sessionId);
    setState(() => _sessionStats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Camera Counting'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSessions),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Camera Selection & Session Config
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('New Counting Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<CameraDevice>(
                          value: _selectedCamera,
                          decoration: const InputDecoration(labelText: 'Camera'),
                          items: _cameras.map((c) => DropdownMenuItem(
                            value: c,
                            child: Text('${c.name} (${c.code})'),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedCamera = v),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _sessionType,
                          decoration: const InputDecoration(labelText: 'Session Type'),
                          items: ['LOADING', 'UNLOADING', 'TRANSFER', 'CYCLE_COUNT']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) => setState(() => _sessionType = v!),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _referenceType,
                                decoration: const InputDecoration(labelText: 'Reference Type'),
                                items: ['GATEPASS', 'SHIPMENT', 'RECEIVING', 'INVENTORY_CHECK']
                                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                    .toList(),
                                onChanged: (v) => setState(() => _referenceType = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'Reference ID'),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => _referenceId = int.tryParse(v),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Expected Count (optional)'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _expectedCount = int.tryParse(v),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Counting Session'),
                            onPressed: _activeSession == null ? _startSession : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Active Session Display
                if (_activeSession != null) ...[
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
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
                                  Text('Session: ${_activeSession!.sessionNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Type: ${_activeSession!.sessionType} | Camera: ${_selectedCamera?.name ?? 'N/A'}'),
                                  if (_activeSession!.expectedCount != null)
                                    Text('Expected: ${_activeSession!.expectedCount}'),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$_currentCount',
                                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                  const Text('AI Count', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check),
                                  label: const Text('Complete & Verify'),
                                  onPressed: _completeSession,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Cancel Session'),
                                  onPressed: () {
                                    setState(() {
                                      _activeSession = null;
                                      _countSubscription?.cancel();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Session History
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Recent Sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _sessions.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final s = _sessions[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(s.status).withOpacity(0.2),
                                  child: Icon(_getSessionIcon(s.sessionType), color: _getStatusColor(s.status)),
                                ),
                                title: Text(s.sessionNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${s.sessionType} | ${DateFormat('MMM dd, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(s.startTime ?? 0))}'),
                                    Text('AI: ${s.aiCount} | Verified: ${s.verifiedCount ?? 'N/A'} | Discrepancy: ${s.discrepancy}'),
                                  ],
                                ),
                                trailing: Chip(
                                  label: Text(s.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                                  backgroundColor: _getStatusColor(s.status),
                                ),
                                onTap: () => _loadSessionStats(s.id!),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'VERIFIED': return Colors.green;
      case 'COMPLETED': return Colors.blue;
      case 'DISPUTED': return Colors.orange;
      case 'IN_PROGRESS': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getSessionIcon(String type) {
    switch (type) {
      case 'LOADING': return Icons.upload;
      case 'UNLOADING': return Icons.download;
      case 'TRANSFER': return Icons.swap_horiz;
      default: return Icons.inventory;
    }
  }
}

class CameraCalibrationScreen extends StatefulWidget {
  final CameraAIService cameraService;

  const CameraCalibrationScreen({super.key, required this.cameraService});

  @override
  State<CameraCalibrationScreen> createState() => _CameraCalibrationScreenState();
}

class _CameraCalibrationScreenState extends State<CameraCalibrationScreen> {
  List<CameraDevice> _cameras = [];
  CameraDevice? _selectedCamera;
  List<CameraCalibration> _calibrations = [];
  String _calibrationType = 'COUNT_LINE';
  String _referenceObject = '';
  double _referenceSize = 0;
  double _pixelMeasurement = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  Future<void> _loadCameras() async {
    final cameras = await widget.cameraService.getCameras();
    setState(() {
      _cameras = cameras;
      _loading = false;
    });
  }

  Future<void> _loadCalibrations() async {
    if (_selectedCamera == null) return;
    final cals = await widget.cameraService.getCalibrations(_selectedCamera!.id!);
    setState(() => _calibrations = cals);
  }

  Future<void> _saveCalibration() async {
    if (_selectedCamera == null) return;

    final factor = _referenceSize / _pixelMeasurement;

    await widget.cameraService.createCalibration(CameraCalibration(
      cameraId: _selectedCamera!.id!,
      calibrationType: _calibrationType,
      referenceObject: _referenceObject,
      referenceSize: _referenceSize,
      pixelMeasurement: _pixelMeasurement,
      calibrationFactor: factor,
      accuracyPercent: 95.0, // Would calculate from multiple measurements
      calibratedBy: 1,
    ));

    _loadCalibrations();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calibration saved. Factor: ${factor.toStringAsFixed(4)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Calibration')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<CameraDevice>(
                    value: _selectedCamera,
                    decoration: const InputDecoration(labelText: 'Select Camera'),
                    items: _cameras.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.name} (${c.code})'),
                    )).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCamera = v;
                        _loadCalibrations();
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_selectedCamera != null) ...[
                    const Text('New Calibration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _calibrationType,
                      decoration: const InputDecoration(labelText: 'Calibration Type'),
                      items: ['DISTANCE', 'COUNT_LINE', 'ROI', 'LENS']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _calibrationType = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Reference Object (e.g., Standard Box, Pallet)'),
                      onChanged: (v) => _referenceObject = v,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Reference Size (meters)'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => _referenceSize = double.tryParse(v) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Pixel Measurement'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => _pixelMeasurement = double.tryParse(v) ?? 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save Calibration'),
                        onPressed: _referenceSize > 0 && _pixelMeasurement > 0 ? _saveCalibration : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Saved Calibrations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._calibrations.map((c) => ListTile(
                      title: Text('${c.calibrationType} - ${c.referenceObject}'),
                      subtitle: Text('Factor: ${c.calibrationFactor?.toStringAsFixed(4)} | Accuracy: ${c.accuracyPercent?.toStringAsFixed(1)}%'),
                      trailing: Text(DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(c.calibratedAt ?? 0))),
                    )),
                  ],
                ],
              ),
            ),
    );
  }
}