import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:untungku_pro/core/security/backup_cipher.dart';
import 'package:untungku_pro/core/security/pin_controller.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/business/entities.dart';
import 'package:untungku_pro/domain/receipt.dart';
import 'package:untungku_pro/services/receipts/receipt_pdf.dart';
import 'package:untungku_pro/services/receipts/printer.dart';
import 'package:untungku_pro/features/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'v2 supplier receiving, partial sale, payment, return and encrypted restore',
    (tester) async {
      const date = '2026-11-05T10:00:00';
      final db = AppDatabase(NativeDatabase.memory()),
          cleanDb = AppDatabase(NativeDatabase.memory());
      final store = Store(db), clean = Store(cleanDb);
      await store.load();
      await clean.load();
      await store.saveProduct(
        const Product(
          id: 'p',
          name: 'Kopi',
          barcode: '12345678',
          price: 10000,
          cost: 5000,
          stock: 0,
          created: date,
          updated: date,
        ),
      );
      for (final supplier in [false, true]) {
        await store.saveContact(
          Contact(
            id: supplier ? 'supplier' : 'customer',
            name: supplier ? 'Pemasok' : 'Pelanggan',
            created: date,
            updated: date,
          ),
          supplier: supplier,
        );
      }
      await store.savePurchaseDraft(
        const Purchase(
          id: 'po',
          date: date,
          supplierId: 'supplier',
          lines: [
            PurchaseLine(
              productId: 'p',
              name: 'Kopi',
              quantity: 10,
              unitCost: 6000,
            ),
          ],
        ),
      );
      await store.confirmPurchase('po', 'confirm-po');
      await store.receivePurchase(
        id: 'receipt-po',
        purchaseId: 'po',
        quantities: {'p': 10},
        date: date,
      );
      await store.receivePurchase(
        id: 'receipt-po',
        purchaseId: 'po',
        quantities: {'p': 10},
        date: date,
      );
      expect(store.products.single.stock, 10);
      await store.saveSale(
        const Sale(
          id: 'sale',
          date: date,
          customer: 'Pelanggan',
          credit: true,
          dueDate: '2026-11-10',
          lines: [
            SaleLine(
              productId: 'p',
              name: 'Kopi',
              quantity: 2,
              price: 10000,
              cost: 6000,
              packaging: 0,
              extra: 0,
            ),
          ],
          payments: [
            SalePayment(
              id: 'partial',
              date: date,
              amount: 5000,
              method: 'Tunai',
            ),
          ],
        ),
        customerId: 'customer',
      );
      expect(store.products.single.stock, 8);
      expect(store.sales.single.outstanding, 15000);
      await store.recordPayment(
        'sale',
        const SalePayment(
          id: 'remaining',
          date: date,
          amount: 15000,
          method: 'Tunai',
        ),
      );
      expect((await store.cashBalances())[null], 20000);
      expect(
        (await receiptPdf(
          ReceiptSnapshot(sale: store.sales.single, business: 'Uji'),
        )).take(5),
        '%PDF-'.codeUnits,
      );
      await store.recordReturn(
        id: 'return',
        saleId: 'sale',
        quantities: {0: 1},
        restock: {0},
        reason: 'Uji retur',
        date: date,
      );
      await store.refundCustomer(
        id: 'refund',
        returnId: 'return',
        amount: 10000,
        date: date,
        method: 'Tunai',
      );
      expect(store.products.single.stock, 9);
      expect((await store.cashBalances())[null], 10000);
      final encrypted = await BackupCipher.encrypt(
        store.backup(),
        'password-integrasi-uji',
      );
      await clean.restore(
        await BackupCipher.decrypt(encrypted, 'password-integrasi-uji'),
      );
      final original = jsonDecode(store.backup()) as Map..remove('created');
      final restored = jsonDecode(clean.backup()) as Map..remove('created');
      expect(restored, original);
      expect((await clean.payableReport()).single.outstanding, 60000);
      expect((await clean.cashBalances())[null], 10000);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const MaterialApp(home: ReceiptPage(saleId: 'sale')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Refund sudah dibayar'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      clean.dispose();
      await db.close();
      await cleanDb.close();
    },
  );

  testWidgets(
    'Android secure PIN verifier persists and native printer fails safely without hardware',
    (tester) async {
      const vault = SecurePinVault(key: 'untungku-integration-test-pin');
      addTearDown(vault.delete);
      final pin = PinController(vault);
      await pin.load();
      await pin.configure('', '2468');
      final reopened = PinController(vault);
      await reopened.load();
      expect(reopened.locked, true);
      await expectLater(reopened.unlock('0000'), throwsArgumentError);
      await reopened.unlock('2468');
      expect(reopened.locked, false);
      await reopened.configure('2468', null);
      try {
        await ReceiptPrinter().printBytes(
          '00:11:22:33:44:55',
          Uint8List.fromList([27, 64, 10]),
        );
        fail('Unpaired printer must not succeed');
      } on PlatformException catch (error) {
        expect(['bluetooth', 'printer', 'permission'], contains(error.code));
      }
      pin.dispose();
      reopened.dispose();
    },
  );
}
