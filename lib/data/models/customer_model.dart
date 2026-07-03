class CustomerModel {
  String id;
  String name;
  String fatherName;
  String mobile;
  String cnic;
  String address;
  String productName;
  double price;
  double downPayment;
  int totalInstallments;
  double installmentAmount;
  DateTime startDate;
  String referenceName;
  String referencePhone;
  String shopName;
  String notes;
  List<String> images;
  int totalMonths;
  bool isPaid;
  String securityDetails;
  int completedInstallments;
  double paidAmount;
  int lastPaidMonth;

  // per-admin filtering (kept for compatibility)
  String adminUid;

  CustomerModel({
    required this.id,
    required this.name,
    required this.fatherName,
    required this.mobile,
    required this.cnic,
    required this.address,
    required this.productName,
    required this.price,
    required this.downPayment,
    required this.totalInstallments,
    required this.installmentAmount,
    required this.startDate,
    required this.referenceName,
    required this.referencePhone,
    required this.shopName,
    required this.notes,
    required this.images,
    required this.totalMonths,
    this.isPaid = false,
    this.securityDetails = '',
    this.completedInstallments = 0,
    this.paidAmount = 0,
    this.lastPaidMonth = 0,
    this.adminUid = '',
  });

  double get remainingAmount =>
      (price - downPayment - paidAmount).clamp(0.0, price - downPayment);

  int get remainingInstallments =>
      (totalMonths - completedInstallments).clamp(0, totalMonths);

  double get currentMonthlyInstallment {
    if (totalMonths <= 0 || remainingInstallments <= 0) {
      return 0.0;
    }
    return remainingAmount / remainingInstallments;
  }

  bool get hasInstallmentProgress =>
      completedInstallments > 0 || paidAmount > 0;
}
