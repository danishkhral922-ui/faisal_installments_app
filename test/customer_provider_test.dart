import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:installment_app/data/models/customer_model.dart';
import 'package:installment_app/firebase_options.dart';
import 'package:installment_app/providers/customer_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (error) {
      // ignore: avoid_print
      print('Firebase unavailable in tests: $error');
    }

    final tempDir = await Directory.systemTemp.createTemp('installment_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CustomerModelAdapter());
    }
    await Hive.deleteBoxFromDisk('customers');
    await Hive.openBox<CustomerModel>('customers');
  });

  test('addCustomer saves a customer and updates the list', () async {
    final provider = CustomerProvider();

    await provider.addCustomer(
      name: 'Ali Khan',
      fName: 'Ahmed Khan',
      phone: '03001234567',
      months: 6,
      productName: 'Mobile',
      price: 60000,
      downPayment: 12000,
      startDate: DateTime(2025, 1, 1),
    );

    expect(provider.customers, isNotEmpty);
    expect(provider.customers.first.name, 'Ali Khan');
  });

  test(
    'recordPayment updates installment progress and remaining balance',
    () async {
      final provider = CustomerProvider();

      await provider.addCustomer(
        name: 'Sara Khan',
        fName: 'Bilal Khan',
        phone: '03001112233',
        months: 6,
        productName: 'Laptop',
        price: 60000,
        downPayment: 10000,
        startDate: DateTime.now().subtract(const Duration(days: 120)),
      );

      final customer = provider.customers.first;

      await provider.recordPayment(
        customer.id,
        installments: 2,
        amountPaid: 20000,
      );

      expect(provider.customers.first.completedInstallments, 2);
      expect(provider.customers.first.remainingInstallments, 4);
      expect(provider.customers.first.remainingAmount, 30000);
    },
  );
}
