import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:installment_app/data/models/customer_model.dart';
import 'package:installment_app/utils/monthly_status_scheduler.dart';

class CustomerProvider extends ChangeNotifier {
  CustomerProvider();

  Box<CustomerModel>? _box;

  FirebaseFirestore? _firestore;
  List<CustomerModel> _customers = [];
  String _searchText = '';
  bool _showOnlyPending = false;

  List<CustomerModel> get customers => _customers;
  String get searchText => _searchText;
  bool get showOnlyPending => _showOnlyPending;

  FirebaseFirestore? get _firestoreInstance {
    if (Firebase.apps.isEmpty) {
      return null;
    }

    _firestore ??= FirebaseFirestore.instance;
    return _firestore;
  }

  List<CustomerModel> get filteredCustomers {
    final query = _searchText.trim().toLowerCase();
    var result = _customers.where((customer) {
      final matchesQuery =
          query.isEmpty ||
          customer.name.toLowerCase().contains(query) ||
          customer.mobile.contains(query) ||
          customer.cnic.toLowerCase().contains(query) ||
          customer.productName.toLowerCase().contains(query);
      final matchesPending = !_showOnlyPending || !customer.isPaid;
      return matchesQuery && matchesPending;
    });

    return result.toList();
  }

  Future<void> initialize() async {
    if (_box != null) {
      return;
    }

    _box = await Hive.openBox<CustomerModel>('customers');
    await loadCustomers();
  }

  Future<void> loadCustomers() async {
    await initialize();
    final box = _box;
    if (box == null) {
      return;
    }

    _customers = box.values.toList().cast<CustomerModel>();
    _customers.sort((a, b) => b.startDate.compareTo(a.startDate));

    // Apply monthly reset logic when app loads.
    await _applyMonthlyStatusResets(now: DateTime.now());

    notifyListeners();
  }

  Future<void> addCustomer({
    required String name,
    required String fName,
    required String phone,
    required int months,
    required String productName,
    required double price,
    required double downPayment,
    required DateTime startDate,
    String cnic = '',
    String address = '',
    String referenceName = '',
    String referencePhone = '',
    String shopName = '',
    String notes = '',
    String securityDetails = '',
    List<String> images = const [],
  }) async {
    await initialize();

    final remainingAmount = price - downPayment;
    final installmentAmount = months > 0 ? remainingAmount / months : 0.0;

    final newCustomer = CustomerModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      fatherName: fName.trim(),
      mobile: phone.trim(),
      cnic: cnic.trim(),
      address: address.trim(),
      productName: productName.trim(),
      price: price,
      downPayment: downPayment,
      totalInstallments: months,
      installmentAmount: installmentAmount,
      startDate: startDate,
      referenceName: referenceName.trim(),
      referencePhone: referencePhone.trim(),
      shopName: shopName.trim(),
      notes: notes.trim(),
      images: images,
      totalMonths: months,
      securityDetails: securityDetails.trim(),
    );

    debugPrint(
      'Adding customer to Hive: id=${newCustomer.id} name=${newCustomer.name}',
    );

    await _box!.add(newCustomer);

    final firestore = _firestoreInstance;
    if (firestore != null) {
      try {
        await firestore.collection('customers').doc(newCustomer.id).set({
          'name': newCustomer.name,
          'fatherName': newCustomer.fatherName,
          'phone': newCustomer.mobile,
          'productName': newCustomer.productName,
          'price': newCustomer.price,
          'downPayment': newCustomer.downPayment,
          'totalMonths': newCustomer.totalMonths,
          'installmentAmount': newCustomer.installmentAmount,
          'isPaid': newCustomer.isPaid,
          'securityDetails': newCustomer.securityDetails,
          'timestamp': FieldValue.serverTimestamp(),
        });
        debugPrint('Firebase set success for id=${newCustomer.id}');
      } catch (e, s) {
        debugPrint('Firebase sync skipped: $e\n$s');
      }
    }

    await loadCustomers();
  }

  Future<void> recordPayment(
    String id, {
    required int installments,
    required double amountPaid,
  }) async {
    await initialize();
    final customer = _customers.firstWhere((item) => item.id == id);

    final normalizedInstallments = installments.clamp(
      0,
      customer.totalMonths - customer.completedInstallments,
    );
    if (normalizedInstallments <= 0) {
      return;
    }

    final monthlyInstallment = customer.totalMonths > 0
        ? (customer.price - customer.downPayment) / customer.totalMonths
        : 0.0;
    final expectedAmount = monthlyInstallment * normalizedInstallments;
    final safeAmount = amountPaid > 0 ? amountPaid : expectedAmount;

    customer.completedInstallments += normalizedInstallments;
    customer.paidAmount += safeAmount;
    customer.lastPaidMonth = customer.completedInstallments;

    // Recompute paid/pending based on totals, not only boolean flag.
    customer.isPaid =
        customer.completedInstallments >= customer.totalMonths &&
        customer.totalMonths > 0;

    customer.installmentAmount = customer.isPaid
        ? 0.0
        : customer.currentMonthlyInstallment;

    await customer.save();
    await loadCustomers();
  }

  void updateSearch(String value) {
    _searchText = value;
    notifyListeners();
  }

  void toggleShowOnlyPending(bool value) {
    _showOnlyPending = value;
    notifyListeners();
  }

  Future<void> markAsPaid(String id, {bool isPaid = true}) async {
    await initialize();
    final customer = _customers.firstWhere((item) => item.id == id);
    customer.isPaid = isPaid;
    customer.installmentAmount = isPaid
        ? 0.0
        : customer.currentMonthlyInstallment;
    await customer.save();
    final firestore = _firestoreInstance;
    if (firestore != null) {
      await firestore
          .collection('customers')
          .doc(id)
          .update({
            'isPaid': customer.isPaid,
            'installmentAmount': customer.installmentAmount,
          })
          .catchError((_) {});
    }
    await loadCustomers();
  }

  Future<void> updateCustomer(CustomerModel updated) async {
    await initialize();
    final customer = _customers.firstWhere((item) => item.id == updated.id);
    customer.name = updated.name;
    customer.fatherName = updated.fatherName;
    customer.mobile = updated.mobile;
    customer.cnic = updated.cnic;
    customer.address = updated.address;
    customer.productName = updated.productName;
    customer.price = updated.price;
    customer.downPayment = updated.downPayment;
    customer.installmentAmount = updated.installmentAmount;
    customer.referenceName = updated.referenceName;
    customer.referencePhone = updated.referencePhone;
    customer.shopName = updated.shopName;
    customer.notes = updated.notes;
    customer.securityDetails = updated.securityDetails;
    customer.images = updated.images;
    customer.isPaid = updated.isPaid;
    customer.totalMonths = updated.totalMonths;
    customer.completedInstallments = updated.completedInstallments;
    customer.paidAmount = updated.paidAmount;
    customer.lastPaidMonth = updated.lastPaidMonth;
    await customer.save();
    await loadCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    await initialize();
    final index = _customers.indexWhere((customer) => customer.id == id);
    if (index >= 0) {
      final customer = _customers[index];
      await _box!.delete(customer.key);
      final firestore = _firestoreInstance;
      if (firestore != null) {
        await firestore
            .collection('customers')
            .doc(id)
            .delete()
            .catchError((_) {});
      }
      await loadCustomers();
    }
  }

  Future<void> _applyMonthlyStatusResets({required DateTime now}) async {
    if (_customers.isEmpty) return;

    // Apply scheduler and persist changes.
    final changed = MonthlyStatusScheduler.runOnCustomers(
      customers: _customers,
      now: now,
      onChanged: (customer) async {
        await customer.save();

        final firestore = _firestoreInstance;
        if (firestore != null) {
          await firestore
              .collection('customers')
              .doc(customer.id)
              .update({
                'isPaid': customer.isPaid,
                'installmentAmount': customer.installmentAmount,
                'lastPaidMonth': customer.lastPaidMonth,
              })
              .catchError((_) {});
        }
      },
    );

    if (changed > 0) {
      debugPrint('Monthly reset applied to $changed customers');
    }
  }
}
