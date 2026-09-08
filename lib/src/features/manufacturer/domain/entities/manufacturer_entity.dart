import 'package:equatable/equatable.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';

/// Hãng sản xuất — master data entity for the product catalog.
class ManufacturerEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String? logoUrl;
  final CatalogStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  const ManufacturerEntity({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.logoUrl,
    this.status = CatalogStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  bool get isActive => status == CatalogStatus.active;
  bool get isArchived => status == CatalogStatus.archived;

  ManufacturerEntity copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    String? logoUrl,
    CatalogStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return ManufacturerEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
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
        description,
        logoUrl,
        status,
        createdAt,
        updatedAt,
        createdBy,
      ];
}
