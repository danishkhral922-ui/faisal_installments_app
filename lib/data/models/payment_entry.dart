class PaymentEntry {
  final int installmentNo;
  final DateTime paidDate;
  final double amount;

  const PaymentEntry({
    required this.installmentNo,
    required this.paidDate,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'installmentNo': installmentNo,
      'paidDate': paidDate.toIso8601String(),
      'amount': amount,
    };
  }

  factory PaymentEntry.fromMap(Map<String, dynamic> map) {
    final installmentNo = (map['installmentNo'] ?? 0) as int;
    final amount = (map['amount'] ?? 0).toDouble();

    final paidDateRaw = map['paidDate'];
    final paidDate = paidDateRaw is DateTime
        ? paidDateRaw
        : DateTime.tryParse(paidDateRaw?.toString() ?? '') ?? DateTime.now();

    return PaymentEntry(
      installmentNo: installmentNo,
      paidDate: paidDate,
      amount: amount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentEntry) return false;
    return installmentNo == other.installmentNo &&
        paidDate == other.paidDate &&
        amount == other.amount;
  }

  @override
  int get hashCode => Object.hash(installmentNo, paidDate, amount);
}
