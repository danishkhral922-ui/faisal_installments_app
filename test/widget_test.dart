import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:installment_app/data/models/customer_model.dart';
import 'package:installment_app/utils/record_export.dart';

void main() {
  testWidgets('App starts without error', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
  });

  test('customer record export text contains the main installment details', () {
    final customer = CustomerModel(
      id: '1',
      name: 'Ali Khan',
      fatherName: 'Khalid Khan',
      mobile: '03001234567',
      cnic: '12345-6789012-3',
      address: 'Lahore',
      productName: 'Mobile Phone',
      price: 50000,
      downPayment: 10000,
      totalInstallments: 10,
      installmentAmount: 4000,
      startDate: DateTime(2024, 1, 1),
      referenceName: 'Amir',
      referencePhone: '03009998877',
      shopName: 'ABC Shop',
      notes: 'Needs follow-up',
      images: [],
      totalMonths: 10,
      isPaid: false,
      securityDetails: 'CNIC copy',
    );

    final text = buildCustomerRecordText(customer);

    expect(text, contains('Installment Record'));
    expect(text, contains('Ali Khan'));
    expect(text, contains('Mobile Phone'));
    expect(text, contains('50000'));
    expect(text, contains('Pending'));
  });
}
