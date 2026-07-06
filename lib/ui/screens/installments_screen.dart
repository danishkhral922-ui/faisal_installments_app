import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/customer_provider.dart';
import 'customer_detail_screen.dart';

class InstallmentsScreen extends StatelessWidget {
  const InstallmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();
    final customers = provider.customers;

    final pendingCustomers = customers.where((c) => !c.isPaid).toList();
    final paidCustomers = customers.where((c) => c.isPaid).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Installments'),
        backgroundColor: const Color(0xFF122A5E),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: const TabBar(
                    indicatorColor: Colors.orangeAccent,
                    tabs: [
                      Tab(text: 'Pending'),
                      Tab(text: 'Paid'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _CustomersList(
                        title: 'Pending Installments',
                        subtitle: '${pendingCustomers.length} customers',
                        customers: pendingCustomers,
                      ),
                      _CustomersList(
                        title: 'Paid Installments',
                        subtitle: '${paidCustomers.length} customers',
                        customers: paidCustomers,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomersList extends StatelessWidget {
  const _CustomersList({
    required this.title,
    required this.subtitle,
    required this.customers,
  });

  final String title;
  final String subtitle;
  final List<dynamic> customers;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2575FC),
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    customer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    customer.isPaid
                        ? 'Paid'
                        : 'Pending • ${customer.remainingInstallments} installments left',
                    style: TextStyle(
                      color: customer.isPaid ? Colors.green : Colors.orange,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs.${customer.remainingAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${customer.completedInstallments}/${customer.totalMonths} paid',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CustomerDetailScreen(customer: customer),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (customers.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No records found.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
      ],
    );
  }
}
