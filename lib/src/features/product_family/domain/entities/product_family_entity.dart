import 'package:equatable/equatable.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';

/// Dòng sản phẩm — master data entity for the product catalog.
class ProductFamilyEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String manufacturerId;
  final String? description;
  final String? imageUrl;
  final CatalogStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  const ProductFamilyEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.manufacturerId,
    this.description,
    this.imageUrl,
    this.status = CatalogStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  bool get isActive => status == CatalogStatus.active;
  bool get isArchived => status == CatalogStatus.archived;

  ProductFamilyEntity copyWith({
    String? id,
    String? code,
    String? name,
    String? manufacturerId,
    String? description,
    String? imageUrl,
    CatalogStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return ProductFamilyEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      manufacturerId: manufacturerId ?? this.manufacturerId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        manufacturerId,
        description,
        imageUrl,
        status,
        createdAt,
        updatedAt,
        createdBy,
      ];
}
