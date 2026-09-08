import 'package:flutter_test/flutter_test.dart';

import 'package:fixshop_shared/fixshop_shared.dart';

void main() {
  group('RepairOrderFilter — customerId (Sprint 15)', () {
    test('customerId participates in equality', () {
      const a = RepairOrderFilter(customerId: 'customer-1');
      const b = RepairOrderFilter(customerId: 'customer-1');
      const c = RepairOrderFilter(customerId: 'customer-2');

      expect(a, b);
      expect(a, isNot(c));
    });

    test('copyWith sets customerId without disturbing other fields', () {
      const base = RepairOrderFilter(status: RepairOrderStatus.pending);
      final updated = base.copyWith(customerId: 'customer-1');

      expect(updated.customerId, 'customer-1');
      expect(updated.status, RepairOrderStatus.pending);
    });

    test('clearCustomer removes customerId', () {
      const base = RepairOrderFilter(customerId: 'customer-1');
      final cleared = base.copyWith(clearCustomer: true);

      expect(cleared.customerId, isNull);
    });
  });
}
