import 'package:hive/hive.dart';
part 'customer_model.g.dart';

@HiveType(typeId: 0)
class CustomerModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String fatherName;
  @HiveField(3)
  String mobile;
  @HiveField(4)
  String cnic;
  @HiveField(5)
  String address;
  @HiveField(6)
  String productName;
  @HiveField(7)
  double price;
  @HiveField(8)
  double downPayment;
  @HiveField(9)
  int totalInstallments;
  @HiveField(10)
  double installmentAmount;
  @HiveField(11)
  DateTime startDate;
  @HiveField(12)
  String referenceName;
  @HiveField(13)
  String referencePhone;
  @HiveField(14)
  String shopName;
  @HiveField(15)
  String notes;
  @HiveField(16)
  List<String> images;
  @HiveField(17)
  int totalMonths;
  @HiveField(18)
  bool isPaid;
  @HiveField(19)
  String securityDetails;
  @HiveField(20)
  int completedInstallments;
  @HiveField(21)
  double paidAmount;
  @HiveField(22)
  int lastPaidMonth;

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
