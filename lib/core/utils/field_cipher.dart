import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

/// Provides field-level AES-256-CBC encryption and HMAC-SHA256 integrity verification.
///
/// Implements Encrypt-then-MAC over `IV || Ciphertext` to ensure confidentiality,
/// authenticity, and resistance against bit-flipping and timing attacks.
class FieldCipher {
  static const int _ivLength = 16;
  static const int _macLength = 32;

  /// Encrypts [plainText] using AES-256-CBC with a random IV and HMAC-SHA256 integrity trailer.
  ///
  /// [plainText] The plaintext string to encrypt.
  /// [keyBytes] Exactly 32 bytes of secure key material.
  static String encrypt(String plainText, Uint8List keyBytes) {
    if (keyBytes.length != 32) {
      throw ArgumentError('keyBytes must be exactly 32 bytes.');
    }
    final encKey = enc.Key(keyBytes);
    final iv = enc.IV.fromSecureRandom(_ivLength);
    final encrypter = enc.Encrypter(enc.AES(encKey, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final ivAndCiphertext = Uint8List(_ivLength + encrypted.bytes.length);
    ivAndCiphertext.setRange(0, _ivLength, iv.bytes);
    ivAndCiphertext.setRange(
      _ivLength,
      ivAndCiphertext.length,
      encrypted.bytes,
    );

    final hmac = Hmac(sha256, keyBytes);
    final macBytes = hmac.convert(ivAndCiphertext).bytes;

    final combined = Uint8List(_ivLength + _macLength + encrypted.bytes.length);
    combined.setRange(0, _ivLength, iv.bytes);
    combined.setRange(_ivLength, _ivLength + _macLength, macBytes);
    combined.setRange(_ivLength + _macLength, combined.length, encrypted.bytes);

    return base64Encode(combined);
  }

  /// Decrypts a Base64 payload produced by [encrypt], verifying the HMAC-SHA256 trailer first.
  ///
  /// [base64String] Base64-encoded encrypted payload with IV and HMAC.
  /// [keyBytes] Exactly 32 bytes of secure key material.
  static String decrypt(String base64String, Uint8List keyBytes) {
    if (keyBytes.length != 32) {
      throw ArgumentError('keyBytes must be exactly 32 bytes.');
    }
    final combined = base64Decode(base64String);
    if (combined.length < _ivLength + _macLength + 16) {
      throw const FormatException('Encrypted payload too short or malformed');
    }

    final ivBytes = combined.sublist(0, _ivLength);
    final macBytes = combined.sublist(_ivLength, _ivLength + _macLength);
    final cipherBytes = combined.sublist(_ivLength + _macLength);

    final ivAndCiphertext = Uint8List(_ivLength + cipherBytes.length);
    ivAndCiphertext.setRange(0, _ivLength, ivBytes);
    ivAndCiphertext.setRange(_ivLength, ivAndCiphertext.length, cipherBytes);

    final hmac = Hmac(sha256, keyBytes);
    final computedMac = hmac.convert(ivAndCiphertext).bytes;

    if (!_constantTimeEquals(macBytes, computedMac)) {
      throw const FormatException('HMAC integrity verification failed');
    }

    final encKey = enc.Key(keyBytes);
    final iv = enc.IV(ivBytes);
    final encrypted = enc.Encrypted(cipherBytes);
    final encrypter = enc.Encrypter(enc.AES(encKey, mode: enc.AESMode.cbc));

    try {
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw FormatException('Decryption failed: $e');
    }
  }

  /// Compares two byte sequences in constant time to prevent side-channel timing attacks.
  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}
