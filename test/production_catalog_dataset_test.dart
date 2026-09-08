import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('productionServiceCategories', () {
    test('exactly 14 categories', () {
      expect(productionServiceCategories.length, 14);
    });

    test('all category codes are unique', () {
      final codes = productionServiceCategories.map((c) => c.code).toSet();
      expect(codes.length, productionServiceCategories.length);
    });

    test('orders are the required deterministic sequence 10..140', () {
      final orders = productionServiceCategories.map((c) => c.order).toList();
      expect(orders,
          [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140]);
    });
  });

  group('productionServiceImportRows — every modelShorthand resolves', () {
    test('no row references a shorthand missing from canonicalModelByShorthand',
        () {
      final unresolved = productionServiceImportRows
          .map((r) => r.modelShorthand)
          .where((s) => !canonicalModelByShorthand.containsKey(s))
          .toSet();
      expect(unresolved, isEmpty, reason: 'Unresolved shorthands: $unresolved');
    });

    test('every row references one of the 14 known category codes', () {
      final validCodes = productionServiceCategories.map((c) => c.code).toSet();
      final invalid = productionServiceImportRows
          .map((r) => r.categoryCode)
          .where((c) => !validCodes.contains(c))
          .toSet();
      expect(invalid, isEmpty, reason: 'Unknown category codes: $invalid');
    });

    test('no (categoryCode, modelShorthand) pair repeats', () {
      final seen = <String>{};
      final dupes = <String>{};
      for (final row in productionServiceImportRows) {
        final key = '${row.categoryCode}::${row.modelShorthand}';
        if (!seen.add(key)) dupes.add(key);
      }
      expect(dupes, isEmpty,
          reason: 'Duplicate (category, model) pairs: $dupes');
    });

    test('no variant or addon has a negative price', () {
      final negatives = <String>[];
      for (final row in productionServiceImportRows) {
        for (final v in row.variants) {
          if (v.price < 0)
            negatives
                .add('${row.categoryCode}/${row.modelShorthand}/${v.code}');
          for (final a in v.addons) {
            if (a.price < 0)
              negatives.add(
                  '${row.categoryCode}/${row.modelShorthand}/${v.code}/${a.code}');
          }
        }
      }
      expect(negatives, isEmpty);
    });

    test(
        'no row has zero variants (every imported service is booking-eligible)',
        () {
      final empty =
          productionServiceImportRows.where((r) => r.variants.isEmpty).toList();
      expect(empty, isEmpty);
    });

    test('no duplicate variant codes within a single row', () {
      final violations = <String>[];
      for (final row in productionServiceImportRows) {
        final codes = row.variants.map((v) => v.code).toList();
        if (codes.toSet().length != codes.length) {
          violations.add('${row.categoryCode}/${row.modelShorthand}');
        }
      }
      expect(violations, isEmpty);
    });

    test('no duplicate addon codes within a single variant', () {
      final violations = <String>[];
      for (final row in productionServiceImportRows) {
        for (final v in row.variants) {
          final codes = v.addons.map((a) => a.code).toList();
          if (codes.toSet().length != codes.length) {
            violations
                .add('${row.categoryCode}/${row.modelShorthand}/${v.code}');
          }
        }
      }
      expect(violations, isEmpty);
    });
  });

  group(
      'productionServiceImportRows — row counts per category (transcription self-check)',
      () {
    int countFor(String categoryCode) => productionServiceImportRows
        .where((r) => r.categoryCode == categoryCode)
        .length;

    test(
        'Ép kính iPhone: 23 rows', () => expect(countFor(catEpKinhIphone), 23));
    test('Face ID: 23 rows', () => expect(countFor(catFaceId), 23));
    test('Ép cảm ứng iPhone: 12 rows',
        () => expect(countFor(catEpCamUngIphone), 12));
    test(
        'Giá màn iPhone: 23 rows', () => expect(countFor(catGiaManIphone), 23));
    test('Pin AirPods: 6 rows', () => expect(countFor(catPinAirpods), 6));
    test('Pin iPhone: 31 rows', () => expect(countFor(catPinIphone), 31));
    test('Samsung Fold/Flip: 10 rows',
        () => expect(countFor(catSamsungFoldFlip), 10));
    test('Thay phôi pin iPhone: 22 rows',
        () => expect(countFor(catThayPhoiPin), 22));
    test('Sửa camera sau iPhone: 23 rows',
        () => expect(countFor(catCameraSau), 23));
    test('Thay lưng iPhone: 23 rows', () => expect(countFor(catThayLung), 23));
    test('Ép cảm ứng iPad: 26 rows',
        () => expect(countFor(catEpCamUngIpad), 26));
    test('Pin iPad: 26 rows', () => expect(countFor(catPinIpad), 26));
    test('Apple Watch: 12 rows', () => expect(countFor(catAppleWatch), 12));
    test('Ép kính iPad: 17 rows', () => expect(countFor(catEpKinhIpad), 17));

    test('total rows across all categories == 277', () {
      expect(productionServiceImportRows.length, 277);
    });
  });

  group('production dataset — spot checks against the source (Phase 3 spec)',
      () {
    ServiceImportRow rowFor(String category, String model) =>
        productionServiceImportRows.firstWhere(
            (r) => r.categoryCode == category && r.modelShorthand == model);

    test('iPhone X không tạo service Thay phôi pin', () {
      final hasX = productionServiceImportRows.any(
          (r) => r.categoryCode == catThayPhoiPin && r.modelShorthand == 'X');
      expect(hasX, isFalse);
    });

    test(
        'Thay phôi pin — addon price = 0 is imported for XS/XR/XMAX, not omitted',
        () {
      for (final model in ['XS', 'XR', 'XMAX']) {
        final row = rowFor(catThayPhoiPin, model);
        expect(row.variants.single.addons.single.price, 0);
      }
    });

    test(
        'Thay phôi pin — iPhone 15 has no addon at all (source has no addon column value)',
        () {
      final row = rowFor(catThayPhoiPin, '15');
      expect(row.variants.single.addons, isEmpty);
    });

    test('Face ID — Dây CB only exists for X/XS/XR/XSMax, not for 11 onward',
        () {
      expect(rowFor(catFaceId, 'X').variants, hasLength(2));
      expect(rowFor(catFaceId, '11').variants, hasLength(1));
      expect(rowFor(catFaceId, '11').variants.single.code, 'truedepth');
    });

    test('Thay lưng iPhone 14 — only "Mắt nhỏ" exists ("-" skipped for Mắt to)',
        () {
      final row = rowFor(catThayLung, '14');
      expect(row.variants, hasLength(1));
      expect(row.variants.single.code, 'small_camera_cutout_back_glass');
      expect(row.variants.single.price, 350000);
    });

    test('Apple Watch Ultra 1/2 — no touch_replacement variant ("-")', () {
      for (final model in ['WATCHULTRA1', 'WATCHULTRA2']) {
        final row = rowFor(catAppleWatch, model);
        expect(row.variants, hasLength(1));
        expect(row.variants.single.code, 'glass_replacement');
      }
    });

    test('Sửa camera sau iPhone X — no camera_error_fix (4th column absent)',
        () {
      final row = rowFor(catCameraSau, 'X');
      expect(row.variants, hasLength(3));
      expect(row.variants.any((v) => v.code == 'camera_error_fix'), isFalse);
    });

    test(
        'Sửa camera sau 12 mini — all 4 variants present including camera_error_fix',
        () {
      final row = rowFor(catCameraSau, '12MINI');
      expect(row.variants, hasLength(4));
    });

    test(
        'Ép kính iPad — Air 3/4/5, Gen 8/9/10, Pro 12.9 (2021, M1) are NOT imported',
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
            reason: '$model should not appear in Ép kính iPad');
      }
    });

    test('exact price spot check: iPhone 15 Pro Max Giá màn = 8.500.000', () {
      final row = rowFor(catGiaManIphone, '15PROMAX');
      expect(row.variants.single.price, 8500000);
    });

    test(
        'exact price spot check: iPhone 6 Pin Pisen = 275.000 (only one variant)',
        () {
      final row = rowFor(catPinIphone, '6');
      expect(row.variants, hasLength(1));
      expect(row.variants.single.price, 275000);
    });

    test('exact price spot check: iPhone 11 Pro Max Pin Pisen DLC = 710.000',
        () {
      final row = rowFor(catPinIphone, '11PROMAX');
      final dlc = row.variants.firstWhere((v) => v.code == 'battery_pisen_dlc');
      expect(dlc.price, 710000);
    });
  });
}
