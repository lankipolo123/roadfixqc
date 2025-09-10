// lib/services/totp_service.dart
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class TotpService {
  static const int _digits = 6;
  static const int _period = 30;

  /// Generate a random TOTP secret (Base32 encoded)
  static String generateSecret() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = Random.secure();
    const secretLength = 32; // 160 bits

    String secret = '';
    for (int i = 0; i < secretLength; i++) {
      secret += chars[random.nextInt(chars.length)];
    }
    return secret;
  }

  /// Generate TOTP URL for QR code
  static String generateTotpUrl({
    required String secret,
    required String accountName,
    required String issuer,
  }) {
    final encodedAccount = Uri.encodeComponent(accountName);
    final encodedIssuer = Uri.encodeComponent(issuer);
    final encodedSecret = Uri.encodeComponent(secret);

    return 'otpauth://totp/$encodedIssuer:$encodedAccount?secret=$encodedSecret&issuer=$encodedIssuer&digits=$_digits&period=$_period';
  }

  /// Generate current TOTP code
  static String generateCode(String secret) {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeStep = currentTime ~/ _period;

    return _generateTotpCode(secret, timeStep);
  }

  /// Verify TOTP code (allows for ±1 time window to account for clock skew)
  static bool verifyCode(String secret, String code) {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final currentTimeStep = currentTime ~/ _period;

    // Check current time step and ±1 for clock skew tolerance
    for (int i = -1; i <= 1; i++) {
      final timeStep = currentTimeStep + i;
      final expectedCode = _generateTotpCode(secret, timeStep);

      if (expectedCode == code) {
        return true;
      }
    }

    return false;
  }

  /// Generate TOTP code for specific time step
  static String _generateTotpCode(String secret, int timeStep) {
    // Decode Base32 secret
    final key = _base32Decode(secret);

    // Convert time step to 8-byte big-endian
    final timeBytes = ByteData(8);
    timeBytes.setUint64(0, timeStep, Endian.big);

    // HMAC-SHA1
    final hmac = Hmac(sha1, key);
    final hash = hmac.convert(timeBytes.buffer.asUint8List());

    // Dynamic truncation
    final offset = hash.bytes[hash.bytes.length - 1] & 0x0f;
    final truncatedHash = hash.bytes.sublist(offset, offset + 4);

    // Convert to 32-bit integer
    final code =
        (truncatedHash[0] & 0x7f) << 24 |
        (truncatedHash[1] & 0xff) << 16 |
        (truncatedHash[2] & 0xff) << 8 |
        (truncatedHash[3] & 0xff);

    // Get last 6 digits
    final result = code % pow(10, _digits);

    return result.toString().padLeft(_digits, '0');
  }

  /// Base32 decoder
  static Uint8List _base32Decode(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final cleanInput = input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');

    if (cleanInput.isEmpty) {
      throw ArgumentError('Invalid Base32 string');
    }

    final output = <int>[];
    int bits = 0;
    int value = 0;

    for (int i = 0; i < cleanInput.length; i++) {
      final char = cleanInput[i];
      final index = alphabet.indexOf(char);

      if (index == -1) {
        throw ArgumentError('Invalid Base32 character: $char');
      }

      value = (value << 5) | index;
      bits += 5;

      if (bits >= 8) {
        output.add((value >> (bits - 8)) & 0xff);
        bits -= 8;
      }
    }

    return Uint8List.fromList(output);
  }

  /// Generate a list of backup codes (for recovery)
  static List<String> generateBackupCodes() {
    final random = Random.secure();
    final codes = <String>[];

    for (int i = 0; i < 8; i++) {
      // Generate 8-digit backup codes
      final code = random.nextInt(100000000).toString().padLeft(8, '0');
      codes.add(code);
    }

    return codes;
  }
}
