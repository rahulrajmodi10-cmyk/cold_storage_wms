// lib/screens/logistics_dashboard.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/logistics_service.dart';
import '../models/logistics_models.dart';

class LogisticsDashboard extends StatefulWidget {
  final LogisticsService logisticsService;

  const LogisticsDashboard({super.key, required this.logisticsService});

  @override
  State<LogisticsDashboard> createState() => _LogisticsDashboardState();
}

class _LogisticsDashboardState extends State<LogisticsDashboard> {
  Map<String, dynamic>? _shipmentSummary;
  List<Map<String, dynamic>> _carrierPerformance = [];
  List<Map<String, dynamic>> _vehicleUtilization = [];
  List<Vehicle> _vehicles = [];
  List<Shipment> _activeShipments = [];
  bool _loading = true;
  int _selectedPeriod = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    int fromDate, toDate;

    switch (_selectedPeriod) {
      case 0:
        fromDate = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
        toDate = now.millisecondsSinceEpoch;
        break;
      case 1:
        fromDate = DateTime(now.year, now.month - 1, 1).millisecondsSinceEpoch;
        toDate = DateTime(now.year, now.month, 0).millisecondsSinceEpoch;
        break;
      case 2:
        int quarterStart = ((now.month - 1) ~/ 3) * 3 + 1;
        fromDate = DateTime(now.year, quarterStart, 1).millisecondsSinceEpoch;
        toDate = now.millisecondsSinceEpoch;
        break;
      case 3:
        fromDate = DateTime(now.year, 1, 1).millisecondsSinceEpoch;
        toDate = now.millisecondsSinceEpoch;
        break;
      default:
        fromDate = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
        toDate = now.millisecondsSinceEpoch;
    }

    final results = await Future.wait([
      widget.logisticsService.getShipmentSummary(fromDate, toDate),
      widget.logisticsService.getCarrierPerformance(fromDate, toDate),
      widget.logisticsService.getVehicleUtilization(fromDate, toDate),
      widget.logisticsService.getVehicles(),
      widget.logisticsService.getShipments(status: 'IN_TRANSIT', limit: 10),
    ]);

    setState(() {
      _shipmentSummary = results[0] as Map<String, dynamic>;
      _carrierPerformance = results[1] as List<Map<String, dynamic>>;
      _vehicleUtilization = results[2] as List<Map<String, dynamic>>;
      _vehicles = results[3] as List<Vehicle>;
      _activeShipments = results[4] as List<Shipment>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logistics Dashboard'),
        actions: [
          DropdownButton<int>(
            value: _selectedPeriod,
            underline: Container(),
            items: const [
              DropdownMenuItem(value: 0, child: Text('This Month')),
              DropdownMenuItem(value: 1, child: Text('Last Month')),
              DropdownMenuItem(value: 2, child: Text('This Quarter')),
              DropdownMenuItem(value: 3, child: Text('This Year')),
            ],
            onChanged: (value) {
              setState(() => _selectedPeriod = value!);
              _loadData();
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShipmentSummary(),
                    const SizedBox(height: 16),
                    _buildActiveShipments(),
                    const SizedBox(height: 16),
                    _buildVehicleStatus(),
                    const SizedBox(height: 16),
                    _buildCarrierPerformance(),
                    const SizedBox(height: 16),
                    _buildVehicleUtilization(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildShipmentSummary() {
    final total = _shipmentSummary?['total_shipments'] as int? ?? 0;
    final delivered = _shipmentSummary?['delivered'] as int? ?? 0;
    final cancelled = _shipmentSummary?['cancelled'] as int? ?? 0;
    final inProgress = _shipmentSummary?['in_progress'] as int? ?? 0;
    final totalWeight = _shipmentSummary?['total_weight'] as double? ?? 0;
    final totalVolume = _shipmentSummary?['total_volume'] as double? ?? 0;
    final totalFreight = _shipmentSummary?['total_freight'] as double? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shipment Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Total', total.toString(), Icons.local_shipping, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Delivered', delivered.toString(), Icons.check_circle, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('In Transit', inProgress.toString(), Icons.directions_truck, Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Cancelled', cancelled.toString(), Icons.cancel, Colors.red)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Weight', '${totalWeight.toStringAsFixed(1)} kg', Icons.fitness_center, Colors.purple)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Total Volume', '${totalVolume.toStringAsFixed(1)} m³', Icons.crop_free, Colors.teal)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Total Freight', NumberFormat.currency(symbol: '₹').format(totalFreight), Icons.attach_money, Colors.green)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveShipments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Shipments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.list, size: 18),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_activeShipments.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No active shipments', style: TextStyle(color: Colors.grey)),
              ))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activeShipments.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final s = _activeShipments[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(s.status).withOpacity(0.2),
                      child: Icon(Icons.local_shipping, color: _getStatusColor(s.status)),
                    ),
                    title: Text(s.shipmentNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${s.originAddress} → ${s.destinationAddress}'),
                        Text('Vehicle: ${s.vehicleId ?? 'N/A'} | Driver: ${s.driverName ?? 'N/A'}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(s.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                      backgroundColor: _getStatusColor(s.status),
                    ),
                    onTap: () {},
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DELIVERED': return Colors.green;
      case 'IN_TRANSIT': return Colors.blue;
      case 'LOADED': return Colors.orange;
      case 'ARRIVED': return Colors.purple;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildVehicleStatus() {
    int available = _vehicles.where((v) => v.status == 'AVAILABLE').length;
    int inTransit = _vehicles.where((v) => v.status == 'IN_TRANSIT').length;
    int maintenance = _vehicles.where((v) => v.status == 'MAINTENANCE').length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vehicle Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildVehicleStatusItem('Available', available, Colors.green, Icons.check_circle)),
                Expanded(child: _buildVehicleStatusItem('In Transit', inTransit, Colors.blue, Icons.directions_truck)),
                Expanded(child: _buildVehicleStatusItem('Maintenance', maintenance, Colors.red, Icons.build)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleStatusItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
        const SizedBox(height: 8),
        Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildCarrierPerformance() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Carrier Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Carrier')),
                  DataColumn(label: Text('Shipments'), numeric: true),
                  DataColumn(label: Text('Delivered'), numeric: true),
                  DataColumn(label: Text('Cancelled'), numeric: true),
                  DataColumn(label: Text('Avg Transit (hrs)'), numeric: true),
                  DataColumn(label: Text('Freight'), numeric: true),
                ],
                rows: _carrierPerformance.map((c) => DataRow(cells: [
                  DataCell(Text(c['carrier_name'] as String? ?? '')),
                  DataCell(Text((c['total_shipments'] as int? ?? 0).toString())),
                  DataCell(Text((c['delivered'] as int? ?? 0).toString(), style: const TextStyle(color: Colors.green))),
                  DataCell(Text((c['cancelled'] as int? ?? 0).toString(), style: const TextStyle(color: Colors.red))),
                  DataCell(Text((c['avg_transit_hours'] as double? ?? 0).toStringAsFixed(1))),
                  DataCell(Text(NumberFormat.currency(symbol: '₹').format(c['total_freight'] as double? ?? 0))),
                ])).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleUtilization() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vehicle Utilization', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Vehicle')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Trips'), numeric: true),
                  DataColumn(label: Text('Weight'), numeric: true),
                  DataColumn(label: Text('Weight %'), numeric: true),
                  DataColumn(label: Text('Volume %'), numeric: true),
                ],
                rows: _vehicleUtilization.map((v) => DataRow(cells: [
                  DataCell(Text(v['registration_number'] as String? ?? '')),
                  DataCell(Text(v['vehicle_type'] as String? ?? '')),
                  DataCell(Text((v['trips'] as int? ?? 0).toString())),
                  DataCell(Text('${(v['total_weight'] as double? ?? 0).toStringAsFixed(1)} kg')),
                  DataCell(Text('${(v['avg_weight_utilization'] as double? ?? 0).toStringAsFixed(1)}%')),
                  DataCell(Text('${(v['avg_volume_utilization'] as double? ?? 0).toStringAsFixed(1)}%')),
                ])).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}