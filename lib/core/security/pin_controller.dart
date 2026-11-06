import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'backup_cipher.dart';

abstract class PinVault {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

class SecurePinVault implements PinVault {
  static const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: false),
  );
  final String key;
  const SecurePinVault({this.key = 'untungku-pin-v1'});
  @override
  Future<String?> read() => storage.read(key: key);
  @override
  Future<void> write(String value) => storage.write(key: key, value: value);
  @override
  Future<void> delete() => storage.delete(key: key);
}

class PinController extends ChangeNotifier {
  final PinVault vault;
  final DateTime Function() now;
  Map<String, dynamic>? _record;
  bool locked = true, busy = false;
  bool _changing = false;
  int _lockGeneration = 0;
  PinController(this.vault, {DateTime Function()? clock})
    : now = clock ?? DateTime.now;
  bool get enabled => _record != null;
  int get timeoutSeconds => _record?['timeout'] as int? ?? 60;
  Future<void> load() async {
    final source = await vault.read();
    if (source != null) {
      final r = jsonDecode(source) as Map<String, dynamic>;
      if (r['version'] != 1 ||
          base64Decode(r['salt']).length != 16 ||
          base64Decode(r['hash']).length != 32 ||
          ![30, 60, 300].contains(r['timeout']) ||
          r['failures'] is! int ||
          r['failures'] < 0 ||
          r['failures'] > 10 ||
          r['until'] is! int ||
          r['until'] < 0) {
        throw StateError(
          'Penyimpanan keamanan tidak dapat dibaca. Data tidak dihapus.',
        );
      }
      _record = r;
    }
    locked = enabled;
    notifyListeners();
  }

  void lock() {
    _lockGeneration++;
    if (enabled) {
      locked = true;
      notifyListeners();
    }
  }

  static void validatePin(String pin) {
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      throw ArgumentError('PIN harus 4–6 digit');
    }
  }

  Future<bool> verify(String pin) {
    if (_changing) throw StateError('Pengaturan PIN sedang berlangsung');
    return _verify(pin);
  }

  Future<bool> _verify(String pin) async {
    if (busy) throw StateError('Verifikasi sedang berlangsung');
    busy = true;
    try {
      if (_record == null) return true;
      final r = Map<String, dynamic>.of(_record!);
      if (now().millisecondsSinceEpoch < r['until']) {
        throw StateError(
          'Terlalu banyak percobaan. Tunggu sebelum mencoba lagi.',
        );
      }
      final salt = base64Decode(r['salt']), expected = base64Decode(r['hash']);
      final actual = await Isolate.run(() => passwordKey(pin, salt));
      var difference = actual.length ^ expected.length;
      for (var i = 0; i < expected.length; i++) {
        difference |= actual[i] ^ expected[i];
      }
      final valid = difference == 0;
      final failures = valid ? 0 : ((r['failures'] as int) + 1).clamp(0, 10);
      r['failures'] = failures;
      r['until'] = valid || failures < 5
          ? 0
          : now()
                .add(Duration(seconds: failures >= 10 ? 300 : 30))
                .millisecondsSinceEpoch;
      await vault.write(jsonEncode(r));
      _record = r;
      return valid;
    } finally {
      busy = false;
    }
  }

  Future<void> unlock(String pin) async {
    final generation = _lockGeneration;
    if (!await verify(pin)) throw ArgumentError('PIN salah');
    if (generation != _lockGeneration) {
      throw StateError('Aplikasi dikunci kembali. Masukkan PIN lagi.');
    }
    locked = false;
    notifyListeners();
  }

  Future<void> configure(
    String oldPin,
    String? newPin, {
    int timeout = 60,
  }) async {
    if (_changing || busy) {
      throw StateError('Pengaturan PIN sedang berlangsung');
    }
    _changing = true;
    final generation = _lockGeneration;
    try {
      if (!await _verify(oldPin)) throw ArgumentError('PIN lama salah');
      if (newPin == null) {
        await vault.delete();
        _record = null;
        locked = false;
      } else {
        validatePin(newPin);
        if (![30, 60, 300].contains(timeout)) {
          throw ArgumentError('Batas waktu tidak valid');
        }
        final salt = securityRandom(16);
        final hash = await Isolate.run(() => passwordKey(newPin, salt));
        final r = {
          'version': 1,
          'salt': base64Encode(salt),
          'hash': base64Encode(hash),
          'timeout': timeout,
          'failures': 0,
          'until': 0,
        };
        await vault.write(jsonEncode(r));
        _record = r;
        locked = generation != _lockGeneration;
      }
      notifyListeners();
    } finally {
      _changing = false;
    }
  }
}
