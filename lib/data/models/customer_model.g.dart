// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerModelAdapter extends TypeAdapter<CustomerModel> {
  @override
  final int typeId = 0;

  @override
  CustomerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerModel(
      id: fields[0] as String,
      name: fields[1] as String,
      fatherName: fields[2] as String,
      mobile: fields[3] as String,
      cnic: fields[4] as String,
      address: fields[5] as String,
      productName: fields[6] as String,
      price: fields[7] as double,
      downPayment: fields[8] as double,
      totalInstallments: fields[9] as int,
      installmentAmount: fields[10] as double,
      startDate: fields[11] as DateTime,
      referenceName: fields[12] as String,
      referencePhone: fields[13] as String,
      shopName: fields[14] as String,
      notes: fields[15] as String,
      images: (fields[16] as List).cast<String>(),
      totalMonths: fields[17] as int,
      isPaid: fields[18] as bool,
      securityDetails: fields[19] as String,
      completedInstallments: fields[20] as int,
      paidAmount: fields[21] as double,
      lastPaidMonth: fields[22] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fatherName)
      ..writeByte(3)
      ..write(obj.mobile)
      ..writeByte(4)
      ..write(obj.cnic)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.productName)
      ..writeByte(7)
      ..write(obj.price)
      ..writeByte(8)
      ..write(obj.downPayment)
      ..writeByte(9)
      ..write(obj.totalInstallments)
      ..writeByte(10)
      ..write(obj.installmentAmount)
      ..writeByte(11)
      ..write(obj.startDate)
      ..writeByte(12)
      ..write(obj.referenceName)
      ..writeByte(13)
      ..write(obj.referencePhone)
      ..writeByte(14)
      ..write(obj.shopName)
      ..writeByte(15)
      ..write(obj.notes)
      ..writeByte(16)
      ..write(obj.images)
      ..writeByte(17)
      ..write(obj.totalMonths)
      ..writeByte(18)
      ..write(obj.isPaid)
      ..writeByte(19)
      ..write(obj.securityDetails)
      ..writeByte(20)
      ..write(obj.completedInstallments)
      ..writeByte(21)
      ..write(obj.paidAmount)
      ..writeByte(22)
      ..write(obj.lastPaidMonth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
