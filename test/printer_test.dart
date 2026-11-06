import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/receipt.dart';
import 'package:untungku_pro/services/receipts/printer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const receipt = ReceiptSnapshot(
    business: 'Toko\u001b@',
    sale: Sale(
      id: 's',
      date: '2026-11-05',
      lines: [
        SaleLine(
          productId: 'p',
          name:
              'Nama produk panjang untuk menguji pembungkusan teks pada printer kecil',
          quantity: 2,
          price: 10000,
          cost: 5000,
          packaging: 0,
          extra: 0,
        ),
      ],
    ),
  );
  test(
    'text ESC/POS wraps both widths and blocks embedded printer commands',
    () {
      for (final width in [58, 80]) {
        final bytes = receiptEscPos(receipt, paperWidth: width);
        expect(bytes.take(2), [27, 64]);
        expect(bytes.skip(2).contains(27), false);
        final text = String.fromCharCodes(bytes.skip(2));
        expect(text, contains('Rp 20.000'));
        expect(
          text.split('\n').every((s) => s.length <= (width == 58 ? 32 : 48)),
          true,
        );
      }
      expect(() => receiptEscPos(receipt, paperWidth: 76), throwsArgumentError);
    },
  );
  test(
    'permission, disconnect and retry expose errors; no sale posting API',
    () async {
      var calls = 0;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(ReceiptPrinter.channel, (call) async {
        calls++;
        if (call.method == 'paired') {
          return [
            {'name': 'Uji', 'address': '00:11:22:33:44:55'},
          ];
        }
        if (calls == 2) throw PlatformException(code: 'print_failed');
        expect(call.arguments['bytes'], receiptEscPos(receipt));
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(ReceiptPrinter.channel, null),
      );
      final printer = ReceiptPrinter();
      expect((await printer.paired()).single['name'], 'Uji');
      await expectLater(
        printer.printBytes('invalid', receiptEscPos(receipt)),
        throwsArgumentError,
      );
      await expectLater(
        printer.printBytes('00:11:22:33:44:55', receiptEscPos(receipt)),
        throwsA(isA<PlatformException>()),
      );
      await printer.printBytes('00:11:22:33:44:55', receiptEscPos(receipt));
      expect(calls, 3);
    },
  );
}
