import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/core/utils/field_cipher.dart';

void main() {
  group('FieldCipher', () {
    final key = Uint8List.fromList(List<int>.generate(32, (i) => i + 1));

    test('encrypts and decrypts round-trip correctly', () {
      const plainText = 'Sensitive user profile notes: 12345';
      final encrypted = FieldCipher.encrypt(plainText, key);

      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(plainText)));

      final decrypted = FieldCipher.decrypt(encrypted, key);
      expect(decrypted, equals(plainText));
    });

    test('fails decryption when HMAC trailer is tampered', () {
      const plainText = 'Secret data';
      final encrypted = FieldCipher.encrypt(plainText, key);
      final rawBytes = base64Decode(encrypted);

      // Mutate one byte in the ciphertext payload
      rawBytes[rawBytes.length - 1] ^= 0xFF;
      final tampered = base64Encode(rawBytes);

      expect(
        () => FieldCipher.decrypt(tampered, key),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when key length is not exactly 32 bytes', () {
      final invalidKey = Uint8List.fromList([1, 2, 3]);

      expect(
        () => FieldCipher.encrypt('test', invalidKey),
        throwsArgumentError,
      );
      expect(
        () => FieldCipher.decrypt('invalidPayload', invalidKey),
        throwsArgumentError,
      );
    });

    test('throws FormatException on truncated payload', () {
      final shortPayload = base64Encode([1, 2, 3]);

      expect(
        () => FieldCipher.decrypt(shortPayload, key),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
