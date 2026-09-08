// Authoritative preflight test for the Phase 3 production dataset — every
// assertion here targets `computeDatasetPreflightSummary()` in
// `lib/src/features/catalog_import/domain/catalog_dataset_preflight.dart`,
// the SAME function the CMS Data Tools page calls for its offline dataset
// summary panel. If the dataset changes later and becomes internally
// inconsistent, this test fails — and so does the CMS panel, in the same
// way, from the same source.
import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PRINT — full preflight inventory (read this test\'s stdout)', () {
    final s = computeDatasetPreflightSummary();

    // ignore: avoid_print
    print('canonicalModelCatalog.length = ${s.canonicalModelCount}');
    s.canonicalByFamily.forEach((k, v) => print('  $k = $v'));
    print(
        'requiredModelCount (unique, referenced by dataset) = ${s.requiredModelCount}');
    print('unusedCanonicalModels = ${s.unusedCanonicalModels.length}');
    for (final m in s.unusedCanonicalModels) {
      print('  UNUSED: ${m.shorthand} -> ${m.modelCode} (${m.modelName})');
    }
    print('categoryCount = ${s.categoryCount}');
    print('serviceRowCount = ${s.serviceRowCount}');
    print('variantCount = ${s.variantCount}');
    print('addonCount = ${s.addonCount}');
    print('zeroPriceVariants = ${s.zeroPriceVariants.length}');
    for (final z in s.zeroPriceVariants) {
      print('  ZERO VARIANT: $z');
    }
    print('zeroPriceAddons = ${s.zeroPriceAddons.length}');
    for (final z in s.zeroPriceAddons) {
      print('  ZERO ADDON: $z');
    }
    print('negativePriceCount = ${s.negativePriceCount}');
    print('duplicateCategoryCodes = ${s.duplicateCategoryCodes}');
    print(
        'duplicateCategoryModelMappings = ${s.duplicateCategoryModelMappings}');
    print('rowsWithDuplicateVariantCodes = ${s.rowsWithDuplicateVariantCodes}');
    print(
        'variantsWithDuplicateAddonCodes = ${s.variantsWithDuplicateAddonCodes}');
    for (final entry in s.perCategory.entries) {
      print(
        '${entry.key}: services=${entry.value.services} variants=${entry.value.variants} addons=${entry.value.addons}',
      );
    }
    print('---- toPlainText() ----');
    print(s.toPlainText());

    expect(s.categoryCount, 14);
  });

  group('canonical model catalog — inventory & integrity', () {
    test('family breakdown (derived from source, not hardcoded)', () {
      final s = computeDatasetPreflightSummary();
      expect(s.canonicalByFamily['iphone'], 31);
      expect(s.canonicalByFamily['ipad'], 28);
      expect(s.canonicalByFamily['airpods'], 6);
      expect(s.canonicalByFamily['apple_watch'], 12);
      expect(s.canonicalByFamily['galaxy_z_flip'], 5);
      expect(s.canonicalByFamily['galaxy_z_fold'], 5);
      final total = s.canonicalByFamily.values.fold<int>(0, (a, b) => a + b);
      expect(total, s.canonicalModelCount);
      // 31+28+6+12+5+5 = 87 — NOT 108 (a prior chat report's arithmetic
      // error; grep confirms "108" appears nowhere in source) and not "88"
      // either (iPad is 28, not 29). This is the actual, derived total.
      expect(s.canonicalModelCount, 87);
    });

    test('no duplicate canonical model codes', () {
      final codes = canonicalModelCatalog.map((m) => m.modelCode).toList();
      expect(codes.toSet().length, codes.length);
    });

    test('no duplicate canonical shorthands (the dataset join key)', () {
      final shorthands = canonicalModelCatalog.map((m) => m.shorthand).toList();
      expect(shorthands.toSet().length, shorthands.length);
    });

    test('no duplicate canonical display name within the same family', () {
      final seen = <String, Set<String>>{};
      for (final m in canonicalModelCatalog) {
        final names = seen.putIfAbsent(m.familyCode, () => {});
        expect(names.add(m.modelName), isTrue,
            reason:
                'Duplicate name "${m.modelName}" in family ${m.familyCode}');
      }
    });
  });

  group('required vs canonical model semantics', () {
    test(
        'required model count (dataset-referenced) is a strict subset of canonical count',
        () {
      final s = computeDatasetPreflightSummary();
      expect(s.requiredModelCount, lessThanOrEqualTo(s.canonicalModelCount));
      expect(s.requiredModelCount + s.unusedCanonicalModels.length,
          s.canonicalModelCount);
      // Exactly 1 canonical model has no production service row anywhere —
      // iPad Pro 12.9" (2021, M1) is used by NO category (Ép kính iPad
      // explicitly excludes it per source; touch/battery use the non-M1
      // "2021" shorthand instead). This is expected, not a bug.
      expect(s.requiredModelCount, 86);
      expect(
          s.unusedCanonicalModels.map((m) => m.shorthand), ['PRO129_2021_M1']);
    });

    test(
        'requiredCanonicalModels() returns exactly the dataset-referenced subset',
        () {
      final required = requiredCanonicalModels(
        productionServiceImportRows.map((r) => r.modelShorthand),
      );
      expect(required.length, 86);
      expect(required.any((m) => m.shorthand == 'PRO129_2021_M1'), isFalse);
    });

    test(
        'every canonical model referenced by the dataset resolves via its shorthand',
        () {
      final referenced =
          productionServiceImportRows.map((r) => r.modelShorthand).toSet();
      for (final shorthand in referenced) {
        expect(canonicalModelByShorthand.containsKey(shorthand), isTrue,
            reason: 'Dataset references unknown shorthand: $shorthand');
      }
    });
  });

  group('dataset counts — programmatically derived, not hardcoded', () {
    test('exactly 14 service categories, covering all 14 production groups',
        () {
      final s = computeDatasetPreflightSummary();
      expect(s.categoryCount, 14);
      const expectedNames = {
        'Ép kính iPhone',
        'Face ID',
        'Ép cảm ứng iPhone',
        'Giá màn iPhone',
        'Pin AirPods',
        'Pin iPhone',
        'Samsung Fold / Flip',
        'Thay phôi pin iPhone',
        'Sửa camera sau iPhone',
        'Thay lưng iPhone',
        'Ép cảm ứng iPad',
        'Pin iPad',
        'Apple Watch',
        'Ép kính iPad',
      };
      final actualNames =
          productionServiceCategories.map((c) => c.name).toSet();
      expect(actualNames, expectedNames);
    });

    test('service row / variant / addon counts', () {
      final s = computeDatasetPreflightSummary();
      // Documents the ACTUAL derived counts — this is the source of truth,
      // not a prior report. A Phase 3 chat report claimed 507 variants / 20
      // addons; neither number was ever computed from source (grep confirms
      // "507" appears nowhere in code) — the real, verified counts are
      // 459 and 18. If these expected numbers ever need to change, that
      // must be a deliberate, reviewed dataset edit, never a silent drift.
      expect(s.serviceRowCount, 277);
      expect(s.variantCount, 459);
      expect(s.addonCount, 18);
    });

    test('isClean is true for the current production dataset', () {
      expect(computeDatasetPreflightSummary().isClean, isTrue);
    });
  });

  group('zero-price integrity', () {
    test('negative prices = 0', () {
      expect(computeDatasetPreflightSummary().negativePriceCount, 0);
    });

    test('the 3 known zero-price Fix trùng 3uTools addons are present', () {
      final s = computeDatasetPreflightSummary();
      const cellReplaceCode = 'battery_cell_replace_fix_health';
      expect(
        s.zeroPriceAddons,
        containsAll([
          '$catThayPhoiPin/XS/$cellReplaceCode/fix_3utools_duplicate',
          '$catThayPhoiPin/XR/$cellReplaceCode/fix_3utools_duplicate',
          '$catThayPhoiPin/XMAX/$cellReplaceCode/fix_3utools_duplicate',
        ]),
      );
      // Exactly these 3 — no more, no fewer zero-price addons in the dataset.
      expect(s.zeroPriceAddons.length, 3);
      // No zero-price variants anywhere in the current production dataset.
      expect(s.zeroPriceVariants, isEmpty);
    });
  });

  group('uniqueness — all dimensions', () {
    test('0 duplicate category codes, 0 duplicate (category, model) mappings',
        () {
      final s = computeDatasetPreflightSummary();
      expect(s.duplicateCategoryCodes, 0);
      expect(s.duplicateCategoryModelMappings, 0);
    });

    test(
        '0 rows with duplicate variant codes, 0 variants with duplicate addon codes',
        () {
      final s = computeDatasetPreflightSummary();
      expect(s.rowsWithDuplicateVariantCodes, 0);
      expect(s.variantsWithDuplicateAddonCodes, 0);
    });
  });

  group('order validation', () {
    test('category order values are all >= 0', () {
      for (final c in productionServiceCategories) {
        expect(c.order, greaterThanOrEqualTo(0));
      }
    });

    test('category order is deterministic 10..140, not all zero', () {
      final orders = productionServiceCategories.map((c) => c.order).toList();
      expect(orders,
          [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140]);
    });

    // The dataset source rows (VariantImportRow/AddonImportRow) don't carry
    // an explicit `order` field themselves — their meaningful order is
    // their LIST POSITION within each row (the price table's own listing
    // order, e.g. "Cell zin 1:1" before "Pin Pisen"). CatalogImportService
    // is responsible for turning that position into a real `order` value
    // on write (verified in catalog_import_service_test.dart) rather than
    // letting every variant/addon collapse to the same order=0 default.
    test('every price value is >= 0', () {
      for (final row in productionServiceImportRows) {
        for (final v in row.variants) {
          expect(v.price, greaterThanOrEqualTo(0));
          for (final a in v.addons) {
            expect(a.price, greaterThanOrEqualTo(0));
          }
        }
      }
    });
  });

  group(
      'representative price assertions (spot checks from the production spec)',
      () {
    ServiceImportRow rowFor(String category, String model) =>
        productionServiceImportRows.firstWhere(
            (r) => r.categoryCode == category && r.modelShorthand == model);

    test('Ép kính iPhone — X = 280000, 15 Pro Max = 800000', () {
      expect(rowFor(catEpKinhIphone, 'X').variants.single.price, 280000);
      expect(rowFor(catEpKinhIphone, '15PROMAX').variants.single.price, 800000);
    });

    test('Giá màn iPhone — 15 Pro Max = 8500000', () {
      expect(
          rowFor(catGiaManIphone, '15PROMAX').variants.single.price, 8500000);
    });

    test('Pin iPhone — 6 Pin Pisen = 275000; 15 Pro Max Pin có cổ = 800000',
        () {
      final six = rowFor(catPinIphone, '6');
      expect(six.variants.single.code, 'battery_pisen');
      expect(six.variants.single.price, 275000);

      final proMax15 = rowFor(catPinIphone, '15PROMAX');
      final withFlex =
          proMax15.variants.firstWhere((v) => v.code == 'battery_with_flex');
      expect(withFlex.price, 800000);
    });

    test('Thay phôi pin — XS base = 300000, Fix trùng 3uTools = 0', () {
      final row = rowFor(catThayPhoiPin, 'XS');
      expect(row.variants.single.price, 300000);
      expect(row.variants.single.addons.single.price, 0);
      expect(row.variants.single.addons.single.code, 'fix_3utools_duplicate');
    });

    test(
        'Sửa camera sau — 15 Pro Max: Rửa đốm 100000, Thay thấu 350000, Fix rung 300000, Fix báo 400000',
        () {
      final row = rowFor(catCameraSau, '15PROMAX');
      final byCode = {for (final v in row.variants) v.code: v.price};
      expect(byCode['camera_spot_cleaning'], 100000);
      expect(byCode['camera_lens_replacement'], 350000);
      expect(byCode['camera_stabilization_focus_fix'], 300000);
      expect(byCode['camera_error_fix'], 400000);
    });

    test('Apple Watch Ultra 2 — Ép kính = 1000000, no touch variant', () {
      final row = rowFor(catAppleWatch, 'WATCHULTRA2');
      expect(row.variants, hasLength(1));
      expect(row.variants.single.code, 'glass_replacement');
      expect(row.variants.single.price, 1000000);
    });

    test(
        'Ép kính iPad — Air 3/4/5, Gen 8/9/10, Pro 12.9 (2021, M1) are absent (no source price)',
        () {
      for (final model in [
        'AIR3',
        'AIR4',
        'AIR5',
        'GEN8',
        'GEN9',
        'GEN10',
        'PRO129_2021_M1'
      ]) {
        final exists = productionServiceImportRows.any((r) =>
            r.categoryCode == catEpKinhIpad && r.modelShorthand == model);
        expect(exists, isFalse,
            reason: '$model should not have an Ép kính iPad row');
      }
    });
  });
}
