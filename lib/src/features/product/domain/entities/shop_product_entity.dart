import 'package:equatable/equatable.dart';

import '../enums/product_condition.dart';
import '../enums/product_status.dart';
import 'product_image.dart';

/// A concrete second-hand item put up for sale on the FixShop mobile app.
///
/// This is a **commerce** entity, a completely different domain from the
/// master catalog (Manufacturer / ProductFamily / Model). One catalog
/// [Model] can back many distinct [ShopProductEntity] listings (an
/// "iPhone 14 Pro 128GB cũ" and an "iPhone 14 Pro 256GB cũ" are two
/// documents). It therefore lives in its own `products` collection and
/// never inside `models`.
///
/// [manufacturerId] / [productFamilyId] / [modelId] are the canonical
/// relations. [manufacturerName] / [productFamilyName] / [modelName] are
/// denormalized snapshots, copied from the referenced catalog records at
/// create/update time so a listing card and the mobile detail screen render
/// without an N+1 join. The ids remain the source of truth.
class ShopProductEntity extends Equatable {
  final String id;

  // ── Canonical catalog relations ─────────────────────────────────────────
  final String manufacturerId;
  final String productFamilyId;
  final String modelId;

  // ── Denormalized snapshots (display only) ───────────────────────────────
  final String manufacturerName;
  final String productFamilyName;
  final String modelName;

  // ── Listing content ────────────────────────────────────────────────────
  final String title;
  final String? shortDescription;
  final String? description;

  // ── Used-item condition ────────────────────────────────────────────────
  final ProductCondition condition;
  final String? conditionNote;

  /// First-class fields that search/filter needs live above; everything
  /// device-type-specific (batteryHealth, storage, color, imei, …) goes
  /// here so FixShop can list phones, laptops and accessories without a
  /// phone-shaped schema.
  final Map<String, dynamic> attributes;

  // ── Pricing (integer VND, never a formatted string) ─────────────────────
  final int listingPrice;
  final int? originalPrice;

  // ── Inventory ──────────────────────────────────────────────────────────
  final int quantity;

  // ── Media ──────────────────────────────────────────────────────────────
  final List<ProductImage> images;

  /// Convenience mirror of the first image's url, denormalized for fast
  /// list-card rendering. Always kept in sync with [images].
  final String? thumbnailUrl;

  // ── Publish / status ───────────────────────────────────────────────────
  final ProductStatus status;
  final bool isPublished;

  // ── Optional identifiers ───────────────────────────────────────────────
  final String? sku;
  final String? slug;

  // ── Audit ──────────────────────────────────────────────────────────────
  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShopProductEntity({
    required this.id,
    required this.manufacturerId,
    required this.productFamilyId,
    required this.modelId,
    required this.manufacturerName,
    required this.productFamilyName,
    required this.modelName,
    required this.title,
    this.shortDescription,
    this.description,
    this.condition = ProductCondition.good,
    this.conditionNote,
    this.attributes = const {},
    required this.listingPrice,
    this.originalPrice,
    this.quantity = 1,
    this.images = const [],
    this.thumbnailUrl,
    this.status = ProductStatus.draft,
    this.isPublished = false,
    this.sku,
    this.slug,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isArchived => status == ProductStatus.discontinued;

  /// Exactly the state the mobile shopfront query returns.
  bool get isShoppable => status == ProductStatus.selling && quantity > 0;

  List<ProductImage> get sortedImages {
    final copy = [...images]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return copy;
  }

  /// Discount percentage vs. [originalPrice], or `null` when there's no
  /// original price to compare against.
  int? get discountPercent {
    final original = originalPrice;
    if (original == null || original <= 0 || original <= listingPrice) {
      return null;
    }
    return (((original - listingPrice) / original) * 100).round();
  }

  ShopProductEntity copyWith({
    String? id,
    String? manufacturerId,
    String? productFamilyId,
    String? modelId,
    String? manufacturerName,
    String? productFamilyName,
    String? modelName,
    String? title,
    String? shortDescription,
    String? description,
    ProductCondition? condition,
    String? conditionNote,
    Map<String, dynamic>? attributes,
    int? listingPrice,
    int? originalPrice,
    int? quantity,
    List<ProductImage>? images,
    String? thumbnailUrl,
    ProductStatus? status,
    bool? isPublished,
    String? sku,
    String? slug,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShopProductEntity(
      id: id ?? this.id,
      manufacturerId: manufacturerId ?? this.manufacturerId,
      productFamilyId: productFamilyId ?? this.productFamilyId,
      modelId: modelId ?? this.modelId,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      productFamilyName: productFamilyName ?? this.productFamilyName,
      modelName: modelName ?? this.modelName,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      conditionNote: conditionNote ?? this.conditionNote,
      attributes: attributes ?? this.attributes,
      listingPrice: listingPrice ?? this.listingPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      images: images ?? this.images,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      isPublished: isPublished ?? this.isPublished,
      sku: sku ?? this.sku,
      slug: slug ?? this.slug,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        manufacturerId,
        productFamilyId,
        modelId,
        manufacturerName,
        productFamilyName,
        modelName,
        title,
        shortDescription,
        description,
        condition,
        conditionNote,
        attributes,
        listingPrice,
        originalPrice,
        quantity,
        images,
        thumbnailUrl,
        status,
        isPublished,
        sku,
        slug,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
      ];
}

/// Outcome of [ShopProductEntity] domain validation, run before any write
/// and before publish. Kept as a plain value object (not exceptions) so the
/// CMS wizard can show messages next to the offending field.
class ShopProductValidation {
  final Map<String, String> errors;

  const ShopProductValidation(this.errors);

  bool get isValid => errors.isEmpty;

  String? operator [](String field) => errors[field];

  /// Rules that must hold for ANY save (draft included).
  static ShopProductValidation forDraft(ShopProductEntity p) {
    final errors = <String, String>{};
    if (p.manufacturerId.trim().isEmpty) {
      errors['manufacturerId'] = 'Vui lòng chọn hãng sản xuất.';
    }
    if (p.productFamilyId.trim().isEmpty) {
      errors['productFamilyId'] = 'Vui lòng chọn dòng sản phẩm.';
    }
    if (p.modelId.trim().isEmpty) {
      errors['modelId'] = 'Vui lòng chọn model.';
    }
    if (p.title.trim().isEmpty) {
      errors['title'] = 'Vui lòng nhập tên sản phẩm.';
    }
    if (p.listingPrice <= 0) {
      errors['listingPrice'] = 'Giá bán phải lớn hơn 0.';
    }
    final original = p.originalPrice;
    if (original != null) {
      if (original < 0) {
        errors['originalPrice'] = 'Giá niêm yết không được âm.';
      } else if (original > 0 && original < p.listingPrice) {
        errors['originalPrice'] =
            'Giá niêm yết ban đầu phải lớn hơn hoặc bằng giá bán.';
      }
    }
    if (p.quantity < 0) {
      errors['quantity'] = 'Số lượng không được âm.';
    }
    return ShopProductValidation(errors);
  }

  /// Everything in [forDraft] plus what publishing additionally requires.
  static ShopProductValidation forPublish(ShopProductEntity p) {
    final errors = Map<String, String>.from(forDraft(p).errors);
    if (p.images.isEmpty) {
      errors['images'] = 'Cần ít nhất 1 hình ảnh để đăng bán.';
    }
    if (p.quantity < 1) {
      errors['quantity'] = 'Số lượng phải lớn hơn 0 để đăng bán.';
    }
    return ShopProductValidation(errors);
  }
}
