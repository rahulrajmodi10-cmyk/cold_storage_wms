// lib/screens/alerts_screen.dart

import 'package:flutter/material.dart';
import '../services/audit_service.dart';

class AlertsScreen extends StatefulWidget {
  final AuditService auditService;

  const AlertsScreen({
    Key? key,
    required this.auditService,
  }) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late Future<List<AuditAlert>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    _alertsFuture = widget.auditService.getRecentAlerts(limit: 100);
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadAlerts();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<AuditAlert>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No alerts found'));
          }

          final alerts = snapshot.data!;

          if (alerts.isEmpty) {
            return const Center(child: Text('No alerts found'));
          }

          return ListView.separated(
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final isUnread = alert.acknowledged == 0;

              return ListTile(
                leading: Icon(
                  isUnread ? Icons.warning_amber_rounded : Icons.info,
                  color: isUnread ? Colors.orange : Colors.blue,
                ),
                title: Text(
                  alert.action.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(alert.detail),
                trailing: Text(
                  _formatTimestamp(alert.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: isUnread
                    ? () async {
                        await widget.auditService.markAlertAcknowledged(alert.id);
                        setState(() {
                          // Refresh will show as acknowledged
                        });
                      }
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}