// lib/screens/home_dashboard.dart

import 'package:flutter/material.dart';
import '../services/inventory_service.dart';
import '../services/location_service.dart';
import '../services/temperature_service.dart';
import '../services/finance_service.dart';
import '../services/logistics_service.dart';
import '../services/camera_ai_service.dart';
import '../services/gatepass_barcode_service.dart';
import '../services/receiving_service.dart';
import '../services/picking_service.dart';
import '../services/dispatch_service.dart';
import '../services/sla_service.dart';
import '../services/audit_service.dart';
import 'inventory_dashboard.dart';
import 'finance_dashboard.dart';
import 'logistics_dashboard.dart';
import 'gatepass_screen.dart';
import 'barcode_scanner_screen.dart';
import 'camera_counting_screen.dart';
import 'parties_screen.dart';
import 'alerts_screen.dart';

class HomeDashboard extends StatefulWidget {
  final int userId;
  final String username;
  final String role;
  final InventoryService inventoryService;
  final LocationService locationService;
  final TemperatureService temperatureService;
  final FinanceService financeService;
  final LogisticsService logisticsService;
  final CameraAIService cameraService;
  final GatepassBarcodeService gatepassService;
  final ReceivingService receivingService;
  final PickingService pickingService;
  final DispatchService dispatchService;
  final SLAService slaService;
  final AuditService auditService;

  const HomeDashboard({
    Key? key,
    required this.userId,
    required this.username,
    required this.role,
    required this.inventoryService,
    required this.locationService,
    required this.temperatureService,
    required this.financeService,
    required this.logisticsService,
    required this.cameraService,
    required this.gatepassService,
    required this.receivingService,
    required this.pickingService,
    required this.dispatchService,
    required this.slaService,
    required this.auditService,
  }) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _currentIndex = 0;
  late Future<DashboardStats> _statsFuture;
  int _unreadAlerts = 0;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadDashboardStats();
    _loadUnreadAlerts();
  }

  Future<DashboardStats> _loadDashboardStats() async {
    // Inventory stats
    final inventoryItems = await widget.inventoryService.getAllItems();
    final totalItems = inventoryItems.length;
    final inStockItems = inventoryItems.where((i) => i.status == 'IN_STOCK').length;
    final expiringSoon = inventoryItems.where((i) {
      if (i.expiryDate == null) return false;
      final expiry = DateTime.fromMillisecondsSinceEpoch(i.expiryDate!);
      final now = DateTime.now();
      return expiry.difference(now).inDays <= 7 && expiry.isAfter(now);
    }).length;

    // Location stats
    final locations = await widget.locationService.getAllLocations();
    final fullLocations = locations.where((l) {
      if (l.capacity == null) return false;
      return l.currentUtilization != null && l.currentUtilization! >= l.capacity! * 0.85;
    }).length;

    // Finance stats
    int pendingInvoices = 0;
    try {
      final invoices = await widget.financeService.getAllInvoices();
      pendingInvoices = invoices.where((i) => i.status == 'DRAFT' || i.status == 'PENDING').length;
    } catch (_) {
      // Handle gracefully if finance module not initialized
    }

    // Gatepass stats
    int pendingGatepasses = 0;
    try {
      final gatepasses = await widget.gatepassService.getAllGatepasses();
      pendingGatepasses = gatepasses.where((g) => g.status == 'PENDING' || g.status == 'APPROVED').length;
    } catch (_) {
      // Handle gracefully
    }

    return DashboardStats(
      totalInventoryItems: totalItems,
      inStockItems: inStockItems,
      expiringSoon: expiringSoon,
      fullLocations: fullLocations,
      totalLocations: locations.length,
      pendingInvoices: pendingInvoices,
      pendingGatepasses: pendingGatepasses,
    );
  }

  Future<void> _loadUnreadAlerts() async {
    try {
      final alerts = await widget.auditService.getRecentAlerts(limit: 20);
      final unread = alerts.where((a) => a.acknowledged == 0).length;
      if (mounted) {
        setState(() {
          _unreadAlerts = unread;
        });
      }
    } catch (_) {
      // Handle gracefully
    }
  }

  void _navigateToScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required dynamic value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value is int
                          ? value.toString()
                          : value.toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color ?? Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertBadge() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_outlined),
        if (_unreadAlerts > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _unreadAlerts > 99 ? '99+' : _unreadAlerts.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cold Storage WMS'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Builder(
              builder: (context) => IconButton(
                icon: _buildAlertBadge(),
                onPressed: () {
                  _navigateToScreen(8);
                },
              ),
            ),
          ),
          CircleAvatar(
            child: Text(username[0].toUpperCase()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: _navigateToScreen,
            labelPlacement: NavigationRailLabelPlacement.all,
            minWidth: 100,
            minExtensionSize: 100,
            groupMargin: const EdgeInsets.symmetric(vertical: 8),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                label: Text('Inventory'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_balance_outlined),
                label: Text('Finance'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_shipping_outlined),
                label: Text('Logistics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.videocam_outlined),
                label: Text('AI Camera'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.badge_outlined),
                label: Text('Gatepass'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.qr_code_scanner_outlined),
                label: Text('Scanner'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                label: Text('Parties'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications),
                label: Text('Alerts'),
              ),
            ],
          ),
          // Main Content
          Expanded(
            child: _currentIndex == 0
                ? _buildDashboardContent()
                : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return FutureBuilder<DashboardStats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _statsFuture = _loadDashboardStats();
              _loadUnreadAlerts();
            });
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // Summary Cards Row
                GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSummaryCard(
                      title: 'Total Items',
                      value: stats.totalInventoryItems,
                      icon: Icons.inventory,
                      color: Colors.blue,
                      onTap: () => _navigateToScreen(1),
                    ),
                    _buildSummaryCard(
                      title: 'In Stock',
                      value: stats.inStockItems,
                      icon: Icons.check_circle,
                      color: Colors.green,
                      onTap: () => _navigateToScreen(1),
                    ),
                    _buildSummaryCard(
                      title: 'Expiring Soon',
                      value: stats.expiringSoon,
                      icon: Icons.warning,
                      color: Colors.orange,
                      onTap: () => _navigateToScreen(1),
                    ),
                    _buildSummaryCard(
                      title: 'Full Locations',
                      value: '${stats.fullLocations}/${stats.totalLocations}',
                      icon: Icons.storage,
                      color: Colors.red,
                      onTap: () {},
                    ),
                    _buildSummaryCard(
                      title: 'Pending Gatepasses',
                      value: stats.pendingGatepasses,
                      icon: Icons.drive_eta,
                      color: Colors.purple,
                      onTap: () => _navigateToScreen(8),
                    ),
                    _buildSummaryCard(
                      title: 'Pending Invoices',
                      value: stats.pendingInvoices,
                      icon: Icons.receipt_long,
                      color: Colors.indigo,
                      onTap: () => _navigateToScreen(2),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.9,
                  children: [
                    _buildQuickAction(
                      title: 'Scan Item',
                      icon: Icons.qr_code,
                      onTap: () => _navigateToScreen(6),
                      color: Colors.blue,
                    ),
                    _buildQuickAction(
                      title: 'Add Item',
                      icon: Icons.add_box,
                      onTap: () => _navigateToScreen(1),
                      color: Colors.green,
                    ),
                    _buildQuickAction(
                      title: 'Camera Count',
                      icon: Icons.videocam,
                      onTap: () => _navigateToScreen(4),
                      color: Colors.purple,
                    ),
                    _buildQuickAction(
                      title: 'Create Gatepass',
                      icon: Icons.drive_eta,
                      onTap: () => _navigateToScreen(5),
                      color: Colors.orange,
                    ),
                    _buildQuickAction(
                      title: 'Create Invoice',
                      icon: Icons.receipt,
                      onTap: () => _navigateToScreen(2),
                      color: Colors.indigo,
                    ),
                    _buildQuickAction(
                      title: 'Add Party',
                      icon: Icons.person_add,
                      onTap: () => _navigateToScreen(7),
                      color: Colors.teal,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    final screens = [
      const SizedBox.shrink(), // Dashboard - handled above
      InventoryDashboard(
        inventoryService: widget.inventoryService,
        locationService: widget.locationService,
      ),
      FinanceDashboard(financeService: widget.financeService),
      LogisticsDashboard(logisticsService: widget.logisticsService),
      CameraCountingScreen(
        cameraService: widget.cameraService,
        gatepassService: widget.gatepassService,
      ),
      GatepassScreen(
        gatepassService: widget.gatepassService,
        inventoryService: widget.inventoryService,
      ),
      BarcodeScannerScreen(
        barcodeService: widget.gatepassService,
      ),
      PartiesScreen(
        partyService: widget.financeService,
      ),
      AlertsScreen(
        auditService: widget.auditService,
      ),
    ];

    return screens[_currentIndex];
  }
}

class DashboardStats {
  final int totalInventoryItems;
  final int inStockItems;
  final int expiringSoon;
  final int fullLocations;
  final int totalLocations;
  final int pendingInvoices;
  final int pendingGatepasses;

  DashboardStats({
    required this.totalInventoryItems,
    required this.inStockItems,
    required this.expiringSoon,
    required this.fullLocations,
    required this.totalLocations,
    required this.pendingInvoices,
    required this.pendingGatepasses,
  });
}