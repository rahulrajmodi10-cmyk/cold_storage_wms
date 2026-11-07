// lib/services/auth_service.dart
// Authentication service with PBKDF2 password verification and OTP handling

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:crypto/pbkdf2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'audit_service.dart';

// Use DeepCollectionEquality for comparing byte arrays
final _listEquality = const DeepCollectionEquality();

class AuthService {
  final Database db;
  final AuditService auditService;
  Timer? _otpTimer;
  int _otpCountdown = 0;

  AuthService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db);

  Future<bool> verifyPassword(String password, String storedHash) async {
    // PBKDF2-HMAC-SHA256 verification
    // Format: iterations:salt:hash (base64)
    final parts = storedHash.split(':');
    if (parts.length != 3) return false;

    final iterations = int.parse(parts[0]);
    final salt = base64.decode(parts[1]);
    final expectedHash = base64.decode(parts[2]);

    // Compute hash using pbkdf2 from crypto 3.x
    // In crypto 3.x, pbkdf2 uses secretKey parameter
    final key = pbkdf2(
      password,
      salt: salt,
      iterations: iterations,
      outputLength: 32,
    );

    return _listEquality.equals(key, expectedHash);
  }

  Future<void> sendOtp(int userId) async {
    // Generate 6-digit OTP
    final otp = (100000 + Random().nextInt(900000)).toString();
    final expiresAt = DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch;

    await db.insert('otps', {
      'user_id': userId,
      'code': otp,
      'expires_at': expiresAt,
      'verified': 0,
    });

    // Log OTP sent
    await auditService.log(
      action: 'otp_sent',
      detail: 'OTP sent to user $userId',
      entityType: 'user',
      entityId: userId,
    );
  }

  Future<bool> verifyOtp(int userId, String otp) async {
    final otpMaps = await db.query(
      'otps',
      where: 'user_id = ? AND code = ? AND expires_at > ? AND verified = 0',
      whereArgs: [userId, otp, DateTime.now().millisecondsSinceEpoch],
    );

    if (otpMaps.isEmpty) return false;

    // Mark OTP as verified
    await db.update(
      'otps',
      {'verified': 1},
      where: 'id = ?',
      whereArgs: [otpMaps.first['id']],
    );

    await auditService.log(
      action: 'otp_verified',
      detail: 'OTP verified for user $userId',
      entityType: 'user',
      entityId: userId,
    );

    return true;
  }

  Future<Map<String, dynamic>?> getUser(int userId) async {
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<Map<String, dynamic>?> authenticate(String username, String password) async {
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isEmpty) return null;

    final user = maps.first;
    final isValid = await verifyPassword(password, user['password_hash'] as String);

    if (!isValid) return null;

    return {
      'id': user['id'] as int,
      'username': user['username'] as String,
      'role': user['role'] as String,
      'face_embedding': user['face_embedding'],
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_user_id');
    await prefs.remove('logged_in_username');
    await prefs.remove('logged_in_role');

    await auditService.log(
      action: 'logout',
      detail: 'User logged out',
      entityType: 'session',
      entityId: 0,
    );

    _otpTimer?.cancel();
    _otpTimer = null;
    _otpCountdown = 0;
  }

  int get otpCountdown => _otpCountdown;

  void startOtpCountdown() {
    _otpTimer?.cancel();
    _otpCountdown = 300;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _otpCountdown--;
      if (_otpCountdown <= 0) {
        timer.cancel();
      }
    });
  }

  void stopOtpCountdown() {
    _otpTimer?.cancel();
    _otpTimer = null;
    _otpCountdown = 0;
  }

  void dispose() {
    _otpTimer?.cancel();
  }
}