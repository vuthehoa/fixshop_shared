import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

RepairServiceEntity _service({
  String? categoryId = 'cat-1',
  bool enabled = true,
  CatalogStatus status = CatalogStatus.active,
  List<RepairServiceVariantEntity> variants = const [],
}) {
  final now = DateTime(2026, 1, 1);
  return RepairServiceEntity(
    id: 'svc-1',
    categoryId: categoryId,
    modelId: 'model-1',
    name: 'Thay phôi pin iPhone 13 Pro Max',
    enabled: enabled,
    status: status,
    variants: variants,
    createdAt: now,
    updatedAt: now,
  );
}

const _addonZeroPrice = RepairServiceAddonEntity(
  code: 'fix_3utools_duplicate',
  name: 'Fix trùng 3uTools',
  price: 0,
);

const _variant = RepairServiceVariantEntity(
  code: 'battery_cell_replace_fix_health',
  name: 'Thay phôi pin + fix % trong Cài đặt',
  price: 500000,
  addons: [_addonZeroPrice],
);

void main() {
  group('RepairServiceAddonEntity — price = 0 is valid, never "missing"', () {
    test('price = 0 round-trips through toMap/fromMap unchanged', () {
      final map = _addonZeroPrice.toMap();
      final restored = RepairServiceAddonEntity.fromMap(map);

      expect(restored.price, 0);
      expect(restored, _addonZeroPrice);
    });
  });

  group('RepairServiceVariantEntity', () {
    test('nested addons round-trip through toMap/fromMap', () {
      final map = _variant.toMap();
      final restored = RepairServiceVariantEntity.fromMap(map);

      expect(restored.addons, hasLength(1));
      expect(restored.addons.first.price, 0);
      expect(restored.price, 500000);
    });

    test('activeAddons excludes disabled add-ons', () {
      final variant = _variant.copyWith(addons: [
        _addonZeroPrice,
        _addonZeroPrice.copyWith(code: 'other', enabled: false),
      ]);

      expect(variant.activeAddons, hasLength(1));
    });
  });

  group('RepairServiceEntity — legacy compatibility', () {
    test('legacy document (no categoryId, no variants) is never booking-ready',
        () {
      final legacy = _service(categoryId: null, variants: const []);

      expect(legacy.isBookingReady, isFalse);
      expect(legacy.categoryId, isNull);
      expect(legacy.variants, isEmpty);
    });

    test('RepairServiceModel.fromFirestore does not crash on a legacy document',
        () {
      final doc = _MockDocumentSnapshot();
      when(() => doc.id).thenReturn('svc-legacy');
      when(() => doc.data()).thenReturn({
        'name': 'Ép kính iPhone X',
        'modelId': 'model-1',
        'status': 'active',
        // categoryId, enabled, order, variants all absent.
      });

      final model = RepairServiceModel.fromFirestore(doc);

      expect(model.categoryId, isNull);
      expect(model.variants, isEmpty);
      expect(model.enabled, isTrue); // CMS-compat default, not customer-visible
      expect(model.order, 0);
      expect(model.isBookingReady, isFalse);
    });
  });

  group('RepairServiceEntity — booking readiness', () {
    test('empty variants is never booking-ready even with a category', () {
      final svc = _service(variants: const []);
      expect(svc.isBookingReady, isFalse);
    });

    test('service disabled at top level is never booking-ready', () {
      final svc = _service(enabled: false, variants: const [_variant]);
      expect(svc.isBookingReady, isFalse);
    });

    test('archived service is never booking-ready', () {
      final svc =
          _service(status: CatalogStatus.archived, variants: const [_variant]);
      expect(svc.isBookingReady, isFalse);
    });

    test('a service with a category and one enabled variant is booking-ready',
        () {
      final svc = _service(variants: const [_variant]);
      expect(svc.isBookingReady, isTrue);
    });

    test(
        'booking-ready requires at least one ENABLED variant, not just any variant',
        () {
      final disabledOnly = _service(
        variants: [_variant.copyWith(enabled: false)],
      );
      expect(disabledOnly.isBookingReady, isFalse);
    });
  });

  group('RepairServiceEntity — booking readiness vs. price (contract §1)', () {
    test('an enabled variant priced 0 does NOT make the service bookable', () {
      const unpriced =
          RepairServiceVariantEntity(code: 'x', name: 'x', price: 0);
      final svc = _service(variants: const [unpriced]);
      expect(svc.isBookingReady, isFalse);
      expect(svc.bookableOffers, isEmpty);
      expect(svc.bookability, RepairServiceBookability.noValidPrice);
    });

    test('bookability labels: bookable / paused / hidden', () {
      expect(_service(variants: const [_variant]).bookability,
          RepairServiceBookability.bookable);
      expect(_service(enabled: false, variants: const [_variant]).bookability,
          RepairServiceBookability.bookingPaused);
      expect(
          _service(status: CatalogStatus.archived, variants: const [_variant])
              .bookability,
          RepairServiceBookability.hidden);
      expect(RepairServiceBookability.bookable.label, 'Đặt lịch được');
      expect(RepairServiceBookability.noValidPrice.label, 'Chưa có giá hợp lệ');
      expect(RepairServiceBookability.bookingPaused.label,
          'Tạm ngưng nhận đặt lịch');
      expect(RepairServiceBookability.hidden.label, 'Đang ẩn');
    });
  });

  group('RepairServiceEntity.minimumPrice', () {
    test('null when there are no enabled variants', () {
      expect(_service(variants: const []).minimumPrice, isNull);
    });

    test(
        'ignores a 0-priced variant — 0 means "chưa có giá", never "từ 0đ" '
        '(eligibility contract §1)', () {
      const unpriced = RepairServiceVariantEntity(
          code: 'unpriced', name: 'Chưa có giá', price: 0, enabled: false);
      final svc = _service(variants: [_variant, unpriced]);

      expect(svc.minimumPrice, 500000);
    });

    test('picks the lowest VALID price among bookable variants', () {
      const cheaper = RepairServiceVariantEntity(
          code: 'cheaper', name: 'Pin thường', price: 300000);
      final svc = _service(variants: [_variant, cheaper]);

      expect(svc.minimumPrice, 300000);
    });

    test('ignores disabled variants when computing the minimum', () {
      const cheap = RepairServiceVariantEntity(
          code: 'cheap', name: 'Cheap', price: 100, enabled: false);
      final svc = _service(variants: [_variant, cheap]);

      expect(svc.minimumPrice, 500000); // not 100 — cheap is disabled
    });
  });

  group('RepairServiceEntity.validationErrors', () {
    test('negative variant price is rejected', () {
      final svc = _service(variants: [_variant.copyWith(price: -1)]);
      expect(svc.validationErrors(), isNotEmpty);
    });

    test(
        'an ENABLED variant with price = 0 is rejected — 0 is "chưa có giá", '
        'not "miễn phí" (eligibility contract §1)', () {
      const unpriced =
          RepairServiceVariantEntity(code: 'free', name: 'Free', price: 0);
      final svc = _service(variants: [unpriced]);
      expect(svc.validationErrors(), hasLength(1));
      expect(svc.validationErrors().single, contains('phải có giá lớn hơn 0'));
    });

    test('a DISABLED variant may keep price = 0', () {
      const unpriced = RepairServiceVariantEntity(
          code: 'free', name: 'Free', price: 0, enabled: false);
      final svc = _service(variants: [unpriced]);
      expect(svc.validationErrors(), isEmpty);
    });

    test('an enabled variant without a code is rejected', () {
      final svc = _service(variants: [_variant.copyWith(code: '  ')]);
      expect(svc.validationErrors(), isNotEmpty);
    });

    test('an enabled variant in a non-VND currency is rejected', () {
      final svc = _service(variants: [_variant.copyWith(currency: 'USD')]);
      expect(svc.validationErrors(), isNotEmpty);
    });

    test('a 0-priced ADD-ON stays valid (free add-on)', () {
      final svc = _service(variants: const [_variant]);
      expect(svc.validationErrors(), isEmpty);
    });

    test('negative addon price is rejected', () {
      final svc = _service(variants: [
        _variant.copyWith(addons: [_addonZeroPrice.copyWith(price: -180000)]),
      ]);
      expect(svc.validationErrors(), isNotEmpty);
    });

    test('duplicate variant code within the same service is rejected', () {
      final svc = _service(variants: [_variant, _variant]);
      expect(
        svc.validationErrors(),
        contains(contains('bị trùng trong dịch vụ này')),
      );
    });

    test('duplicate addon code within the same variant is rejected', () {
      final svc = _service(variants: [
        _variant.copyWith(addons: [_addonZeroPrice, _addonZeroPrice]),
      ]);
      expect(
        svc.validationErrors(),
        contains(contains('bị trùng trong biến thể')),
      );
    });

    test(
        'same variant code in two different services is fine (uniqueness is per-service)',
        () {
      final serviceA = _service(variants: [_variant]);
      final serviceB = _service(variants: [_variant])
          .copyWith(id: 'svc-2', modelId: 'model-2');

      expect(serviceA.validationErrors(), isEmpty);
      expect(serviceB.validationErrors(), isEmpty);
    });

    test('negative order is rejected', () {
      final now = DateTime(2026, 1, 1);
      final svc = RepairServiceEntity(
        id: 'svc-1',
        categoryId: 'cat-1',
        modelId: 'model-1',
        name: 'x',
        order: -1,
        createdAt: now,
        updatedAt: now,
      );
      expect(svc.validationErrors(), isNotEmpty);
    });
  });

  group(
      'RepairServiceModel — nested variants/addons round-trip via Firestore mapping',
      () {
    test('toFirestore -> fromFirestore preserves variants and addons', () {
      final model =
          RepairServiceModel.fromEntity(_service(variants: [_variant]));
      final doc = _MockDocumentSnapshot();
      when(() => doc.id).thenReturn(model.id);
      when(() => doc.data()).thenReturn(model.toFirestore());

      final restored = RepairServiceModel.fromFirestore(doc);

      expect(restored.variants, hasLength(1));
      expect(restored.variants.first.code, _variant.code);
      expect(restored.variants.first.addons, hasLength(1));
      expect(restored.variants.first.addons.first.price, 0);
      expect(restored.categoryId, 'cat-1');
    });
  });
}
