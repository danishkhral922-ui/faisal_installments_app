import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/statement_export.dart' as statement_export;

/// IMPORTANT:
/// CustomerDetailScreen must rebuild after recordPayment.
/// We keep it Stateless but we re-pull the latest customer from provider
/// and use [context.watch] so that paid/pending status updates instantly.

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    // Important: customer.isPaid might change after recordPayment.
    // Using provider.watch ensures rebuild after Hive save + notifyListeners.
    final provider = context.watch<CustomerProvider>();
    final latest = provider.customers.firstWhere(
      (c) => c.id == customer.id,
      orElse: () => customer,
    );

    return _CustomerDetailBody(customer: latest);
  }
}

class _CustomerDetailBody extends StatelessWidget {
  const _CustomerDetailBody({required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        elevation: 0,
        backgroundColor: const Color(0xFF122A5E),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'share') {
                await statement_export.exportCustomerStatement(customer);
              } else if (value == 'save') {
                final savedFile = await statement_export
                    .saveCustomerStatementToDownloads(customer);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved to ${savedFile.path}')),
                  );
                }
              } else if (value == 'print') {
                await statement_export.printCustomerStatement(customer);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'share', child: Text('Share Record')),
              PopupMenuItem(value: 'save', child: Text('Save to Downloads')),
              PopupMenuItem(value: 'print', child: Text('Print / Export')),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: context.watch<ThemeProvider>().appGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoCard('Customer', customer.name),
              _infoCard('Father Name', customer.fatherName),
              _infoCard('Mobile', customer.mobile),
              _infoCard(
                'CNIC',
                customer.cnic.isEmpty ? 'Not provided' : customer.cnic,
              ),
              _infoCard('Product', customer.productName),
              _infoCard('Price', 'Rs ${customer.price.toStringAsFixed(0)}'),

              _infoCard(
                'Down Payment',
                'Rs.${customer.downPayment.toStringAsFixed(0)}',
              ),

              _infoCard('Months', '${customer.totalMonths}'),
              _infoCard('Status', customer.isPaid ? 'Paid' : 'Pending'),
              _infoCard(
                'Completed Installments',
                '${customer.completedInstallments}/${customer.totalMonths}',
              ),
              _infoCard(
                'Remaining Installments',
                '${customer.remainingInstallments}',
              ),
              _infoCard(
                'Paid Amount',
                'Rs.${customer.paidAmount.toStringAsFixed(0)}',
              ),
              _infoCard(
                'Remaining Amount',
                'Rs.${customer.remainingAmount.toStringAsFixed(0)}',
              ),
              _infoCard(
                'Next Installment',
                'Rs.${customer.currentMonthlyInstallment.toStringAsFixed(0)}',
              ),
              _infoCard(
                'Reference Person',
                customer.referenceName.isEmpty
                    ? 'Not provided'
                    : customer.referenceName,
              ),
              _infoCard(
                'Reference Phone',
                customer.referencePhone.isEmpty
                    ? 'Not provided'
                    : customer.referencePhone,
              ),
              _infoCard(
                'Security Details',
                customer.securityDetails.isEmpty
                    ? 'Not provided'
                    : customer.securityDetails,
              ),
              _infoCard(
                'Address',
                customer.address.isEmpty ? 'Not provided' : customer.address,
              ),
              _infoCard(
                'Notes',
                customer.notes.isEmpty ? 'No notes' : customer.notes,
              ),
              _imageCard(
                title: 'CNIC Front',
                path: customer.images.isNotEmpty ? customer.images[0] : null,
                placeholderIcon: Icons.credit_card,
              ),
              _imageCard(
                title: 'CNIC Back',
                path: customer.images.length > 1 ? customer.images[1] : null,
                placeholderIcon: Icons.credit_card_outlined,
              ),
              _imageCard(
                title: 'Product Image',
                path: customer.images.length > 2 ? customer.images[2] : null,
                placeholderIcon: Icons.shopping_bag_outlined,
              ),
              const SizedBox(height: 8),
              if (!customer.isPaid)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await context.read<CustomerProvider>().markAsPaid(
                        customer.id,
                        isPaid: true,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Customer marked as paid'),
                          ),
                        );
                      }
                    },
                    child: const Text('Mark as Paid'),
                  ),
                ),
              if (!customer.isPaid) const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async => _showPaymentDialog(context),
                  child: Text(
                    customer.isPaid ? 'Mark as Pending' : 'Record Payment',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.print_rounded, color: Colors.orangeAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Share, save, or print this installment record anytime.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPaymentDialog(BuildContext context) async {
    if (customer.isPaid) {
      await context.read<CustomerProvider>().markAsPaid(
        customer.id,
        isPaid: false,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer marked as pending')),
        );
      }
      return;
    }

    final installmentsCtrl = TextEditingController(text: '1');
    final amountCtrl = TextEditingController(
      text: customer.currentMonthlyInstallment.toStringAsFixed(0),
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Record Installment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: installmentsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Installments completed',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount paid',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, {
                  'installments':
                      int.tryParse(installmentsCtrl.text.trim()) ?? 1,
                  'amount': double.tryParse(amountCtrl.text.trim()) ?? 0.0,
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    await context.read<CustomerProvider>().recordPayment(
      customer.id,
      installments: result['installments'] as int,
      amountPaid: result['amount'] as double,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Installment recorded')));
    }
  }

  Widget _imageCard({
    required String title,
    required String? path,
    required IconData placeholderIcon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withValues(alpha: 0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: path != null && path.trim().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(path), fit: BoxFit.cover),
                    )
                  : Center(
                      child: Icon(
                        placeholderIcon,
                        size: 48,
                        color: Colors.white70,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withValues(alpha: 0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
