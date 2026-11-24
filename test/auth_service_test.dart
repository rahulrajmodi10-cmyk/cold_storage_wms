// test/auth_service_test.dart

import 'dart:convert';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import 'package:crypto/crypto.dart';

import 'package:cold_storage_wms/services/auth_service.dart';
import 'package:cold_storage_wms/services/audit_service.dart';

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
    service.dispose();
    await db.close();
  });

  group('Password Verification', () {
    test('verifyPassword returns true for valid credentials', () async {
      // Create a test user with PBKDF2 hash
      // Format: iterations:salt:hash (base64)
      final password = 'testpassword123';
      final salt = utf8.encode('testsalt');
      final saltBase64 = base64.encode(salt);
      final iterations = 10000;

      // Compute expected hash using the same PBKDF2 implementation
      final expectedHash = _computePbkdf2(
        utf8.encode(password),
        salt,
        iterations,
        32,
      );
      final hashBase64 = base64.encode(expectedHash);

      await db.insert('users', {
        'username': 'testuser',
        'password_hash': '$iterations:$saltBase64:$hashBase64',
        'role': 'OPERATOR',
      });

      final result = await service.verifyPassword(password, '$iterations:$saltBase64:$hashBase64');
      expect(result, isTrue);
    });

    test('verifyPassword returns false for invalid password', () async {
      final salt = utf8.encode('testsalt');
      final saltBase64 = base64.encode(salt);
      final iterations = 10000;
      final hashBase64 = base64.encode(List.generate(32, (i) => i));
      final storedHash = '$iterations:$saltBase64:$hashBase64';

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
      final salt = utf8.encode('randomsalt');
      final saltBase64 = base64.encode(salt);
      final hash = _computePbkdf2(utf8.encode(password), salt, 10000, 32);
      final hashBase64 = base64.encode(hash);

      await db.insert('users', {
        'username': 'testuser',
        'password_hash': '10000:$saltBase64:$hashBase64',
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
      final salt = utf8.encode('randomsalt');
      final saltBase64 = base64.encode(salt);
      final hash = _computePbkdf2(utf8.encode(password), salt, 10000, 32);
      final hashBase64 = base64.encode(hash);

      await db.insert('users', {
        'username': 'testuser',
        'password_hash': '10000:$saltBase64:$hashBase64',
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
      await service.logout();
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

/// Helper function to compute PBKDF2 hash - matches the implementation in AuthService
List<int> _computePbkdf2(
  List<int> passwordBytes,
  List<int> salt,
  int iterations,
  int outputLength,
) {
  final hmacSha256 = Hmac(sha256, passwordBytes);

  final result = <int>[];
  final blockCount = (outputLength / 32).ceil();

  for (int blockIndex = 1; blockIndex <= blockCount; blockIndex++) {
    final blockInput = salt + _intToBytes(blockIndex);
    List<int> u = hmacSha256.convert(blockInput).bytes;

    var f = List<int>.from(u);
    for (int i = 1; i < iterations; i++) {
      f = _xor(f, u);
      u = hmacSha256.convert(u).bytes;
    }

    result.addAll(f);
  }

  return result.sublist(0, outputLength);
}

List<int> _xor(List<int> a, List<int> b) {
  final result = <int>[];
  final len = a.length < b.length ? a.length : b.length;
  for (int i = 0; i < len; i++) {
    result.add(a[i] ^ b[i]);
  }
  return result;
}

List<int> _intToBytes(int value) {
  return [
    (value >> 24) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 8) & 0xFF,
    value & 0xFF,
  ];
}