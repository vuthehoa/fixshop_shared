import 'package:equatable/equatable.dart';

enum UserRole {
  admin,
  manager,
  reception,
  technician,
  customer;

  bool get isCmsUser =>
      this == admin ||
      this == manager ||
      this == reception ||
      this == technician;

  bool get canManageEmployees => this == admin || this == manager;

  bool get canManageRepairs =>
      this == admin ||
      this == manager ||
      this == reception ||
      this == technician;

  String get displayName => switch (this) {
        UserRole.admin => 'Quản trị viên',
        UserRole.manager => 'Quản lý',
        UserRole.reception => 'Lễ tân',
        UserRole.technician => 'Kỹ thuật viên',
        UserRole.customer => 'Khách hàng',
      };
}

enum UserStatus {
  active,
  disabled,
  deleted;

  String get displayName => switch (this) {
        UserStatus.active => 'Đang hoạt động',
        UserStatus.disabled => 'Bị vô hiệu hoá',
        UserStatus.deleted => 'Đã xoá',
      };
}

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? createdBy;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.role,
    this.status = UserStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.createdBy,
    this.lastLoginAt,
  });

  bool get isActive => status == UserStatus.active;
  bool get isDisabled => status == UserStatus.disabled;
  bool get isDeleted => status == UserStatus.deleted;

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    UserRole? role,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    String? createdBy,
    DateTime? lastLoginAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      createdBy: createdBy ?? this.createdBy,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        phoneNumber,
        role,
        status,
        createdAt,
        updatedAt,
        address,
        dateOfBirth,
        gender,
        createdBy,
        lastLoginAt,
      ];
}
