import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/entities/service_category_entity.dart';

class ServiceCategoryModel extends ServiceCategoryEntity {
  const ServiceCategoryModel({
    required super.id,
    required super.code,
    required super.name,
    super.description,
    super.enabled,
    super.order,
    super.status,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
  });

  factory ServiceCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceCategoryModel(
      id: doc.id,
      code: data['code'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      // Missing on legacy CMS docs → default true so nothing already live
      // silently disappears from the customer app the moment this field ships.
      enabled: data['enabled'] as bool? ?? true,
      order: (data['order'] as num?)?.toInt() ?? 0,
      status: CatalogStatus.fromName(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String?,
    );
  }

  factory ServiceCategoryModel.fromEntity(ServiceCategoryEntity entity) {
    return ServiceCategoryModel(
      id: entity.id,
      code: entity.code,
      name: entity.name,
      description: entity.description,
      enabled: entity.enabled,
      order: entity.order,
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
      'enabled': enabled,
      'order': order,
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
      'enabled': enabled,
      'order': order,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
