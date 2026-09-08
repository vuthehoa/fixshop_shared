import 'package:equatable/equatable.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';

/// Phiên bản — master data entity for the product catalog.
class VariantEntity extends Equatable {
  final String id;
  final String name;
  final String modelId;
  final CatalogStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  const VariantEntity({
    required this.id,
    required this.name,
    required this.modelId,
    this.status = CatalogStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  bool get isActive => status == CatalogStatus.active;
  bool get isArchived => status == CatalogStatus.archived;

  VariantEntity copyWith({
    String? id,
    String? name,
    String? modelId,
    CatalogStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return VariantEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      modelId: modelId ?? this.modelId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        modelId,
        status,
        createdAt,
        updatedAt,
        createdBy,
      ];
}
