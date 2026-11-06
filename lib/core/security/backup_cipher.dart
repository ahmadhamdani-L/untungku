import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

const securityIterations = 600000;
List<int> securityRandom(int count) {
  final random = Random.secure();
  return List.generate(count, (_) => random.nextInt(256));
}

Future<List<int>> passwordKey(String password, List<int> salt) async =>
    (await Pbkdf2(
          macAlgorithm: Hmac.sha256(),
          iterations: securityIterations,
          bits: 256,
        ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt))
        .extractBytes();

/// Envelope v1 is separate from Store payload schema v3. All metadata is bounded.
class BackupCipher {
  static const aad = 'untungku-pro:backup:1:AES-256-GCM:PBKDF2-SHA256:600000';
  static Future<String> encrypt(String payload, String password) =>
      Isolate.run(() async {
        if (password.length < 12 || password.length > 256) {
          throw ArgumentError('Password backup harus 12–256 karakter');
        }
        if (utf8.encode(payload).length > 20000000) {
          throw const FormatException('Backup terlalu besar');
        }
        final salt = securityRandom(16), nonce = securityRandom(12);
        final box = await AesGcm.with256bits().encrypt(
          utf8.encode(payload),
          secretKey: SecretKey(await passwordKey(password, salt)),
          nonce: nonce,
          aad: utf8.encode(aad),
        );
        return jsonEncode({
          'format': 'untungku-encrypted',
          'envelopeVersion': 1,
          'kdf': 'PBKDF2-SHA256',
          'iterations': securityIterations,
          'cipher': 'AES-256-GCM',
          'salt': base64Encode(salt),
          'nonce': base64Encode(nonce),
          'ciphertext': base64Encode(box.cipherText),
          'tag': base64Encode(box.mac.bytes),
        });
      });
  static Future<String> decrypt(
    String source,
    String password,
  ) => Isolate.run(() async {
    try {
      if (source.length > 28000000 || password.length > 256) {
        throw const FormatException();
      }
      final j = jsonDecode(source) as Map<String, dynamic>;
      if (j['format'] != 'untungku-encrypted' ||
          j['envelopeVersion'] != 1 ||
          j['kdf'] != 'PBKDF2-SHA256' ||
          j['iterations'] != securityIterations ||
          j['cipher'] != 'AES-256-GCM') {
        throw const FormatException();
      }
      final salt = base64Decode(j['salt'] as String),
          nonce = base64Decode(j['nonce'] as String),
          tag = base64Decode(j['tag'] as String),
          data = base64Decode(j['ciphertext'] as String);
      if (salt.length != 16 ||
          nonce.length != 12 ||
          tag.length != 16 ||
          data.length > 20000000) {
        throw const FormatException();
      }
      final plain = await AesGcm.with256bits().decrypt(
        SecretBox(data, nonce: nonce, mac: Mac(tag)),
        secretKey: SecretKey(await passwordKey(password, salt)),
        aad: utf8.encode(aad),
      );
      return utf8.decode(plain);
    } catch (_) {
      throw const FormatException(
        'Password salah atau backup terenkripsi rusak/tidak didukung. Data belum diganti.',
      );
    }
  });
  static bool isEncrypted(String source) {
    try {
      if (source.length > 28000000) throw const FormatException();
      return (jsonDecode(source) as Map)['format'] == 'untungku-encrypted';
    } catch (_) {
      throw const FormatException('Format backup JSON tidak valid');
    }
  }
}
