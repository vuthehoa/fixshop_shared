import 'package:equatable/equatable.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';

/// Nhóm dịch vụ — groups repair services for customer-facing browsing
/// (e.g. "Pin iPhone", "Ép kính iPhone"). Sits above [ModelEntity] in the
/// business hierarchy but is stored as its own top-level collection since a
/// category cuts across many device models, mirroring how RepairService
/// already references `modelId` directly rather than being nested under it.
///
/// [status] and [enabled] are deliberately separate concepts:
///   status = archived → record removed from CMS active management (soft
///                        delete, reversible via restore).
///   enabled = false   → record still active in the CMS but must not be
///                        shown to the customer app (a temporary toggle).
class ServiceCategoryEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String? description;
  final bool enabled;
  final int order;
  final CatalogStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  const ServiceCategoryEntity({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.enabled = true,
    this.order = 0,
    this.status = CatalogStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  bool get isActive => status == CatalogStatus.active;
  bool get isArchived => status == CatalogStatus.archived;

  ServiceCategoryEntity copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    bool? enabled,
    int? order,
    CatalogStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return ServiceCategoryEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
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
        enabled,
        order,
        status,
        createdAt,
        updatedAt,
        createdBy,
      ];
}
