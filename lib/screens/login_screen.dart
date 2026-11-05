// lib/screens/login_screen.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
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
import 'inventory_dashboard.dart';
import 'finance_dashboard.dart';
import 'logistics_dashboard.dart';
import 'camera_counting_screen.dart';
import 'gatepass_screen.dart';
import 'barcode_scanner_screen.dart';

class LoginScreen extends StatefulWidget {
  final Database db;
  final AuthService? authService;

  const LoginScreen({
    super.key,
    required this.db,
    this.authService,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _showOtp = false;
  bool _rememberMe = false;
  String? _errorMessage;
  int _otpExpiresAt = 0;
  Timer? _otpTimer;
  int _otpCountdown = 0;

  late final InventoryService _inventoryService;
  late final LocationService _locationService;
  late final TemperatureService _temperatureService;
  late final FinanceService _financeService;
  late final LogisticsService _logisticsService;
  late final CameraAIService _cameraService;
  late final GatepassBarcodeService _gatepassService;
  late final ReceivingService _receivingService;
  late final PickingService _pickingService;
  late final DispatchService _dispatchService;
  late final SLAService _slaService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadSavedCredentials();
  }

  void _initializeServices() {
    _inventoryService = InventoryService(widget.db);
    _locationService = LocationService(widget.db);
    _temperatureService = TemperatureService(widget.db);
    _financeService = FinanceService(widget.db);
    _logisticsService = LogisticsService(widget.db);
    _cameraService = CameraAIService(widget.db);
    _gatepassService = GatepassBarcodeService(widget.db);
    _receivingService = ReceivingService(widget.db);
    _pickingService = PickingService(widget.db);
    _dispatchService = DispatchService(widget.db);
    _slaService = SLAService(widget.db);
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('saved_username');
    final savedPass = prefs.getString('saved_password');
    final remember = prefs.getBool('remember_me') ?? false;

    if (remember && savedUser != null && savedPass != null) {
      setState(() {
        _usernameController.text = savedUser;
        _passwordController.text = savedPass;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_username', _usernameController.text);
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      // Query user from database
      final maps = await widget.db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (maps.isEmpty) {
        throw Exception('Invalid username or password');
      }

      final user = maps.first;
      final storedHash = user['password_hash'] as String;
      final role = user['role'] as String;
      final userId = user['id'] as int;

      // Verify password (PBKDF2-HMAC-SHA256)
      final isValid = await _verifyPassword(password, storedHash);
      if (!isValid) {
        throw Exception('Invalid username or password');
      }

      // If face embedding exists, require face verification
      final hasFace = user['face_embedding'] != null;
      if (hasFace && !_showOtp) {
        // In a real app, trigger face recognition here
        // For now, fall back to OTP
        _sendOtp(userId);
        return;
      }

      // If OTP was sent, verify it
      if (_showOtp) {
        final otp = _otpController.text.trim();
        final otpMaps = await widget.db.query(
          'otps',
          where: 'user_id = ? AND code = ? AND expires_at > ? AND verified = 0',
          whereArgs: [userId, otp, DateTime.now().millisecondsSinceEpoch],
        );

        if (otpMaps.isEmpty) {
          throw Exception('Invalid or expired OTP');
        }

        // Mark OTP as verified
        await widget.db.update(
          'otps',
          {'verified': 1},
          where: 'id = ?',
          whereArgs: [otpMaps.first['id']],
        );
      }

      // Save credentials if remember me
      await _saveCredentials();

      // Save login session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('logged_in_user_id', userId);
      await prefs.setString('logged_in_username', username);
      await prefs.setString('logged_in_role', role);

      // Navigate to main app
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainAppShell(
              db: widget.db,
              userId: userId,
              username: username,
              role: role,
              inventoryService: _inventoryService,
              locationService: _locationService,
              temperatureService: _temperatureService,
              financeService: _financeService,
              logisticsService: _logisticsService,
              cameraService: _cameraService,
              gatepassService: _gatepassService,
              receivingService: _receivingService,
              pickingService: _pickingService,
              dispatchService: _dispatchService,
              slaService: _slaService,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<bool> _verifyPassword(String password, String storedHash) async {
    // PBKDF2-HMAC-SHA256 verification
    // Format: iterations:salt:hash (base64)
    final parts = storedHash.split(':');
    if (parts.length != 3) return false;

    final iterations = int.parse(parts[0]);
    final salt = base64.decode(parts[1]);
    final expectedHash = base64.decode(parts[2]);

    // Compute hash using the crypto package's pbkdf2 function
    final key = pbkdf2(
      Hmac(sha256, utf8.encode(password)),
      salt,
      iterations: iterations,
      keyLength: 32,
    );

    return const DeepCollectionEquality().equals(key, expectedHash);
  }

  Future<void> _sendOtp(int userId) async {
    // Generate 6-digit OTP
    final otp = (100000 + Random().nextInt(900000)).toString();
    final expiresAt = DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch;

    await widget.db.insert('otps', {
      'user_id': userId,
      'code': otp,
      'expires_at': expiresAt,
      'verified': 0,
    });

    // In production, send via SMS/Email
    // For demo, show in snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demo OTP: $otp (expires in 5 min)')),
      );
    }

    setState(() {
      _showOtp = true;
      _otpExpiresAt = expiresAt;
      _startOtpCountdown();
    });
  }

  void _startOtpCountdown() {
    _otpTimer?.cancel();
    _otpCountdown = 300; // 5 minutes
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _otpCountdown--;
        if (_otpCountdown <= 0) {
          timer.cancel();
          _showOtp = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _otpTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo / Title
                    Icon(
                      Icons.ac_unit,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cold Storage WMS',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Warehouse Management System',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 32),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Username
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // OTP Field (conditional)
                    if (_showOtp) ...[
                      TextFormField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          labelText: 'OTP Code',
                          prefixIcon: const Icon(Icons.security),
                          border: const OutlineInputBorder(),
                          helperText: _otpCountdown > 0
                              ? 'Expires in ${(_otpCountdown ~/ 60).toString().padLeft(2, '0')}:${(_otpCountdown % 60).toString().padLeft(2, '0')}'
                              : 'OTP expired',
                        ),
                        validator: (v) {
                          if (_showOtp && (v == null || v.trim().isEmpty)) {
                            return 'Please enter OTP';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Remember me
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v ?? false),
                        ),
                        const Text('Remember me'),
                        const Spacer(),
                        if (_showOtp)
                          TextButton(
                            onPressed: _sendOtp,
                            child: const Text('Resend OTP'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Login', style: TextStyle(fontSize: 16)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Demo credentials hint
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Demo Credentials',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Username: admin\nPassword: admin123',
                            style: TextStyle(color: Colors.blue[700]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Main App Shell with Bottom Navigation
class MainAppShell extends StatefulWidget {
  final Database db;
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

  const MainAppShell({
    super.key,
    required this.db,
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
  });

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Finance',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'Logistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.videocam_outlined),
            selectedIcon: Icon(Icons.videocam),
            label: 'AI Camera',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Gatepass',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Barcode',
          ),
        ],
      ),
    );
  }
}