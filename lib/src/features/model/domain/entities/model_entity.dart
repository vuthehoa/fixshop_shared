import 'package:equatable/equatable.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';

/// Model máy — master data entity for the product catalog.
class ModelEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String productFamilyId;
  final String? description;
  final String? imageUrl;

  /// Device-side hardware model identifiers (e.g. `"iPhone16,2"`) the future
  /// customer app can use to auto-detect this model. Additive/optional —
  /// legacy documents without this field resolve to `[]`, never `null` and
  /// never a fabricated guess. Phase 3 populates this only where a reliable
  /// mapping is known; an empty list is expected and valid for most models.
  final List<String> hardwareIdentifiers;

  final CatalogStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  const ModelEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.productFamilyId,
    this.description,
    this.imageUrl,
    this.hardwareIdentifiers = const [],
    this.status = CatalogStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  bool get isActive => status == CatalogStatus.active;
  bool get isArchived => status == CatalogStatus.archived;

  ModelEntity copyWith({
    String? id,
    String? code,
    String? name,
    String? productFamilyId,
    String? description,
    String? imageUrl,
    List<String>? hardwareIdentifiers,
    CatalogStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return ModelEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      productFamilyId: productFamilyId ?? this.productFamilyId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      hardwareIdentifiers: hardwareIdentifiers ?? this.hardwareIdentifiers,
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
        productFamilyId,
        description,
        imageUrl,
        hardwareIdentifiers,
        status,
        createdAt,
        updatedAt,
        createdBy,
      ];
}
