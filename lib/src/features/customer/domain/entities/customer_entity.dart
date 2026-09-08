import 'package:equatable/equatable.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';

enum CustomerGender {
  male,
  female,
  other;

  String get displayName => switch (this) {
        CustomerGender.male => 'Nam',
        CustomerGender.female => 'Nữ',
        CustomerGender.other => 'Khác',
      };

  static CustomerGender fromName(String? value) => switch (value) {
        'male' => CustomerGender.male,
        'female' => CustomerGender.female,
        _ => CustomerGender.other,
      };
}

/// Owner of every device — the foundation for Device, Warranty and Repair
/// Order in later sprints.
class CustomerEntity extends Equatable {
  final String id;
  final String customerCode;
  final String fullName;
  final String phone;
  final String? email;
  final CustomerGender gender;
  final DateTime? birthday;
  final String? address;
  final String? province;
  final String? district;
  final String? ward;
  final String? avatarUrl;
  final CatalogStatus status;
  final String? note;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const CustomerEntity({
    required this.id,
    required this.customerCode,
    required this.fullName,
    required this.phone,
    this.email,
    this.gender = CustomerGender.other,
    this.birthday,
    this.address,
    this.province,
    this.district,
    this.ward,
    this.avatarUrl,
    this.status = CatalogStatus.active,
    this.note,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isActive => status == CatalogStatus.active;
  bool get isArchived => status == CatalogStatus.archived;

  CustomerEntity copyWith({
    String? id,
    String? customerCode,
    String? fullName,
    String? phone,
    String? email,
    CustomerGender? gender,
    DateTime? birthday,
    String? address,
    String? province,
    String? district,
    String? ward,
    String? avatarUrl,
    CatalogStatus? status,
    String? note,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      customerCode: customerCode ?? this.customerCode,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      address: address ?? this.address,
      province: province ?? this.province,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      note: note ?? this.note,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerCode,
        fullName,
        phone,
        email,
        gender,
        birthday,
        address,
        province,
        district,
        ward,
        avatarUrl,
        status,
        note,
        createdBy,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
