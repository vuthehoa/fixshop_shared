import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/entities/manufacturer_entity.dart';

class ManufacturerModel extends ManufacturerEntity {
  const ManufacturerModel({
    required super.id,
    required super.code,
    required super.name,
    super.description,
    super.logoUrl,
    super.status,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
  });

  factory ManufacturerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ManufacturerModel(
      id: doc.id,
      code: data['code'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      logoUrl: data['logoUrl'] as String?,
      status: CatalogStatus.fromName(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String?,
    );
  }

  factory ManufacturerModel.fromEntity(ManufacturerEntity entity) {
    return ManufacturerModel(
      id: entity.id,
      code: entity.code,
      name: entity.name,
      description: entity.description,
      logoUrl: entity.logoUrl,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  /// Update payload — never touches createdAt/createdBy/status.
  Map<String, dynamic> toUpdateMap() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
