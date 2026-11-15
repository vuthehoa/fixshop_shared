import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ignore: subtype_of_sealed_class
class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

Map<String, dynamic> _item(String sid, String cat, int price,
        {String? name, String? variant, Object? lineTotal}) =>
    {
      'serviceId': sid,
      'categoryId': cat,
      'serviceName': name ?? 'Dịch vụ $sid',
      'variantCode': 'v_$sid',
      'variantName': variant ?? 'Phương án $sid',
      'basePrice': price,
      'selectedAddons': <Map<String, dynamic>>[],
      'warrantyMonths': 6,
      'lineTotal': lineTotal ?? price,
    };

/// A customer-app order as written by the web multi-service contract v1.
Map<String, dynamic> _multiOrder() => {
      'bookingRequestId': 'b-1',
      'source': 'customer_app',
      'currentStatus': 'pending',
      'repairOrderCode': '',
      'customerId': 'c-1',
      'customerName': 'A',
      'customerPhone': '0905555538',
      'deviceId': '',
      'deviceCode': '',
      'deviceName': 'iPhone 13',
      'serialNumber': '',
      'manufacturerId': '',
      'manufacturerName': 'Apple',
      'createdBy': 'u-1',
      'serviceId': 'svc-a',
      'serviceSnapshot': {
        'categoryId': 'cat-a',
        'categoryCode': 'a',
        'categoryName': 'Thay pin',
        'serviceId': 'svc-a',
        'variantCode': 'v_svc-a',
        'variantName': 'Pin zin',
        'basePrice': 800000,
        'currency': 'VND',
        'selectedAddons': <Map<String, dynamic>>[],
        'estimatedPrice': 2300000,
      },
      'serviceItems': [
        _item('svc-a', 'cat-a', 800000, name: 'Thay pin', variant: 'Pin zin'),
        _item('svc-b', 'cat-b', 1500000,
            name: 'Thay màn hình', variant: 'Màn OLED'),
      ],
      'receiptKey': 'a' * 64,
      'estimatedCost': 2300000,
      'problemDescription': 'Dịch vụ đã chọn (2): …',
      'createdAt': Timestamp.fromDate(DateTime(2026, 11, 15)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 11, 15)),
    };

RepairOrderModel _parse(Map<String, dynamic> data, [String id = 'b-1']) {
  final doc = _MockDocumentSnapshot();
  when(() => doc.id).thenReturn(id);
  when(() => doc.data()).thenReturn(data);
  return RepairOrderModel.fromFirestore(doc);
}

void main() {
  group('serviceItems parsing', () {
    test('multi-service order parses every item in stored order', () {
      final o = _parse(_multiOrder());
      expect(o.serviceItems, hasLength(2));
      expect(o.isMultiService, isTrue);
      expect(o.receiptKey, 'a' * 64);
      expect(o.serviceLines.map((i) => i.serviceName),
          ['Thay pin', 'Thay màn hình']);
      expect(o.serviceLines[1].variantName, 'Màn OLED');
      expect(o.serviceLines[1].lineTotal, 1500000);
      expect(o.serviceLines[1].warrantyMonths, 6);
      // legacy item-0 fields still read as before
      expect(o.serviceSnapshot!.serviceId, 'svc-a');
      expect(o.serviceSnapshot!.estimatedPrice, 2300000);
      expect(o.estimatedCost, 2300000);
    });

    test('legacy order (no serviceItems) derives ONE line from serviceSnapshot',
        () {
      final data = _multiOrder()
        ..remove('serviceItems')
        ..remove('receiptKey');
      final o = _parse(data);
      expect(o.serviceItems, isNull);
      expect(o.receiptKey, isNull);
      expect(o.isMultiService, isFalse);
      expect(o.serviceLines, hasLength(1));
      final line = o.serviceLines.single;
      expect(line.serviceName, 'Thay pin');
      expect(line.variantName, 'Pin zin');
      expect(line.basePrice, 800000);
      expect(line.lineTotal, 2300000); // = estimatedPrice (old behaviour)
    });

    test('CMS/walk-in order without any booking snapshot has no lines', () {
      final data = _multiOrder()
        ..remove('serviceItems')
        ..remove('serviceSnapshot');
      expect(_parse(data).serviceLines, isEmpty);
    });

    test(
        'defensive: non-map elements skipped, bad labels → "", lineTotal falls back',
        () {
      final data = _multiOrder()
        ..['serviceItems'] = [
          'garbage',
          42,
          {
            'serviceId': 'svc-a',
            'categoryId': 7,
            'serviceName': null,
            'variantCode': 'v',
            'variantName': ['x'],
            'basePrice': 500000.0,
            'selectedAddons': 'nope',
          },
        ];
      final o = _parse(data);
      expect(o.serviceItems, hasLength(1));
      final i = o.serviceItems!.single;
      expect(i.categoryId, '');
      expect(i.serviceName, '');
      expect(i.variantName, '');
      expect(i.basePrice, 500000);
      expect(i.lineTotal, 500000);
      expect(i.selectedAddons, isEmpty);
      expect(i.warrantyMonths, isNull);
    });

    test(
        'defensive: serviceItems not a list / empty / only junk → legacy fallback',
        () {
      for (final bad in [
        'x',
        <dynamic>[],
        [1, 'a'],
        {'0': {}}
      ]) {
        final o = _parse(_multiOrder()..['serviceItems'] = bad);
        expect(o.serviceItems, isNull, reason: '$bad');
        expect(o.serviceLines, hasLength(1), reason: '$bad');
      }
      expect(_parse(_multiOrder()..['receiptKey'] = 5).receiptKey, isNull);
    });
  });

  group('round-trip preserves serviceItems / receiptKey', () {
    test('toFirestore writes items and receiptKey back verbatim', () {
      final data = _multiOrder();
      final out = _parse(data).toFirestore();
      expect(out['serviceItems'], data['serviceItems']);
      expect(out['receiptKey'], data['receiptKey']);
    });

    test('copyWith (status/timeline edits) and fromEntity keep the items', () {
      final o = _parse(_multiOrder());
      final updated = o.copyWith(
        currentStatus: RepairOrderStatus.received,
        internalNote: 'ok',
        timeline: [
          RepairOrderTimelineEntry(
            type: RepairOrderTimelineEntryType.received,
            message: 'Đã tiếp nhận',
            actorId: 'u-2',
            actorRole: UserRole.reception,
            timestamp: DateTime(2026, 11, 16),
          ),
        ],
      );
      expect(updated.serviceItems, o.serviceItems);
      expect(updated.receiptKey, o.receiptKey);
      final back = RepairOrderModel.fromEntity(updated).toFirestore();
      expect(back['serviceItems'], _multiOrder()['serviceItems']);
      expect(back['receiptKey'], 'a' * 64);
      // the generic edit payload never touches booking fields
      final upd = RepairOrderModel.fromEntity(updated).toUpdateMap();
      expect(upd.containsKey('serviceItems'), isFalse);
      expect(upd.containsKey('serviceSnapshot'), isFalse);
    });

    test('legacy order never gains a synthesised serviceItems field on write',
        () {
      final data = _multiOrder()
        ..remove('serviceItems')
        ..remove('receiptKey');
      final out = _parse(data).toFirestore();
      expect(out.containsKey('serviceItems'), isFalse);
      expect(out.containsKey('receiptKey'), isFalse);
    });

    test('item toMap omits warrantyMonths when absent (allowlist-exact)', () {
      final m = BookingServiceItem.fromMap(
              _item('s', 'c', 1)..remove('warrantyMonths'))
          .toMap();
      expect(m.keys.toSet(), {
        'serviceId',
        'categoryId',
        'serviceName',
        'variantCode',
        'variantName',
        'basePrice',
        'selectedAddons',
        'lineTotal',
      });
    });
  });

  group('warranty per item category', () {
    Map<String, dynamic> completed() =>
        {..._multiOrder(), 'currentStatus': 'delivered', 'deviceId': 'd-1'};

    test('serviceTargets lists one target per item category', () {
      final t = DeviceWarrantyActivation.serviceTargets(completed());
      expect(t.map((x) => x.categoryId), ['cat-a', 'cat-b']);
      expect(t.map((x) => x.categoryName), ['Thay pin', 'Thay màn hình']);
      expect(t[1].partLabel, 'Màn OLED');
      expect(t[1].itemIndex, 1);
    });

    test('serviceTargets of a legacy order = the snapshot category', () {
      final o = completed()..remove('serviceItems');
      final t = DeviceWarrantyActivation.serviceTargets(o);
      expect(t.single.categoryId, 'cat-a');
      expect(
          DeviceWarrantyActivation.serviceTargets(
              {...o, 'serviceSnapshot': {}}),
          isEmpty);
    });

    test('duplicate categories collapse to one target', () {
      final o = completed()
        ..['serviceItems'] = [
          _item('s1', 'cat-a', 1),
          _item('s2', 'cat-a', 2),
          _item('s3', '', 3),
        ];
      expect(
          DeviceWarrantyActivation.serviceTargets(o).map((t) => t.categoryId),
          ['cat-a']);
    });

    test('check(itemCategoryId) resolves each item with deterministic id', () {
      final a = DeviceWarrantyActivation.check(
          repairOrderId: 'ro', order: completed(), itemCategoryId: 'cat-b');
      expect(a.ok, isTrue);
      expect(a.warrantyId, 'ro__cat-b');
      expect(a.categoryName, 'Thay màn hình');
      expect(a.partLabel, 'Màn OLED');
      final b = DeviceWarrantyActivation.check(
          repairOrderId: 'ro', order: completed());
      expect(b.warrantyId, 'ro__cat-a'); // default = item 0 / snapshot
      final bad = DeviceWarrantyActivation.check(
          repairOrderId: 'ro', order: completed(), itemCategoryId: 'cat-z');
      expect(bad.skip, WarrantySkipReason.missingService);
    });

    test('itemCategoryId is ignored for a legacy order (snapshot wins)', () {
      final o = completed()..remove('serviceItems');
      final c = DeviceWarrantyActivation.check(
          repairOrderId: 'ro', order: o, itemCategoryId: 'cat-b');
      expect(c.warrantyId, 'ro__cat-a');
    });

    test('status gates still apply to item activation', () {
      final c = DeviceWarrantyActivation.check(
          repairOrderId: 'ro',
          order: {...completed(), 'currentStatus': 'repairing'},
          itemCategoryId: 'cat-b');
      expect(c.skip, WarrantySkipReason.orderNotCompleted);
    });
  });
}
