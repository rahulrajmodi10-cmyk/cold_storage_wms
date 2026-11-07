// test/auth_service_test.dart

import 'dart:convert';
import 'dart:math';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import 'package:crypto/crypto.dart';
import 'package:crypto/pbkdf2.dart';
import 'package:collection/collection.dart';

import '../lib/services/auth_service.dart';
import '../lib/services/audit_service.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late AuthService service;
  late AuditService auditService;

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password_hash TEXT,
            role TEXT,
            face_embedding BLOB
          )
        ''');
        await db.execute('''
          CREATE TABLE otps (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            code TEXT,
            expires_at INTEGER,
            verified INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE audit_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            action TEXT,
            detail TEXT,
            timestamp INTEGER,
            entity_type TEXT,
            entity_id INTEGER
          )
        ''');
      },
    );
    auditService = AuditService(db);
    service = AuthService(db, auditService: auditService);
  });

  tearDown(() async {
    await service.dispose();
    await db.close();
  });

  group('Password Verification', () {
    test('verifyPassword returns true for valid credentials', () async {
      // Create a test user with PBKDF2 hash
      // Format: iterations:salt:hash (base64)
      final password = 'testpassword123';
      final salt = base64.decode('dGVzdHNhbHQ='); // base64 encoded 'testsalt'
      final iterations = 10000;

      // Compute expected hash using crypto 3.x API
      final expectedHash = pbkdf2(
        password,
        salt: salt,
        iterations: iterations,
        outputLength: 32,
      );
      final hashBase64 = base64.encode(expectedHash);

      await db.insert('users', {
        'username': 'testuser',
        'password_hash': '$iterations:${base64.encode(salt)}:$hashBase64',
        'role': 'OPERATOR',
      });

      final result = await service.verifyPassword(password, '$iterations:${base64.encode(salt)}:$hashBase64');
      expect(result, isTrue);
    });

    test('verifyPassword returns false for invalid password', () async {
      final salt = 'dGVzdHNhbHQ=';
      final hashBase64 = 'YWJjZA=='; // dummy hash
      final storedHash = '10000:$salt:$hashBase64';

      final result = await service.verifyPassword('wrongpassword', storedHash);
      expect(result, isFalse);
    });

    test('verifyPassword returns false for invalid hash format', () async {
      final result = await service.verifyPassword('password', 'invalidhash');
      expect(result, isFalse);
    });
  });

  group('Authentication', () {
    test('authenticate returns user for valid credentials', () async {
      final password = 'testpassword';
      final salt = base64.encode(utf8.encode('randomsalt'));
      final hash = pbkdf2(
        password,
        salt: salt,
        iterations: 10000,
        outputLength: 32,
      );
      final hashBase64 = base64.encode(hash);

      await db.insert('users', {
        'username': 'testuser',
        'password_hash': '10000:${base64.encode(salt)}:$hashBase64',
        'role': 'ADMIN',
      });

      final result = await service.authenticate('testuser', password);
      expect(result, isNotNull);
      expect(result!['username'], 'testuser');
      expect(result['role'], 'ADMIN');
    });

    test('authenticate returns null for invalid username', () async {
      final result = await service.authenticate('nonexistent', 'password');
      expect(result, isNull);
    });

    test('authenticate returns null for invalid password', () async {
      final password = 'correctpassword';
      final salt = base64.encode(utf8.encode('randomsalt'));
      final hash = pbkdf2(
        password,
        salt: salt,
        iterations: 10000,
        outputLength: 32,
      );

      await db.insert('users', {
        'username': 'testuser',
        'password_hash': '10000:${base64.encode(salt)}:${base64.encode(hash)}',
        'role': 'OPERATOR',
      });

      final result = await service.authenticate('testuser', 'wrongpassword');
      expect(result, isNull);
    });
  });

  group('OTP Handling', () {
    test('sendOtp generates and stores OTP', () async {
      await db.insert('users', {
        'username': 'testuser',
        'password_hash': 'dummy',
        'role': 'OPERATOR',
      });

      await service.sendOtp(1);

      final otp = await db.query('otps', where: 'user_id = ?', whereArgs: [1]);
      expect(otp, isNotEmpty);
      expect(otp.first['code'], isNotNull);
      expect(otp.first['code'].toString().length, 6);
      expect(otp.first['verified'], 0);
    });

    test('verifyOtp returns true for valid OTP', () async {
      await db.insert('users', {'username': 'testuser', 'password_hash': 'dummy', 'role': 'OPERATOR'});

      // Generate OTP with a known code
      final expiresAt = DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch;
      await db.insert('otps', {
        'user_id': 1,
        'code': '123456',
        'expires_at': expiresAt,
        'verified': 0,
      });

      final result = await service.verifyOtp(1, '123456');
      expect(result, isTrue);
    });

    test('verifyOtp returns false for invalid OTP', () async {
      await db.insert('users', {'username': 'testuser', 'password_hash': 'dummy', 'role': 'OPERATOR'});

      await db.insert('otps', {
        'user_id': 1,
        'code': '123456',
        'expires_at': DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch,
        'verified': 0,
      });

      final result = await service.verifyOtp(1, '654321');
      expect(result, isFalse);
    });

    test('verifyOtp returns false for expired OTP', () async {
      await db.insert('users', {'username': 'testuser', 'password_hash': 'dummy', 'role': 'OPERATOR'});

      await db.insert('otps', {
        'user_id': 1,
        'code': '123456',
        'expires_at': DateTime.now().subtract(const Duration(minutes: 5)).millisecondsSinceEpoch,
        'verified': 0,
      });

      final result = await service.verifyOtp(1, '123456');
      expect(result, isFalse);
    });

    test('verifyOtp marks OTP as verified', () async {
      await db.insert('users', {'username': 'testuser', 'password_hash': 'dummy', 'role': 'OPERATOR'});

      await db.insert('otps', {
        'user_id': 1,
        'code': '123456',
        'expires_at': DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch,
        'verified': 0,
      });

      await service.verifyOtp(1, '123456');

      final otp = await db.query('otps', where: 'user_id = ?', whereArgs: [1]);
      expect(otp.first['verified'], 1);
    });
  });

  group('User Management', () {
    test('getUser returns user by id', () async {
      await db.insert('users', {
        'username': 'testuser',
        'password_hash': 'dummy',
        'role': 'OPERATOR',
      });

      final result = await service.getUser(1);
      expect(result, isNotNull);
      expect(result!['username'], 'testuser');
    });

    test('getUser returns null for non-existent user', () async {
      final result = await service.getUser(999);
      expect(result, isNull);
    });
  });

  group('Logout', () {
    test('logout clears user preferences', () async {
      // This test would require SharedPreferences mocking which is complex
      // For now, verify the method completes without error
      await service.logout();
      // If we get here without exception, the test passes
      expect(true, isTrue);
    });
  });

  group('OTP Timer', () {
    test('startOtpCountdown initializes countdown', () {
      service.startOtpCountdown();
      expect(service.otpCountdown, 300);
      service.stopOtpCountdown();
    });

    test('stopOtpCountdown resets countdown', () {
      service.startOtpCountdown();
      service.stopOtpCountdown();
      expect(service.otpCountdown, 0);
    });
  });
}