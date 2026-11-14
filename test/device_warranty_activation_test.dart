import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('addCalendarMonthsUtc (port of functions addMonths)', () {
    test('clamps end of month', () {
      expect(
          DeviceWarrantyActivation.addCalendarMonthsUtc(
              DateTime.utc(2026, 1, 31, 10), 1),
          DateTime.utc(2026, 2, 28, 10));
      expect(
          DeviceWarrantyActivation.addCalendarMonthsUtc(
              DateTime.utc(2028, 1, 31), 1),
          DateTime.utc(2028, 2, 29));
    });
    test('crosses years', () {
      expect(
          DeviceWarrantyActivation.addCalendarMonthsUtc(
              DateTime.utc(2026, 11, 14, 3, 4, 5), 12),
          DateTime.utc(2027, 11, 14, 3, 4, 5));
      expect(
          DeviceWarrantyActivation.addCalendarMonthsUtc(
              DateTime.utc(2026, 8, 31), 6),
          DateTime.utc(2027, 2, 28));
    });
  });

  test(
      'ids and record code are deterministic (same vectors as the TS function)',
      () {
    expect(DeviceWarrantyActivation.docId('ro-7', 'cat-1'), 'ro-7__cat-1');
    expect(DeviceWarrantyActivation.logId('ro-7__cat-1', 1), 'ro-7__cat-1__r1');
    final code = DeviceWarrantyActivation.recordCode('ro-7__cat-1');
    expect(code, matches(RegExp(r'^FS-WR-[0-9A-Z]{7}$')));
    expect(DeviceWarrantyActivation.recordCode('ro-7__cat-1'), code);
    // djb2 uint32 of "a" = 177670 → base36 "3T3A"
    expect(DeviceWarrantyActivation.recordCode('a'), 'FS-WR-0003T3A');
  });

  group('check', () {
    Map<String, dynamic> order([Map<String, dynamic> o = const {}]) => {
          'currentStatus': 'completed',
          'customerId': 'c1',
          'deviceId': 'd1',
          'serviceSnapshot': {
            'categoryId': 'cat-1',
            'categoryName': 'Pin',
            'variantName': 'Pisen'
          },
          ...o,
        };
    test('completed order with snapshot → ok, snapshot wins over fallback', () {
      final c = DeviceWarrantyActivation.check(
          repairOrderId: 'ro', order: order(), fallbackCategoryId: 'other');
      expect(c.ok, isTrue);
      expect(c.warrantyId, 'ro__cat-1');
      expect(c.partLabel, 'Pisen');
    });
    test('skip reasons', () {
      expect(
          DeviceWarrantyActivation.check(repairOrderId: 'r', order: null).skip,
          WarrantySkipReason.orderNotFound);
      expect(
          DeviceWarrantyActivation.check(
              repairOrderId: 'r',
              order: order({'currentStatus': 'repairing'})).skip,
          WarrantySkipReason.orderNotCompleted);
      expect(
          DeviceWarrantyActivation.check(
              repairOrderId: 'r',
              order: order({'currentStatus': 'cancelled'})).skip,
          WarrantySkipReason.orderCancelled);
      expect(
          DeviceWarrantyActivation.check(
              repairOrderId: 'r', order: order({'customerId': ''})).skip,
          WarrantySkipReason.missingCustomer);
      expect(
          DeviceWarrantyActivation.check(
              repairOrderId: 'r', order: order({'serviceSnapshot': null})).skip,
          WarrantySkipReason.missingService);
    });
    test(
        'buildRecord carries revision 1, lookup fields, and expiry = now + months',
        () {
      final o =
          order({'customerPhone': '0901', 'imei': '35', 'serialNumber': 'SN'});
      final c = DeviceWarrantyActivation.check(repairOrderId: 'ro', order: o);
      final now = DateTime.utc(2026, 1, 31, 8);
      final r = DeviceWarrantyActivation.buildRecord(
        repairOrderId: 'ro',
        order: o,
        check: c,
        plan: const WarrantyPlanRef(
            id: 'p', code: 'BH6', name: '6 tháng', months: 6),
        actorUid: 'u',
        actorName: 'NV',
        note: ' ghi chú ',
        now: now,
      );
      expect(r['revision'], 1);
      expect(r['expiresAt'], DateTime.utc(2026, 7, 31, 8));
      expect(r['endDate'], r['expiresAt']);
      expect(r['customerPhone'], '0901');
      expect(r['deviceImei'], '35');
      expect(r['activationNote'], 'ghi chú');
      expect(r['stickerAttached'], false);
    });
  });

  test('role gates', () {
    expect(DeviceWarrantyActivation.canActivate(UserRole.technician), isFalse);
    expect(DeviceWarrantyActivation.canActivate(UserRole.reception), isTrue);
    expect(
        DeviceWarrantyActivation.canVoidOrExtend(UserRole.reception), isFalse);
    expect(DeviceWarrantyActivation.canVoidOrExtend(UserRole.manager), isTrue);
  });
}
