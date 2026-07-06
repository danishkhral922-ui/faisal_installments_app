import 'dart:io';

import 'package:installment_app/data/models/customer_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

String buildCustomerStatementText(CustomerModel customer) {
  final sortedHistory = List.of(customer.paymentHistory)
    ..sort((a, b) => a.installmentNo.compareTo(b.installmentNo));

  final dateFmt = (DateTime dt) => dt.toLocal().toString().split(' ').first;

  final buffer = StringBuffer();
  buffer.writeln('Installment Statement (Bank Style)');
  buffer.writeln('====================================');
  buffer.writeln('Customer: ${customer.name}');
  buffer.writeln('Father Name: ${customer.fatherName}');
  buffer.writeln('Mobile: ${customer.mobile}');
  buffer.writeln(
    'CNIC: ${customer.cnic.isEmpty ? 'Not provided' : customer.cnic}',
  );
  buffer.writeln(
    'Address: ${customer.address.isEmpty ? 'Not provided' : customer.address}',
  );
  buffer.writeln('Product: ${customer.productName}');
  buffer.writeln('Price: ${customer.price.toStringAsFixed(0)}');
  buffer.writeln('Down Payment: ${customer.downPayment.toStringAsFixed(0)}');
  buffer.writeln('Start Date: ${dateFmt(customer.startDate)}');
  buffer.writeln(
    'Shop: ${customer.shopName.isEmpty ? 'Not provided' : customer.shopName}',
  );
  if (customer.referenceName.isNotEmpty) {
    buffer.writeln('Reference Person: ${customer.referenceName}');
  }
  if (customer.referencePhone.isNotEmpty) {
    buffer.writeln('Reference Phone: ${customer.referencePhone}');
  }
  if (customer.securityDetails.isNotEmpty) {
    buffer.writeln('Security Details: ${customer.securityDetails}');
  }
  if (customer.notes.isNotEmpty) {
    buffer.writeln('Notes: ${customer.notes}');
  }

  buffer.writeln('');
  buffer.writeln('Ledger (Installments)');
  buffer.writeln('-----------------------');
  buffer.writeln('No. | Paid Date | Amount');
  buffer.writeln('----+-----------+----------------');

  if (sortedHistory.isEmpty) {
    buffer.writeln('No payments recorded yet.');
  } else {
    for (final e in sortedHistory) {
      buffer.writeln(
        '${e.installmentNo.toString().padLeft(3)} | ${dateFmt(e.paidDate)} | Rs.${e.amount.toStringAsFixed(0)}',
      );
    }
  }

  buffer.writeln('');
  buffer.writeln('Totals');
  buffer.writeln('------');
  buffer.writeln('Paid Amount: Rs.${customer.paidAmount.toStringAsFixed(0)}');
  buffer.writeln(
    'Completed Installments: ${customer.completedInstallments}/${customer.totalMonths}',
  );
  buffer.writeln('Remaining Installments: ${customer.remainingInstallments}');
  buffer.writeln(
    'Next Installment (Approx): Rs.${customer.currentMonthlyInstallment.toStringAsFixed(0)}',
  );
  buffer.writeln('Status: ${customer.isPaid ? 'Paid' : 'Pending'}');

  buffer.writeln('');
  buffer.writeln('Authorized Signature: ____________________');

  return buffer.toString();
}

Future<void> exportCustomerStatement(CustomerModel customer) async {
  final content = buildCustomerStatementText(customer);
  final directory = await getTemporaryDirectory();
  final file = File(
    '${directory.path}/installment_statement_${customer.id}.txt',
  );
  await file.writeAsString(content);

  await SharePlus.instance.share(
    ShareParams(
      title: 'Installment Statement - ${customer.name}',
      text: 'Installment statement for ${customer.name}',
      files: [XFile(file.path)],
    ),
  );
}

Future<File> saveCustomerStatementToDownloads(CustomerModel customer) async {
  final content = buildCustomerStatementText(customer);
  final directory = await getDownloadsDirectory();
  final downloadPath = directory?.path ?? '/storage/emulated/0/Download';

  final file = File('$downloadPath/installment_statement_${customer.id}.txt');
  await file.writeAsString(content);
  return file;
}

Future<void> printCustomerStatement(CustomerModel customer) async {
  final pdf = pw.Document();

  final sortedHistory = List.of(customer.paymentHistory)
    ..sort((a, b) => a.installmentNo.compareTo(b.installmentNo));

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue900, width: 1.5),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Installment Statement',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Bank-style installment ledger with paid dates',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 14),
              pw.Divider(color: PdfColors.blue300),
              pw.SizedBox(height: 12),
              pw.Text(
                'Customer: ${customer.name}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text('Product: ${customer.productName}'),
              pw.Text('Mobile: ${customer.mobile}'),
              pw.Text('Status: ${customer.isPaid ? 'Paid' : 'Pending'}'),
              pw.SizedBox(height: 10),

              pw.Text(
                'Ledger (Installments)',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),

              if (sortedHistory.isEmpty)
                pw.Text('No payments recorded yet.')
              else
                pw.Table.fromTextArray(
                  headers: const ['No.', 'Paid Date', 'Amount'],
                  data: sortedHistory.map((e) {
                    final paidDate = e.paidDate
                        .toLocal()
                        .toString()
                        .split(' ')
                        .first;
                    return [
                      e.installmentNo.toString(),
                      paidDate,
                      'Rs.${e.amount.toStringAsFixed(0)}',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blue900,
                  ),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  border: pw.TableBorder.all(
                    color: PdfColors.grey400,
                    width: 0.6,
                  ),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(0.15),
                    1: pw.FlexColumnWidth(0.45),
                    2: pw.FlexColumnWidth(0.3),
                  },
                ),

              pw.SizedBox(height: 14),
              pw.Divider(color: PdfColors.blue300),
              pw.SizedBox(height: 10),

              pw.Text(
                'Totals',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Paid Amount: Rs.${customer.paidAmount.toStringAsFixed(0)}',
              ),
              pw.Text(
                'Completed Installments: ${customer.completedInstallments}/${customer.totalMonths}',
              ),
              pw.Text(
                'Remaining Installments: ${customer.remainingInstallments}',
              ),
              pw.Text(
                'Next Installment (Approx): Rs.${customer.currentMonthlyInstallment.toStringAsFixed(0)}',
              ),
              pw.Spacer(),

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
    name: 'installment_statement_${customer.id}.pdf',
    onLayout: (format) async => bytes,
  );
}
