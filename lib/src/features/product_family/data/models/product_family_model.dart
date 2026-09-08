import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/entities/product_family_entity.dart';

class ProductFamilyModel extends ProductFamilyEntity {
  const ProductFamilyModel({
    required super.id,
    required super.code,
    required super.name,
    required super.manufacturerId,
    super.description,
    super.imageUrl,
    super.status,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
  });

  factory ProductFamilyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductFamilyModel(
      id: doc.id,
      code: data['code'] as String? ?? '',
      name: data['name'] as String? ?? '',
      manufacturerId: data['manufacturerId'] as String? ?? '',
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      status: CatalogStatus.fromName(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String?,
    );
  }

  factory ProductFamilyModel.fromEntity(ProductFamilyEntity entity) {
    return ProductFamilyModel(
      id: entity.id,
      code: entity.code,
      name: entity.name,
      manufacturerId: entity.manufacturerId,
      description: entity.description,
      imageUrl: entity.imageUrl,
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
      'manufacturerId': manufacturerId,
      'description': description,
      'imageUrl': imageUrl,
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
      'manufacturerId': manufacturerId,
      'description': description,
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
