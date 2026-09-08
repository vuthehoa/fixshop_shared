import 'package:equatable/equatable.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';
import 'repair_service_variant_entity.dart';

/// Dịch vụ sửa chữa — master data entity for the product catalog.
///
/// [categoryId] is nullable to stay backward-compatible with documents
/// written before Phase 2 (no category concept existed yet). A service with
/// `categoryId == null` or `variants.isEmpty` is never customer-bookable —
/// see [isBookingReady] — but it is never rewritten with a fake category or
/// fake variant just to satisfy that condition.
class RepairServiceEntity extends Equatable {
  final String id;
  final String? categoryId;
  final String modelId;
  final String name;
  final String? description;
  final bool enabled;
  final int order;
  final List<RepairServiceVariantEntity> variants;
  final CatalogStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  const RepairServiceEntity({
    required this.id,
    this.categoryId,
    required this.modelId,
    required this.name,
    this.description,
    this.enabled = true,
    this.order = 0,
    this.variants = const [],
    this.status = CatalogStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  bool get isActive => status == CatalogStatus.active;
  bool get isArchived => status == CatalogStatus.archived;

  List<RepairServiceVariantEntity> get activeVariants =>
      variants.where((v) => v.enabled).toList();

  /// A service is only eligible for customer booking once it has a category,
  /// is active/enabled, and has at least one enabled variant. Legacy
  /// documents (no categoryId, no variants) fail this on purpose instead of
  /// being silently patched with placeholder data.
  bool get isBookingReady =>
      isActive && enabled && categoryId != null && activeVariants.isNotEmpty;

  /// Lowest price among enabled variants, or `null` when there are none.
  /// `0` is a legitimate price and participates in the comparison like any
  /// other value — never filtered out.
  int? get minimumPrice {
    final prices = activeVariants.map((v) => v.price).toList();
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) => a < b ? a : b);
  }

  /// Pure domain validation — no Firestore access. Returns a human-readable
  /// error per violation, or an empty list when the document is valid.
  /// Shared by the CMS form (pre-submit) and the datasource (pre-write).
  List<String> validationErrors() {
    final errors = <String>[];
    final seenVariantCodes = <String>{};

    for (final variant in variants) {
      if (variant.price < 0) {
        errors.add('Giá của biến thể "${variant.name}" không được âm.');
      }
      if (!seenVariantCodes.add(variant.code)) {
        errors.add('Mã biến thể "${variant.code}" bị trùng trong dịch vụ này.');
      }

      final seenAddonCodes = <String>{};
      for (final addon in variant.addons) {
        if (addon.price < 0) {
          errors.add('Giá add-on "${addon.name}" không được âm.');
        }
        if (!seenAddonCodes.add(addon.code)) {
          errors.add(
            'Mã add-on "${addon.code}" bị trùng trong biến thể "${variant.name}".',
          );
        }
      }
    }

    if (order < 0) errors.add('Thứ tự hiển thị không được âm.');

    return errors;
  }

  RepairServiceEntity copyWith({
    String? id,
    String? categoryId,
    String? modelId,
    String? name,
    String? description,
    bool? enabled,
    int? order,
    List<RepairServiceVariantEntity>? variants,
    CatalogStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return RepairServiceEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      modelId: modelId ?? this.modelId,
      name: name ?? this.name,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
      variants: variants ?? this.variants,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        modelId,
        name,
        description,
        enabled,
        order,
        variants,
        status,
        createdAt,
        updatedAt,
        createdBy,
      ];
}
