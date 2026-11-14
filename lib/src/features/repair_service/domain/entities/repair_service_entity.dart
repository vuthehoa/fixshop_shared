import 'package:equatable/equatable.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../services/catalog_eligibility.dart';
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

  /// `catalog_eligibility.offers` for this service (contract §2): every
  /// enabled variant with a non-empty code and a valid integer VND price > 0,
  /// keyed by code — or `{}` unless the service is active AND enabled.
  Map<String, int> get bookableOffers => computeEligibilityOffers(
        status: status,
        enabled: enabled,
        variants: variants,
      );

  /// Enabled variants that can actually be booked (valid price > 0, code).
  List<RepairServiceVariantEntity> get bookableVariants =>
      variants.where(isBookableVariant).toList();

  /// Computed display state — "Đặt lịch được" / "Chưa có giá hợp lệ" /
  /// "Tạm ngưng nhận đặt lịch" / "Đang ẩn". Never stored.
  RepairServiceBookability get bookability => computeBookability(
        status: status,
        enabled: enabled,
        variants: variants,
      );

  /// A service is only eligible for customer booking once it has a category,
  /// is active/enabled, and has at least one enabled variant with a VALID
  /// price (integer VND > 0 — `0`/empty means "chưa có giá", never free;
  /// see the eligibility contract). Legacy documents (no categoryId, no
  /// variants) fail this on purpose instead of being silently patched with
  /// placeholder data.
  bool get isBookingReady => categoryId != null && bookableOffers.isNotEmpty;

  /// Lowest VALID price among bookable variants, or `null` when there is
  /// none. A `0`/invalid price is "chưa có giá" (contract §1) and never
  /// participates — it must not surface as "từ 0đ".
  int? get minimumPrice {
    final prices = bookableVariants.map((v) => v.price).toList();
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
      // Contract §1: an ENABLED option must carry a real price (integer VND
      // > 0). A disabled option may keep 0 / no price.
      if (variant.enabled) {
        final label = variant.name.isEmpty ? variant.code : variant.name;
        if (variant.code.trim().isEmpty) {
          errors.add('Phương án đang bật "$label" phải có mã.');
        }
        if (!isValidOfferPrice(variant.price) && variant.price >= 0) {
          errors.add(
            'Phương án đang bật "$label" phải có giá lớn hơn 0 (VND). '
            'Giá 0 / để trống nghĩa là "Chưa có giá" — hãy nhập giá hoặc tắt phương án.',
          );
        }
        if (!isValidOfferCurrency(variant.currency)) {
          errors.add('Phương án "$label" phải dùng đơn vị VND.');
        }
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
