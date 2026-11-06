import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/core/security/backup_cipher.dart';
import 'package:untungku_pro/core/security/pin_controller.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';

class MemoryVault implements PinVault {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async {
    value = v;
  }

  @override
  Future<void> delete() async {
    value = null;
  }
}

void main() {
  test(
    'AEAD roundtrip, randomness, wrong password and tamper do not replace data',
    () async {
      final db = AppDatabase(NativeDatabase.memory()),
          targetDb = AppDatabase(NativeDatabase.memory());
      final store = Store(db), target = Store(targetDb);
      await store.load();
      await target.load();
      await store.saveSettings({'business': 'Asli'});
      await target.saveSettings({'business': 'Target'});
      const password = 'password-backup-uji';
      final source = store.backup();
      final encrypted = await BackupCipher.encrypt(source, password);
      final another = await BackupCipher.encrypt(source, password);
      final a = jsonDecode(encrypted), b = jsonDecode(another);
      expect(a['salt'], isNot(b['salt']));
      expect(a['nonce'], isNot(b['nonce']));
      await expectLater(
        BackupCipher.decrypt(encrypted, 'wrong-password'),
        throwsFormatException,
      );
      a['tag'] = base64Encode(List.filled(16, 0));
      await expectLater(
        BackupCipher.decrypt(jsonEncode(a), password),
        throwsFormatException,
      );
      expect(target.settings['business'], 'Target');
      final plain = await BackupCipher.decrypt(encrypted, password);
      expect(plain, source);
      await target.restore(plain);
      expect(target.settings['business'], 'Asli');
      a['iterations'] = 999999999;
      await expectLater(
        BackupCipher.decrypt(jsonEncode(a), password),
        throwsFormatException,
      );
      await expectLater(
        BackupCipher.encrypt(source, 'short'),
        throwsArgumentError,
      );
      store.dispose();
      target.dispose();
      await db.close();
      await targetDb.close();
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
  test(
    'PIN stores salted verifier, persists lockout, verifies change/disable',
    () async {
      final vault = MemoryVault();
      var now = DateTime(2026, 11, 5);
      final pin = PinController(vault, clock: () => now);
      await pin.load();
      expect(pin.locked, false);
      await pin.configure('', '125678', timeout: 30);
      final record = jsonDecode(vault.value!);
      expect(record.containsKey('pin'), false);
      expect(record['hash'], isNot('125678'));
      pin.lock();
      final reopened = PinController(vault, clock: () => now);
      await reopened.load();
      expect(reopened.locked, true);
      for (var i = 0; i < 5; i++) {
        expect(await reopened.verify('0000'), false);
      }
      final again = PinController(vault, clock: () => now);
      await again.load();
      await expectLater(again.unlock('125678'), throwsStateError);
      now = now.add(const Duration(seconds: 31));
      await again.unlock('125678');
      expect(again.locked, false);
      final inFlight = again.unlock('125678');
      again.lock();
      await expectLater(inFlight, throwsStateError);
      expect(again.locked, true);
      await again.unlock('125678');
      await expectLater(again.configure('9999', null), throwsArgumentError);
      await again.configure('125678', '4321');
      expect(await again.verify('125678'), false);
      await again.configure('4321', null);
      expect(vault.value, null);
      expect(again.enabled, false);
      expect(() => PinController.validatePin('123'), throwsArgumentError);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
