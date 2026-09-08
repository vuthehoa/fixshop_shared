import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/entities/model_entity.dart';

class ModelModel extends ModelEntity {
  const ModelModel({
    required super.id,
    required super.code,
    required super.name,
    required super.productFamilyId,
    super.description,
    super.imageUrl,
    super.hardwareIdentifiers,
    super.status,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
  });

  factory ModelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModelModel(
      id: doc.id,
      code: data['code'] as String? ?? '',
      name: data['name'] as String? ?? '',
      productFamilyId: data['productFamilyId'] as String? ?? '',
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      // Legacy documents predate this field — [] rather than a fabricated
      // guess, matching the "never invent hardware identifiers" rule.
      hardwareIdentifiers:
          (data['hardwareIdentifiers'] as List<dynamic>?)?.cast<String>() ??
              const [],
      status: CatalogStatus.fromName(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String?,
    );
  }

  factory ModelModel.fromEntity(ModelEntity entity) {
    return ModelModel(
      id: entity.id,
      code: entity.code,
      name: entity.name,
      productFamilyId: entity.productFamilyId,
      description: entity.description,
      imageUrl: entity.imageUrl,
      hardwareIdentifiers: entity.hardwareIdentifiers,
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
      'productFamilyId': productFamilyId,
      'description': description,
      'imageUrl': imageUrl,
      'hardwareIdentifiers': hardwareIdentifiers,
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
      'productFamilyId': productFamilyId,
      'description': description,
      'imageUrl': imageUrl,
      'hardwareIdentifiers': hardwareIdentifiers,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
