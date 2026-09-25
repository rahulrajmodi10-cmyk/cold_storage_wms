// lib/screens/finance_dashboard.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/finance_service.dart';
import '../models/finance_models.dart';

class FinanceDashboard extends StatefulWidget {
  final FinanceService financeService;

  const FinanceDashboard({super.key, required this.financeService});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  Map<String, double>? _trialBalance;
  Map<String, dynamic>? _profitLoss;
  Map<String, dynamic>? _balanceSheet;
  List<Map<String, dynamic>> _agedReceivables = [];
  List<Map<String, dynamic>> _agedPayables = [];
  bool _loading = true;
  int _selectedPeriod = 0; // 0: This Month, 1: Last Month, 2: This Quarter, 3: This Year

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
      case 0: // This Month
        fromDate = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
        toDate = now.millisecondsSinceEpoch;
        break;
      case 1: // Last Month
        fromDate = DateTime(now.year, now.month - 1, 1).millisecondsSinceEpoch;
        toDate = DateTime(now.year, now.month, 0).millisecondsSinceEpoch;
        break;
      case 2: // This Quarter
        int quarterStart = ((now.month - 1) ~/ 3) * 3 + 1;
        fromDate = DateTime(now.year, quarterStart, 1).millisecondsSinceEpoch;
        toDate = now.millisecondsSinceEpoch;
        break;
      case 3: // This Year
        fromDate = DateTime(now.year, 1, 1).millisecondsSinceEpoch;
        toDate = now.millisecondsSinceEpoch;
        break;
      default:
        fromDate = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
        toDate = now.millisecondsSinceEpoch;
    }

    final results = await Future.wait([
      widget.financeService.getTrialBalance(toDate),
      widget.financeService.getProfitLoss(fromDate, toDate),
      widget.financeService.getBalanceSheet(toDate),
      widget.financeService.getAgedReceivables(toDate),
      widget.financeService.getAgedPayables(toDate),
    ]);

    setState(() {
      _trialBalance = results[0] as Map<String, double>;
      _profitLoss = results[1] as Map<String, dynamic>;
      _balanceSheet = results[2] as Map<String, dynamic>;
      _agedReceivables = results[3] as List<Map<String, dynamic>>;
      _agedPayables = results[4] as List<Map<String, dynamic>>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Dashboard'),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
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
                    // P&L Summary Cards
                    _buildPLSummary(),
                    const SizedBox(height: 16),
                    // Balance Sheet Summary
                    _buildBalanceSheetSummary(),
                    const SizedBox(height: 16),
                    // Aged Receivables/Payables
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildAgedReceivables()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildAgedPayables()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Trial Balance
                    _buildTrialBalance(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPLSummary() {
    final revenue = _profitLoss?['revenue'] as double? ?? 0;
    final expenses = _profitLoss?['expenses'] as double? ?? 0;
    final netProfit = _profitLoss?['net_profit'] as double? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profit & Loss Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Revenue', revenue, Colors.green, Icons.trending_up)),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard('Expenses', expenses, Colors.red, Icons.trending_down)),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Net Profit',
                netProfit,
                netProfit >= 0 ? Colors.green : Colors.red,
                netProfit >= 0 ? Icons.check_circle : Icons.cancel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(symbol: '₹').format(value),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSheetSummary() {
    final totalAssets = _balanceSheet?['total_assets'] as double? ?? 0;
    final totalLiabilities = _balanceSheet?['total_liabilities'] as double? ?? 0;
    final totalEquity = _balanceSheet?['total_equity'] as double? ?? 0;
    final balanced = _balanceSheet?['balanced'] as bool? ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Balance Sheet Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Chip(
              label: Text(balanced ? 'Balanced' : 'Unbalanced', style: const TextStyle(color: Colors.white)),
              backgroundColor: balanced ? Colors.green : Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Total Assets', totalAssets, Colors.blue, Icons.account_balance)),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard('Total Liabilities', totalLiabilities, Colors.orange, Icons.warning)),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard('Total Equity', totalEquity, Colors.purple, Icons.people)),
          ],
        ),
      ],
    );
  }

  Widget _buildAgedReceivables() {
    Map<String, double> aging = {'NOT_DUE': 0, '0-30': 0, '31-60': 0, '61-90': 0, '90+': 0};
    for (var item in _agedReceivables) {
      aging[item['aging_bucket']] = (aging[item['aging_bucket']] ?? 0) + (item['outstanding_amount'] as num).toDouble();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aged Receivables', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...aging.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key),
                  Text(
                    NumberFormat.currency(symbol: '₹').format(e.value),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  NumberFormat.currency(symbol: '₹').format(aging.values.fold(0.0, (a, b) => a + b)),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgedPayables() {
    Map<String, double> aging = {'NOT_DUE': 0, '0-30': 0, '31-60': 0, '61-90': 0, '90+': 0};
    for (var item in _agedPayables) {
      aging[item['aging_bucket']] = (aging[item['aging_bucket']] ?? 0) + (item['outstanding_amount'] as num).toDouble();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aged Payables', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...aging.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key),
                  Text(
                    NumberFormat.currency(symbol: '₹').format(e.value),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  NumberFormat.currency(symbol: '₹').format(aging.values.fold(0.0, (a, b) => a + b)),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialBalance() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trial Balance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Account')),
                  DataColumn(label: Text('Debit'), numeric: true),
                  DataColumn(label: Text('Credit'), numeric: true),
                  DataColumn(label: Text('Balance'), numeric: true),
                ],
                rows: _trialBalance!.entries.map((e) {
                  // This is simplified - in reality you'd show debit/credit separately
                  double balance = e.value;
                  return DataRow(cells: [
                    DataCell(Text(e.key.split(' - ').last)),
                    DataCell(Text(balance > 0 ? NumberFormat.currency(symbol: '₹').format(balance) : '')),
                    DataCell(Text(balance < 0 ? NumberFormat.currency(symbol: '₹').format(-balance) : '')),
                    DataCell(Text(NumberFormat.currency(symbol: '₹').format(balance))),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}