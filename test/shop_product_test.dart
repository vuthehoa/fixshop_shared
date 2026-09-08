import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductCondition', () {
    test('wire names round-trip', () {
      for (final c in ProductCondition.values) {
        expect(ProductCondition.fromName(c.wireName), c);
      }
    });

    test('unknown / null falls back to good', () {
      expect(ProductCondition.fromName(null), ProductCondition.good);
      expect(ProductCondition.fromName('nonsense'), ProductCondition.good);
    });
  });

  group('ProductStatus', () {
    test('wire names round-trip', () {
      for (final s in ProductStatus.values) {
        expect(ProductStatus.fromName(s.wireName), s);
      }
    });

    test('sold_out wire value maps correctly', () {
      expect(ProductStatus.soldOut.wireName, 'sold_out');
      expect(ProductStatus.fromName('sold_out'), ProductStatus.soldOut);
    });

    test('only active is shoppable', () {
      expect(ProductStatus.active.isShoppable, isTrue);
      for (final s
          in ProductStatus.values.where((s) => s != ProductStatus.active)) {
        expect(s.isShoppable, isFalse);
      }
    });
  });

  ShopProductEntity build({
    int listingPrice = 15000000,
    int? originalPrice = 27990000,
    int quantity = 1,
    List<ProductImage> images = const [],
    bool isPublished = false,
    ProductStatus status = ProductStatus.draft,
  }) {
    final now = DateTime(2026, 9, 4, 10);
    return ShopProductEntity(
      id: 'prod-1',
      manufacturerId: 'apple',
      productFamilyId: 'iphone',
      modelId: 'iphone_14_pro',
      manufacturerName: 'Apple',
      productFamilyName: 'iPhone',
      modelName: 'iPhone 14 Pro',
      title: 'iPhone 14 Pro 128GB - Like New',
      shortDescription: 'Máy đẹp',
      description: 'Chi tiết',
      condition: ProductCondition.likeNew,
      conditionNote: 'Xước nhẹ viền trái',
      attributes: const {'Màu sắc': 'Deep Purple', 'Dung lượng': '128GB'},
      listingPrice: listingPrice,
      originalPrice: originalPrice,
      quantity: quantity,
      images: images,
      thumbnailUrl: images.isEmpty ? null : images.first.url,
      status: status,
      isPublished: isPublished,
      createdBy: 'staff-1',
      updatedBy: 'staff-1',
      createdAt: now,
      updatedAt: now,
    );
  }

  const image = ProductImage(
    url: 'https://storage/products/prod-1/images/a.webp',
    storagePath: 'products/prod-1/images/a.webp',
    sortOrder: 0,
  );

  group('ShopProductModel serialization', () {
    test('toCreateMap keeps price as an integer, never a formatted string', () {
      final map = ShopProductModel.fromEntity(build()).toCreateMap();
      expect(map['listingPrice'], 15000000);
      expect(map['listingPrice'], isA<int>());
      expect(map['originalPrice'], 27990000);
      expect(map['condition'], 'like_new');
      expect(map['status'], 'draft');
      expect(map['isPublished'], false);
      expect(map['attributes'], containsPair('Dung lượng', '128GB'));
    });

    test('image maps carry url + storagePath + re-numbered sortOrder', () {
      final entity = build(images: [
        image.copyWith(sortOrder: 5),
        image.copyWith(
          url: 'https://storage/b.webp',
          storagePath: 'products/prod-1/images/b.webp',
          sortOrder: 2,
        ),
      ]);
      final maps =
          (ShopProductModel.fromEntity(entity).toCreateMap()['images'] as List)
              .cast<Map<String, dynamic>>();
      // Re-sorted by original sortOrder then re-indexed 0..n.
      expect(maps[0]['storagePath'], 'products/prod-1/images/b.webp');
      expect(maps[0]['sortOrder'], 0);
      expect(maps[1]['sortOrder'], 1);
    });
  });

  group('ShopProductValidation', () {
    test('draft rules: price must be > 0', () {
      final v = ShopProductValidation.forDraft(build(listingPrice: 0));
      expect(v.isValid, isFalse);
      expect(v['listingPrice'], isNotNull);
    });

    test('draft rules: originalPrice must be >= listingPrice when set', () {
      final v = ShopProductValidation.forDraft(
        build(listingPrice: 20000000, originalPrice: 10000000),
      );
      expect(v['originalPrice'], isNotNull);
    });

    test('a valid draft passes with no images', () {
      final v = ShopProductValidation.forDraft(build());
      expect(v.isValid, isTrue);
    });

    test('publish rules additionally require >= 1 image', () {
      final noImages = ShopProductValidation.forPublish(build());
      expect(noImages.isValid, isFalse);
      expect(noImages['images'], isNotNull);

      final withImage =
          ShopProductValidation.forPublish(build(images: const [image]));
      expect(withImage.isValid, isTrue);
    });

    test('publish rules require quantity >= 1', () {
      final v = ShopProductValidation.forPublish(
        build(images: const [image], quantity: 0),
      );
      expect(v['quantity'], isNotNull);
    });
  });

  group('ShopProductEntity derived', () {
    test('isShoppable == published + active + in stock', () {
      expect(
        build(isPublished: true, status: ProductStatus.active, quantity: 1)
            .isShoppable,
        isTrue,
      );
      expect(
        build(isPublished: true, status: ProductStatus.active, quantity: 0)
            .isShoppable,
        isFalse,
      );
      expect(
        build(isPublished: false, status: ProductStatus.active).isShoppable,
        isFalse,
      );
    });

    test('discountPercent', () {
      expect(
          build(listingPrice: 15000000, originalPrice: 30000000)
              .discountPercent,
          50);
      expect(build(originalPrice: null).discountPercent, isNull);
      expect(
          build(listingPrice: 100, originalPrice: 90).discountPercent, isNull);
    });
  });
}
