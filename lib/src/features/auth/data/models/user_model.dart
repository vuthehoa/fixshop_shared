import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.photoUrl,
    super.phoneNumber,
    required super.role,
    super.status,
    required super.createdAt,
    required super.updatedAt,
    super.address,
    super.dateOfBirth,
    super.gender,
    super.createdBy,
    super.lastLoginAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      role: _parseRole(data['role'] as String?),
      status: _parseStatus(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      address: data['address'] as String?,
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: data['gender'] as String?,
      createdBy: data['createdBy'] as String?,
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      phoneNumber: entity.phoneNumber,
      role: entity.role,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      address: entity.address,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      createdBy: entity.createdBy,
      lastLoginAt: entity.lastLoginAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'address': address,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'createdBy': createdBy,
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'address': address,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static UserRole _parseRole(String? value) => switch (value) {
        'admin' => UserRole.admin,
        'manager' => UserRole.manager,
        'reception' => UserRole.reception,
        'technician' => UserRole.technician,
        'customer' => UserRole.customer,
        _ => UserRole.customer,
      };

  static UserStatus _parseStatus(String? value) => switch (value) {
        'active' => UserStatus.active,
        'disabled' => UserStatus.disabled,
        'deleted' => UserStatus.deleted,
        // backward compat for legacy documents
        'inactive' => UserStatus.disabled,
        'suspended' => UserStatus.disabled,
        _ => UserStatus.active,
      };
}
