import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/entities/variant_entity.dart';

class VariantModel extends VariantEntity {
  const VariantModel({
    required super.id,
    required super.name,
    required super.modelId,
    super.status,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
  });

  factory VariantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VariantModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      modelId: data['modelId'] as String? ?? '',
      status: CatalogStatus.fromName(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String?,
    );
  }

  factory VariantModel.fromEntity(VariantEntity entity) {
    return VariantModel(
      id: entity.id,
      name: entity.name,
      modelId: entity.modelId,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'modelId': modelId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  /// Update payload — never touches createdAt/createdBy/status.
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'modelId': modelId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
