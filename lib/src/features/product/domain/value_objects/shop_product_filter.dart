import 'package:equatable/equatable.dart';

import '../enums/product_condition.dart';
import '../enums/product_status.dart';

/// Query shape for `products`. Server-applied where clauses stay narrow
/// (equality on the denormalized relation ids + status/publish flags); the
/// free-text [searchQuery] and the price range are applied client-side on
/// the fetched page, matching every other FixShop catalog data source.
class ShopProductFilter extends Equatable {
  final String? searchQuery;
  final ProductStatus? status;
  final ProductCondition? condition;
  final String? manufacturerId;
  final String? productFamilyId;
  final String? modelId;
  final int? minPrice;
  final int? maxPrice;

  /// When true the query is constrained to `isPublished == true` — the
  /// mobile shopfront always sets this; the CMS list never does.
  final bool publishedOnly;

  /// When true only in-stock rows (`quantity > 0`) are returned — mobile
  /// shopfront default.
  final bool inStockOnly;

  final int pageSize;

  const ShopProductFilter({
    this.searchQuery,
    this.status,
    this.condition,
    this.manufacturerId,
    this.productFamilyId,
    this.modelId,
    this.minPrice,
    this.maxPrice,
    this.publishedOnly = false,
    this.inStockOnly = false,
    this.pageSize = 20,
  });

  /// The exact filter the mobile app must use.
  const ShopProductFilter.shopfront({
    this.searchQuery,
    this.condition,
    this.manufacturerId,
    this.productFamilyId,
    this.modelId,
    this.minPrice,
    this.maxPrice,
    this.pageSize = 20,
  })  : status = ProductStatus.active,
        publishedOnly = true,
        inStockOnly = true;

  ShopProductFilter copyWith({
    String? searchQuery,
    ProductStatus? status,
    ProductCondition? condition,
    String? manufacturerId,
    String? productFamilyId,
    String? modelId,
    int? minPrice,
    int? maxPrice,
    bool? publishedOnly,
    bool? inStockOnly,
    int? pageSize,
    bool clearSearch = false,
    bool clearStatus = false,
    bool clearCondition = false,
    bool clearManufacturer = false,
    bool clearProductFamily = false,
    bool clearModel = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return ShopProductFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      status: clearStatus ? null : (status ?? this.status),
      condition: clearCondition ? null : (condition ?? this.condition),
      manufacturerId:
          clearManufacturer ? null : (manufacturerId ?? this.manufacturerId),
      productFamilyId:
          clearProductFamily ? null : (productFamilyId ?? this.productFamilyId),
      modelId: clearModel ? null : (modelId ?? this.modelId),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      publishedOnly: publishedOnly ?? this.publishedOnly,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        status,
        condition,
        manufacturerId,
        productFamilyId,
        modelId,
        minPrice,
        maxPrice,
        publishedOnly,
        inStockOnly,
        pageSize,
      ];

  // Named fields in logs — a bare `ShopProductFilter(null, null, null, ...)`
  // tells a debugger nothing about which filter failed.
  @override
  String toString() => 'ShopProductFilter('
      'searchQuery: $searchQuery, status: ${status?.name}, '
      'condition: ${condition?.name}, manufacturerId: $manufacturerId, '
      'productFamilyId: $productFamilyId, modelId: $modelId, '
      'minPrice: $minPrice, maxPrice: $maxPrice, '
      'publishedOnly: $publishedOnly, inStockOnly: $inStockOnly, '
      'pageSize: $pageSize)';
}
