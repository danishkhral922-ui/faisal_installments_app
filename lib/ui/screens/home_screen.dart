import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/theme_provider.dart';

import 'add_customer_screen.dart';
import 'customer_detail_screen.dart';
import 'edit_customer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Installment Tracker'),
        centerTitle: true,
        backgroundColor: const Color(0xFF122A5E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/auth');
                }
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: context.watch<ThemeProvider>().appGradient,
        ),
        child: SafeArea(
          child: Consumer<CustomerProvider>(
            builder: (context, provider, child) {
              if (provider.customers.isEmpty) {
                return const Center(
                  child: Text(
                    'No customers added yet.',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                );
              }

              final totalCustomers = provider.customers.length;
              final paidCustomers = provider.customers
                  .where((c) => c.isPaid)
                  .length;
              final pendingCustomers = provider.customers
                  .where((c) => !c.isPaid)
                  .length;
              final totalDueThisMonth = provider.customers.fold<double>(0, (
                sum,
                customer,
              ) {
                if (customer.isPaid) return sum;
                // Show only this month's installment due, not full remaining balance.
                return sum + customer.currentMonthlyInstallment;
              });

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SummaryTile(
                              label: 'Customers',
                              value: '$totalCustomers',
                            ),
                            _SummaryTile(
                              label: 'Paid',
                              value: '$paidCustomers',
                            ),
                            _SummaryTile(
                              label: 'Pending',
                              value: '$pendingCustomers',
                            ),
                            _SummaryTile(
                              label: 'Due',
                              value:
                                  'Rs.${totalDueThisMonth.toStringAsFixed(0)}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by name, phone, CNIC or product',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: provider.updateSearch,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      itemCount: provider.filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = provider.filteredCustomers[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${customer.productName} • ${customer.totalMonths} months',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  customer.isPaid ? 'Paid' : 'Pending',
                                  style: TextStyle(
                                    color: customer.isPaid
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs.${customer.remainingAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${customer.completedInstallments}/${customer.totalMonths} paid',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  customer.mobile,
                                  style: const TextStyle(fontSize: 12),
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
                            onLongPress: auth.isAdmin
                                ? () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (_) => SafeArea(
                                        child: Wrap(
                                          children: [
                                            ListTile(
                                              leading: const Icon(Icons.edit),
                                              title: const Text('Edit'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        EditCustomerScreen(
                                                          customer: customer,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.delete),
                                              title: const Text('Delete'),
                                              onTap: () async {
                                                Navigator.pop(context);
                                                await context
                                                    .read<CustomerProvider>()
                                                    .deleteCustomer(
                                                      customer.id,
                                                    );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFA726),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}
