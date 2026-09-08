import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/entities/repair_service_entity.dart';
import '../../domain/entities/repair_service_variant_entity.dart';

class RepairServiceModel extends RepairServiceEntity {
  const RepairServiceModel({
    required super.id,
    super.categoryId,
    required super.modelId,
    required super.name,
    super.description,
    super.enabled,
    super.order,
    super.variants,
    super.status,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
  });

  factory RepairServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RepairServiceModel(
      id: doc.id,
      // Legacy documents predate Sprint "categoryId" — stays null rather
      // than a fabricated value, which keeps isBookingReady() correctly
      // false for them instead of silently faking readiness.
      categoryId: data['categoryId'] as String?,
      modelId: data['modelId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      // Missing on legacy docs → default true for CMS-side compatibility
      // (Phase 2 spec §11): the record itself isn't hidden by this field,
      // isBookingReady() still keeps it out of customer results because it
      // has no categoryId/variants yet.
      enabled: data['enabled'] as bool? ?? true,
      order: (data['order'] as num?)?.toInt() ?? 0,
      // Missing on legacy docs → [] (never a fabricated placeholder variant).
      variants: ((data['variants'] as List<dynamic>?) ?? const [])
          .map((raw) => RepairServiceVariantEntity.fromMap(
                Map<String, dynamic>.from(raw as Map),
              ))
          .toList(),
      status: CatalogStatus.fromName(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String?,
    );
  }

  factory RepairServiceModel.fromEntity(RepairServiceEntity entity) {
    return RepairServiceModel(
      id: entity.id,
      categoryId: entity.categoryId,
      modelId: entity.modelId,
      name: entity.name,
      description: entity.description,
      enabled: entity.enabled,
      order: entity.order,
      variants: entity.variants,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'modelId': modelId,
      'name': name,
      'description': description,
      'enabled': enabled,
      'order': order,
      'variants': variants.map((v) => v.toMap()).toList(),
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  /// Update payload — never touches createdAt/createdBy/status.
  Map<String, dynamic> toUpdateMap() {
    return {
      'categoryId': categoryId,
      'modelId': modelId,
      'name': name,
      'description': description,
      'enabled': enabled,
      'order': order,
      'variants': variants.map((v) => v.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
