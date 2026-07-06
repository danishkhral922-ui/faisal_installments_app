import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:installment_app/data/models/customer_model.dart';
import 'package:installment_app/data/models/payment_entry.dart';
import 'package:installment_app/utils/monthly_status_scheduler.dart';

class CustomerProvider extends ChangeNotifier {
  CustomerProvider();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _customersSub;

  FirebaseFirestore? _firestore;
  List<CustomerModel> _customers = [];

  String _searchText = '';
  bool _showOnlyPending = false;

  List<CustomerModel> get customers => _customers;
  String get searchText => _searchText;
  bool get showOnlyPending => _showOnlyPending;

  FirebaseFirestore? get _firestoreInstance {
    if (Firebase.apps.isEmpty) return null;
    _firestore ??= FirebaseFirestore.instance;
    return _firestore;
  }

  List<CustomerModel> get filteredCustomers {
    final query = _searchText.trim().toLowerCase();

    final result = _customers.where((customer) {
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
    final firestore = _firestoreInstance;
    if (firestore == null) return;

    // Listen to Firestore so offline cache works automatically.
    await _customersSub?.cancel();

    _customersSub = firestore
        .collection('customers')
        .orderBy('startDate', descending: true)
        .snapshots()
        .listen(
          (snapshot) async {
            _customers = snapshot.docs
                .map((d) => _fromDoc(d))
                .whereType<CustomerModel>()
                .toList();

            // Apply monthly reset when data changes / app opens.
            await _applyMonthlyStatusResets(now: DateTime.now());

            notifyListeners();
          },
          onError: (e) {
            debugPrint('[CustomerProvider] customers listen error: $e');
          },
        );
  }

  CustomerModel? _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    if (data == null) return null;

    // startDate is stored as Timestamp (see addCustomer).
    final startTs = data['startDate'];
    final startDate = startTs is Timestamp
        ? startTs.toDate()
        : DateTime.tryParse('${startTs ?? ''}') ?? DateTime.now();

    final images = (data['images'] as List?)?.cast<String>() ?? const [];

    return CustomerModel(
      id: d.id,
      name: (data['name'] ?? '') as String,
      fatherName: (data['fatherName'] ?? '') as String,
      mobile: (data['phone'] ?? '') as String,
      cnic: (data['cnic'] ?? '') as String,
      address: (data['address'] ?? '') as String,
      productName: (data['productName'] ?? '') as String,
      price: (data['price'] ?? 0).toDouble(),
      downPayment: (data['downPayment'] ?? 0).toDouble(),
      totalInstallments: (data['totalMonths'] ?? 0) as int,
      installmentAmount: (data['installmentAmount'] ?? 0).toDouble(),
      startDate: startDate,
      referenceName: (data['referenceName'] ?? '') as String,
      referencePhone: (data['referencePhone'] ?? '') as String,
      shopName: (data['shopName'] ?? '') as String,
      notes: (data['notes'] ?? '') as String,
      images: images,
      totalMonths: (data['totalMonths'] ?? 0) as int,
      securityDetails: (data['securityDetails'] ?? '') as String,
      isPaid: (data['isPaid'] ?? false) as bool,
      completedInstallments: (data['completedInstallments'] ?? 0) as int,
      paidAmount: (data['paidAmount'] ?? 0).toDouble(),
      lastPaidMonth: (data['lastPaidMonth'] ?? 0) as int,
      paymentHistory: ((data['paymentHistory'] as List?) ?? const [])
          .map((e) => PaymentEntry.fromMap((e as Map).cast<String, dynamic>()))
          .toList(),
      adminUid: (data['adminUid'] ?? '') as String,
    );
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
    final firestore = _firestoreInstance;
    if (firestore == null) return;

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

    await firestore.collection('customers').doc(newCustomer.id).set({
      'name': newCustomer.name,
      'fatherName': newCustomer.fatherName,
      'phone': newCustomer.mobile,
      'cnic': newCustomer.cnic,
      'address': newCustomer.address,
      'productName': newCustomer.productName,
      'price': newCustomer.price,
      'downPayment': newCustomer.downPayment,
      'totalMonths': newCustomer.totalMonths,
      'installmentAmount': newCustomer.installmentAmount,
      'completedInstallments': newCustomer.completedInstallments,
      'paidAmount': newCustomer.paidAmount,
      'lastPaidMonth': newCustomer.lastPaidMonth,
      'isPaid': newCustomer.isPaid,
      'securityDetails': newCustomer.securityDetails,
      'referenceName': newCustomer.referenceName,
      'referencePhone': newCustomer.referencePhone,
      'shopName': newCustomer.shopName,
      'notes': newCustomer.notes,
      'images': newCustomer.images,
      'paymentHistory': newCustomer.paymentHistory
          .map((e) => e.toMap())
          .toList(),
      'startDate': Timestamp.fromDate(newCustomer.startDate),
      'adminUid': newCustomer.adminUid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> recordPayment(
    String id, {
    required int installments,
    required double amountPaid,
  }) async {
    final firestore = _firestoreInstance;
    if (firestore == null) return;

    final customer = _customers.firstWhere((c) => c.id == id);

    final normalizedInstallments = installments.clamp(
      0,
      customer.totalMonths - customer.completedInstallments,
    );
    if (normalizedInstallments <= 0) return;

    final monthlyInstallment = customer.totalMonths > 0
        ? (customer.price - customer.downPayment) / customer.totalMonths
        : 0.0;

    final expectedAmount = monthlyInstallment * normalizedInstallments;
    final safeAmount = amountPaid > 0 ? amountPaid : expectedAmount;

    final newCompleted =
        customer.completedInstallments + normalizedInstallments;
    final newPaidAmount = customer.paidAmount + safeAmount;
    final isPaidNow =
        newCompleted >= customer.totalMonths && customer.totalMonths > 0;

    final newInstallmentAmount = isPaidNow
        ? 0.0
        : customer.currentMonthlyInstallment;

    final now = DateTime.now();
    final perInstallmentAmount = normalizedInstallments > 0
        ? safeAmount / normalizedInstallments
        : 0.0;

    final newHistory = List<Map<String, dynamic>>.from(
      customer.paymentHistory.map((e) => e.toMap()),
    );

    for (int i = 0; i < normalizedInstallments; i++) {
      final installmentNo = customer.completedInstallments + i + 1;
      newHistory.add({
        'installmentNo': installmentNo,
        'paidDate': now.toIso8601String(),
        'amount': perInstallmentAmount,
      });
    }

    await firestore
        .collection('customers')
        .doc(id)
        .update({
          'completedInstallments': newCompleted,
          'paidAmount': newPaidAmount,
          'lastPaidMonth': newCompleted,
          'isPaid': isPaidNow,
          'installmentAmount': newInstallmentAmount,
          'paymentHistory': newHistory,
        })
        .catchError((_) {});
  }

  Future<void> markAsPaid(String id, {bool isPaid = true}) async {
    final firestore = _firestoreInstance;
    if (firestore == null) return;

    final customer = _customers.firstWhere((c) => c.id == id);

    final newInstallmentAmount = isPaid
        ? 0.0
        : customer.currentMonthlyInstallment;

    // If admin manually marks as paid/pending we do NOT change paymentHistory
    // because we don't know which exact installments were paid.
    // Statement will reflect paymentHistory (ledger).
    await firestore
        .collection('customers')
        .doc(id)
        .update({'isPaid': isPaid, 'installmentAmount': newInstallmentAmount})
        .catchError((_) {});
  }

  Future<void> updateCustomer(CustomerModel updated) async {
    final firestore = _firestoreInstance;
    if (firestore == null) return;

    await firestore
        .collection('customers')
        .doc(updated.id)
        .update({
          'name': updated.name,
          'fatherName': updated.fatherName,
          'phone': updated.mobile,
          'cnic': updated.cnic,
          'address': updated.address,
          'productName': updated.productName,
          'price': updated.price,
          'downPayment': updated.downPayment,
          'totalMonths': updated.totalMonths,
          'installmentAmount': updated.installmentAmount,
          'completedInstallments': updated.completedInstallments,
          'paidAmount': updated.paidAmount,
          'lastPaidMonth': updated.lastPaidMonth,
          'isPaid': updated.isPaid,
          'securityDetails': updated.securityDetails,
          'referenceName': updated.referenceName,
          'referencePhone': updated.referencePhone,
          'shopName': updated.shopName,
          'notes': updated.notes,
          'images': updated.images,
          'startDate': Timestamp.fromDate(updated.startDate),
          'adminUid': updated.adminUid,
        })
        .catchError((_) {});
  }

  Future<void> deleteCustomer(String id) async {
    final firestore = _firestoreInstance;
    if (firestore == null) return;

    await firestore.collection('customers').doc(id).delete().catchError((_) {});
  }

  void updateSearch(String value) {
    _searchText = value;
    notifyListeners();
  }

  void toggleShowOnlyPending(bool value) {
    _showOnlyPending = value;
    notifyListeners();
  }

  Future<void> _applyMonthlyStatusResets({required DateTime now}) async {
    if (_customers.isEmpty) return;

    final firestore = _firestoreInstance;
    if (firestore == null) return;

    // Apply scheduler and persist changes.
    final changed = MonthlyStatusScheduler.runOnCustomers(
      customers: _customers,
      now: now,
      onChanged: (customer) async {
        await firestore
            .collection('customers')
            .doc(customer.id)
            .update({
              'isPaid': customer.isPaid,
              'installmentAmount': customer.installmentAmount,
              'lastPaidMonth': customer.lastPaidMonth,
              'completedInstallments': customer.completedInstallments,
              'paidAmount': customer.paidAmount,
            })
            .catchError((_) {});
      },
    );

    if (changed > 0) {
      debugPrint('Monthly reset applied to $changed customers');
    }
  }

  @override
  void dispose() {
    _customersSub?.cancel();
    super.dispose();
  }
}
