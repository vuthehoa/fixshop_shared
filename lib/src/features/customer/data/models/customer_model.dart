import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.customerCode,
    required super.fullName,
    required super.phone,
    super.email,
    super.gender,
    super.birthday,
    super.address,
    super.province,
    super.district,
    super.ward,
    super.avatarUrl,
    super.status,
    super.note,
    super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      id: doc.id,
      customerCode: data['customerCode'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String?,
      gender: CustomerGender.fromName(data['gender'] as String?),
      birthday: (data['birthday'] as Timestamp?)?.toDate(),
      address: data['address'] as String?,
      province: data['province'] as String?,
      district: data['district'] as String?,
      ward: data['ward'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      status: CatalogStatus.fromName(data['status'] as String?),
      note: data['note'] as String?,
      createdBy: data['createdBy'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory CustomerModel.fromEntity(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      customerCode: entity.customerCode,
      fullName: entity.fullName,
      phone: entity.phone,
      email: entity.email,
      gender: entity.gender,
      birthday: entity.birthday,
      address: entity.address,
      province: entity.province,
      district: entity.district,
      ward: entity.ward,
      avatarUrl: entity.avatarUrl,
      status: entity.status,
      note: entity.note,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerCode': customerCode,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'gender': gender.name,
      'birthday': birthday == null ? null : Timestamp.fromDate(birthday!),
      'address': address,
      'province': province,
      'district': district,
      'ward': ward,
      'avatarUrl': avatarUrl,
      'status': status.name,
      'note': note,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
    };
  }

  /// Update payload — never touches createdAt/createdBy/status/deletedAt.
  /// Status and deletedAt are only ever changed via archive/restore.
  Map<String, dynamic> toUpdateMap() {
    return {
      'customerCode': customerCode,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'gender': gender.name,
      'birthday': birthday == null ? null : Timestamp.fromDate(birthday!),
      'address': address,
      'province': province,
      'district': district,
      'ward': ward,
      'avatarUrl': avatarUrl,
      'note': note,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
