import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product_image.dart';
import '../../domain/entities/shop_product_entity.dart';
import '../../domain/enums/product_condition.dart';
import '../../domain/enums/product_status.dart';

class ProductImageModel extends ProductImage {
  const ProductImageModel({
    required super.url,
    required super.storagePath,
    required super.sortOrder,
  });

  factory ProductImageModel.fromMap(
      Map<String, dynamic> map, int fallbackOrder) {
    return ProductImageModel(
      url: map['url'] as String? ?? '',
      storagePath: map['storagePath'] as String? ?? '',
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? fallbackOrder,
    );
  }

  factory ProductImageModel.fromEntity(ProductImage image) => ProductImageModel(
        url: image.url,
        storagePath: image.storagePath,
        sortOrder: image.sortOrder,
      );

  Map<String, dynamic> toMap() => {
        'url': url,
        'storagePath': storagePath,
        'sortOrder': sortOrder,
      };
}

class ShopProductModel extends ShopProductEntity {
  const ShopProductModel({
    required super.id,
    required super.manufacturerId,
    required super.productFamilyId,
    required super.modelId,
    required super.manufacturerName,
    required super.productFamilyName,
    required super.modelName,
    required super.title,
    super.shortDescription,
    super.description,
    super.condition,
    super.conditionNote,
    super.attributes,
    required super.listingPrice,
    super.originalPrice,
    super.quantity,
    super.images,
    super.thumbnailUrl,
    super.status,
    super.isPublished,
    super.sku,
    super.slug,
    super.createdBy,
    super.updatedBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ShopProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawImages = (data['images'] as List<dynamic>?) ?? const [];
    final images = <ProductImage>[
      for (var i = 0; i < rawImages.length; i++)
        ProductImageModel.fromMap(
          Map<String, dynamic>.from(rawImages[i] as Map),
          i,
        ),
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return ShopProductModel(
      id: doc.id,
      manufacturerId: data['manufacturerId'] as String? ?? '',
      productFamilyId: data['productFamilyId'] as String? ?? '',
      modelId: data['modelId'] as String? ?? '',
      manufacturerName: data['manufacturerName'] as String? ?? '',
      productFamilyName: data['productFamilyName'] as String? ?? '',
      modelName: data['modelName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      shortDescription: data['shortDescription'] as String?,
      description: data['description'] as String?,
      condition: ProductCondition.fromName(data['condition'] as String?),
      conditionNote: data['conditionNote'] as String?,
      attributes: (data['attributes'] as Map<String, dynamic>?) ?? const {},
      listingPrice: (data['listingPrice'] as num?)?.toInt() ?? 0,
      originalPrice: (data['originalPrice'] as num?)?.toInt(),
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      images: images,
      thumbnailUrl: data['thumbnailUrl'] as String? ??
          (images.isNotEmpty ? images.first.url : null),
      status: ProductStatus.fromName(data['status'] as String?),
      isPublished: data['isPublished'] as bool? ?? false,
      sku: data['sku'] as String?,
      slug: data['slug'] as String?,
      createdBy: data['createdBy'] as String?,
      updatedBy: data['updatedBy'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ShopProductModel.fromEntity(ShopProductEntity e) => ShopProductModel(
        id: e.id,
        manufacturerId: e.manufacturerId,
        productFamilyId: e.productFamilyId,
        modelId: e.modelId,
        manufacturerName: e.manufacturerName,
        productFamilyName: e.productFamilyName,
        modelName: e.modelName,
        title: e.title,
        shortDescription: e.shortDescription,
        description: e.description,
        condition: e.condition,
        conditionNote: e.conditionNote,
        attributes: e.attributes,
        listingPrice: e.listingPrice,
        originalPrice: e.originalPrice,
        quantity: e.quantity,
        images: e.images,
        thumbnailUrl: e.thumbnailUrl,
        status: e.status,
        isPublished: e.isPublished,
        sku: e.sku,
        slug: e.slug,
        createdBy: e.createdBy,
        updatedBy: e.updatedBy,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  List<Map<String, dynamic>> _imageMaps() {
    final sorted = [...images]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return [
      for (var i = 0; i < sorted.length; i++)
        ProductImageModel.fromEntity(sorted[i].copyWith(sortOrder: i)).toMap(),
    ];
  }

  String? _thumbnail() {
    final sorted = [...images]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted.isEmpty ? null : sorted.first.url;
  }

  /// Full document — used on create. createdAt/updatedAt are server
  /// timestamps so listings never depend on the CMS machine's clock.
  Map<String, dynamic> toCreateMap() => {
        'manufacturerId': manufacturerId,
        'productFamilyId': productFamilyId,
        'modelId': modelId,
        'manufacturerName': manufacturerName,
        'productFamilyName': productFamilyName,
        'modelName': modelName,
        'title': title,
        'shortDescription': shortDescription,
        'description': description,
        'condition': condition.wireName,
        'conditionNote': conditionNote,
        'attributes': attributes,
        'listingPrice': listingPrice,
        'originalPrice': originalPrice,
        'quantity': quantity,
        'images': _imageMaps(),
        'thumbnailUrl': _thumbnail(),
        'status': status.wireName,
        'isPublished': isPublished,
        'sku': sku,
        'slug': slug,
        'createdBy': createdBy,
        'updatedBy': updatedBy,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  /// Update payload — never touches createdAt/createdBy. status/isPublished
  /// are included because the CMS edit form can legitimately change them
  /// (e.g. quantity → 0 auto-sets sold_out), but publish/unpublish has its
  /// own dedicated path that only writes those two keys.
  Map<String, dynamic> toUpdateMap() => {
        'manufacturerId': manufacturerId,
        'productFamilyId': productFamilyId,
        'modelId': modelId,
        'manufacturerName': manufacturerName,
        'productFamilyName': productFamilyName,
        'modelName': modelName,
        'title': title,
        'shortDescription': shortDescription,
        'description': description,
        'condition': condition.wireName,
        'conditionNote': conditionNote,
        'attributes': attributes,
        'listingPrice': listingPrice,
        'originalPrice': originalPrice,
        'quantity': quantity,
        'images': _imageMaps(),
        'thumbnailUrl': _thumbnail(),
        'status': status.wireName,
        'isPublished': isPublished,
        'sku': sku,
        'slug': slug,
        'updatedBy': updatedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
