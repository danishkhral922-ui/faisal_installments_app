import 'dart:io';

import 'package:installment_app/data/models/customer_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

String buildCustomerRecordText(CustomerModel customer) {
  // Must match what CustomerDetailScreen shows.
  final paidAmount = customer.paidAmount;

  return '''
Installment Record
=================
Customer: ${customer.name}
Father Name: ${customer.fatherName}
Mobile: ${customer.mobile}
CNIC: ${customer.cnic.isEmpty ? 'Not provided' : customer.cnic}
Address: ${customer.address.isEmpty ? 'Not provided' : customer.address}
Product: ${customer.productName}
Price: ${customer.price.toStringAsFixed(0)}
Down Payment: ${customer.downPayment.toStringAsFixed(0)}
Paid Amount: ${paidAmount.toStringAsFixed(0)}

Completed Installments: ${customer.completedInstallments}/${customer.totalMonths}
Remaining Installments: ${customer.remainingInstallments}
Next Installment: ${customer.currentMonthlyInstallment.toStringAsFixed(0)}
Status: ${customer.isPaid ? 'Paid' : 'Pending'}
Reference Person: ${customer.referenceName.isEmpty ? 'Not provided' : customer.referenceName}
Reference Phone: ${customer.referencePhone.isEmpty ? 'Not provided' : customer.referencePhone}
Security Details: ${customer.securityDetails.isEmpty ? 'Not provided' : customer.securityDetails}
Notes: ${customer.notes.isEmpty ? 'No notes' : customer.notes}
Shop: ${customer.shopName.isEmpty ? 'Not provided' : customer.shopName}
Start Date: ${customer.startDate.toLocal().toString().split(' ').first}
''';
}

Future<void> exportCustomerRecord(CustomerModel customer) async {
  final content = buildCustomerRecordText(customer);
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/installment_record_${customer.id}.txt');
  await file.writeAsString(content);
  await SharePlus.instance.share(
    ShareParams(
      title: 'Installment Record - ${customer.name}',
      text: 'Installment record for ${customer.name}',
      files: [XFile(file.path)],
    ),
  );
}

Future<void> saveCustomerRecord(CustomerModel customer) async {
  final content = buildCustomerRecordText(customer);
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/installment_record_${customer.id}.txt');
  await file.writeAsString(content);
}

Future<File> saveCustomerRecordToDownloads(CustomerModel customer) async {
  final content = buildCustomerRecordText(customer);
  final directory = await getDownloadsDirectory();
  final downloadPath = directory?.path ?? '/storage/emulated/0/Download';
  final file = File('$downloadPath/installment_record_${customer.id}.txt');
  await file.writeAsString(content);
  return file;
}

Future<void> printCustomerRecord(CustomerModel customer) async {
  final pdf = pw.Document();
  final content = buildCustomerRecordText(customer);
  final lines = content
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .toList();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(24),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue900, width: 1.5),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 44,
                    height: 44,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue900,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'FAISAL',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'FAISAL ELECTRONICS',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'Installment Record Summary',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Divider(color: PdfColors.blue300),
              pw.SizedBox(height: 12),
              pw.Text(
                'Customer: ${customer.name}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Product: ${customer.productName}'),
              pw.Text('Mobile: ${customer.mobile}'),
              pw.Text('Status: ${customer.isPaid ? 'Paid' : 'Pending'}'),
              pw.SizedBox(height: 12),
              pw.Text(
                'Financial Details',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              ...lines.skip(1).map((line) => pw.Text(line)),
              pw.SizedBox(height: 18),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Signature',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 24),
                    pw.Container(height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 4),
                    pw.Text('Proprietor: Muhammad Faisal'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  final bytes = await pdf.save();
  await Printing.layoutPdf(
    name: 'installment_record_${customer.id}.pdf',
    onLayout: (format) async => bytes,
  );
}
