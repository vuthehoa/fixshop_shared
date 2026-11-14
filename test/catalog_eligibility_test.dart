import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';

const _pisen = RepairServiceVariantEntity(
  code: 'battery_pisen',
  name: 'Pin Pisen',
  price: 810000,
);

void main() {
  group('isValidOfferPrice — integer VND > 0 only (contract §1)', () {
    test('accepts positive integers', () {
      expect(isValidOfferPrice(1), isTrue);
      expect(isValidOfferPrice(810000), isTrue);
    });

    test('rejects 0, negative, null, strings', () {
      expect(isValidOfferPrice(0), isFalse);
      expect(isValidOfferPrice(-1), isFalse);
      expect(isValidOfferPrice(null), isFalse);
      expect(isValidOfferPrice('810000'), isFalse);
    });

    test('rejects fractional doubles, NaN and infinity', () {
      expect(isValidOfferPrice(810000.5), isFalse);
      expect(isValidOfferPrice(double.nan), isFalse);
      expect(isValidOfferPrice(double.infinity), isFalse);
    });

    test('a whole-number double is the same integer (Flutter web numbers)', () {
      expect(isValidOfferPrice(810000.0), isTrue);
    });
  });

  group('isValidOfferCurrency', () {
    test('VND, empty and missing are accepted; others are not', () {
      expect(isValidOfferCurrency('VND'), isTrue);
      expect(isValidOfferCurrency(''), isTrue);
      expect(isValidOfferCurrency(null), isTrue);
      expect(isValidOfferCurrency('USD'), isFalse);
      expect(isValidOfferCurrency(1), isFalse);
    });
  });

  group('computeEligibilityOffers (entity)', () {
    Map<String, int> offers({
      CatalogStatus status = CatalogStatus.active,
      bool enabled = true,
      List<RepairServiceVariantEntity> variants = const [_pisen],
    }) =>
        computeEligibilityOffers(
          status: status,
          enabled: enabled,
          variants: variants,
        );

    test('active + enabled + valid variant ⇒ offers[code] = price', () {
      expect(offers(), {'battery_pisen': 810000});
    });

    test('archived service ⇒ {}', () {
      expect(offers(status: CatalogStatus.archived), isEmpty);
    });

    test('service enabled == false ⇒ {}', () {
      expect(offers(enabled: false), isEmpty);
    });

    test('drops disabled, 0-priced, negative, code-less and non-VND variants',
        () {
      final result = offers(variants: [
        _pisen,
        _pisen.copyWith(code: 'disabled', enabled: false),
        _pisen.copyWith(code: 'zero', price: 0),
        _pisen.copyWith(code: 'negative', price: -5),
        _pisen.copyWith(code: '   '),
        _pisen.copyWith(code: 'usd', currency: 'USD'),
        _pisen.copyWith(code: 'empty_currency', currency: '', price: 300000),
      ]);
      expect(result, {'battery_pisen': 810000, 'empty_currency': 300000});
    });

    test('duplicate code: first enabled variant wins (deterministic)', () {
      final result = offers(variants: [
        _pisen,
        _pisen.copyWith(price: 1),
      ]);
      expect(result, {'battery_pisen': 810000});
    });

    test('trims the code used as the offers key', () {
      expect(offers(variants: [_pisen.copyWith(code: ' battery_pisen ')]),
          {'battery_pisen': 810000});
    });
  });

  group('computeEligibilityOffersFromDocument (raw Firestore map)', () {
    Map<String, dynamic> doc({
      Object? status = 'active',
      Object? enabled = true,
      List<Map<String, dynamic>>? variants,
    }) =>
        {
          'modelId': 'model-1',
          if (status != null) 'status': status,
          if (enabled != null) 'enabled': enabled,
          'variants': variants ??
              [
                {'code': 'battery_pisen', 'price': 810000, 'enabled': true},
              ],
        };

    test('matches the entity rules on a well-formed document', () {
      expect(computeEligibilityOffersFromDocument(doc()),
          {'battery_pisen': 810000});
    });

    test('missing status is NOT active ⇒ {}', () {
      expect(computeEligibilityOffersFromDocument(doc(status: null)), isEmpty);
    });

    test('missing enabled (legacy) defaults to true', () {
      expect(computeEligibilityOffersFromDocument(doc(enabled: null)),
          {'battery_pisen': 810000});
    });

    test('enabled must be literally true (no truthy strings)', () {
      expect(
          computeEligibilityOffersFromDocument(doc(enabled: 'true')), isEmpty);
    });

    test('fractional / string / missing prices are not offers', () {
      final result = computeEligibilityOffersFromDocument(doc(variants: [
        {'code': 'frac', 'price': 1.5},
        {'code': 'str', 'price': '100000'},
        {'code': 'none'},
        {'code': 'whole_double', 'price': 250000.0},
        {'code': 'off', 'price': 1000, 'enabled': false},
        {'code': 'eur', 'price': 1000, 'currency': 'EUR'},
        {'price': 1000},
      ]));
      expect(result, {'whole_double': 250000});
      expect(result['whole_double'], isA<int>());
    });

    test('non-list variants ⇒ {}', () {
      final d = doc()..['variants'] = 'oops';
      expect(computeEligibilityOffersFromDocument(d), isEmpty);
    });
  });

  group('computeBookability', () {
    test('hidden > paused > no price > bookable', () {
      expect(
        computeBookability(
            status: CatalogStatus.archived, enabled: false, variants: const []),
        RepairServiceBookability.hidden,
      );
      expect(
        computeBookability(
            status: CatalogStatus.active,
            enabled: false,
            variants: const [_pisen]),
        RepairServiceBookability.bookingPaused,
      );
      expect(
        computeBookability(
            status: CatalogStatus.active,
            enabled: true,
            variants: [_pisen.copyWith(price: 0)]),
        RepairServiceBookability.noValidPrice,
      );
      expect(
        computeBookability(
            status: CatalogStatus.active,
            enabled: true,
            variants: const [_pisen]),
        RepairServiceBookability.bookable,
      );
    });
  });

  group('parseWarrantyMonths', () {
    test('reads the _bhN code segment', () {
      expect(parseWarrantyMonths(code: 'screen_zin_bh12', name: 'Màn zin'), 12);
      expect(parseWarrantyMonths(code: 'screen_bh6_premium', name: 'x'), 6);
      expect(parseWarrantyMonths(code: 'SCREEN_BH3', name: 'x'), 3);
    });

    test('falls back to "BH N tháng" / "Bảo hành N tháng" in the name', () {
      expect(
          parseWarrantyMonths(code: 'screen', name: 'Màn zin BH 6 tháng'), 6);
      expect(parseWarrantyMonths(code: 'screen', name: 'Màn zin (bh12 tháng)'),
          12);
      expect(
          parseWarrantyMonths(
              code: 'screen', name: 'Màn zin – Bảo hành 3 tháng'),
          3);
    });

    test('code wins over name', () {
      expect(parseWarrantyMonths(code: 'x_bh12', name: 'BH 6 tháng'), 12);
    });

    test('null when absent; "bh" inside a word is not a warranty', () {
      expect(parseWarrantyMonths(code: 'battery_pisen', name: 'Pin Pisen'),
          isNull);
      expect(parseWarrantyMonths(code: 'abh12x', name: 'x'), isNull);
    });
  });

  group('diffVariantPricing / buildPricingAuditMetadata', () {
    RepairServiceEntity svc({
      bool enabled = true,
      List<RepairServiceVariantEntity> variants = const [_pisen],
      String name = 'Thay pin iPhone 13',
    }) {
      final now = DateTime(2026, 1, 1);
      return RepairServiceEntity(
        id: 'svc-1',
        categoryId: 'cat-1',
        modelId: 'model-1',
        name: name,
        enabled: enabled,
        variants: variants,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('no price/enabled change ⇒ null (name edits are not audited)', () {
      expect(
        buildPricingAuditMetadata(before: svc(), after: svc(name: 'Đổi tên')),
        isNull,
      );
    });

    test('price change ⇒ one change with old/new price and warranty months',
        () {
      final before = svc(variants: [_pisen.copyWith(code: 'screen_bh12')]);
      final after =
          svc(variants: [_pisen.copyWith(code: 'screen_bh12', price: 900000)]);
      final meta = buildPricingAuditMetadata(before: before, after: after)!;
      expect(meta['serviceId'], 'svc-1');
      expect(meta['modelId'], 'model-1');
      expect(meta['categoryId'], 'cat-1');
      expect(meta['changes'], [
        {
          'variantCode': 'screen_bh12',
          'variantName': 'Pin Pisen',
          'warrantyMonths': 12,
          'oldPrice': 810000,
          'newPrice': 900000,
          'oldEnabled': true,
          'newEnabled': true,
        }
      ]);
    });

    test('enabled toggle, added and removed variants are all recorded', () {
      final before = svc(variants: [
        _pisen,
        _pisen.copyWith(code: 'removed', name: 'Bị xoá'),
      ]);
      final after = svc(variants: [
        _pisen.copyWith(enabled: false),
        _pisen.copyWith(code: 'added', name: 'Mới', price: 100000),
      ]);
      final changes = diffVariantPricing(before.variants, after.variants);
      expect(changes.map((c) => c.variantCode),
          ['battery_pisen', 'added', 'removed']);
      expect(changes[0].oldEnabled, isTrue);
      expect(changes[0].newEnabled, isFalse);
      expect(changes[1].oldPrice, isNull);
      expect(changes[1].newPrice, 100000);
      expect(changes[2].newPrice, isNull);
      expect(changes[2].newEnabled, isNull);
    });

    test('service-level enabled change alone is audited', () {
      final meta =
          buildPricingAuditMetadata(before: svc(), after: svc(enabled: false))!;
      expect(meta['oldServiceEnabled'], isTrue);
      expect(meta['newServiceEnabled'], isFalse);
      expect(meta['changes'], isEmpty);
    });
  });

  test('CatalogEligibilitySource wire values', () {
    expect(CatalogEligibilitySource.cms.value, 'cms');
    expect(CatalogEligibilitySource.importer.value, 'import');
    expect(CatalogEligibilitySource.migration.value, 'migration');
  });
}
