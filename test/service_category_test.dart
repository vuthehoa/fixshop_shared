import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('ServiceCategoryFilter', () {
    test('equality includes enabled', () {
      const a = ServiceCategoryFilter(enabled: true);
      const b = ServiceCategoryFilter(enabled: true);
      const c = ServiceCategoryFilter(enabled: false);

      expect(a, b);
      expect(a, isNot(c));
    });

    test('copyWith(clearEnabled: true) removes the enabled filter', () {
      const base = ServiceCategoryFilter(enabled: true);
      final cleared = base.copyWith(clearEnabled: true);

      expect(cleared.enabled, isNull);
    });
  });

  group('ServiceCategoryEntity', () {
    final now = DateTime(2026, 1, 1);

    ServiceCategoryEntity category({bool enabled = true, int order = 0}) {
      return ServiceCategoryEntity(
        id: 'cat-1',
        code: 'iphone_battery',
        name: 'Pin iPhone',
        enabled: enabled,
        order: order,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('status archived and enabled false are independent flags', () {
      final archivedButEnabled =
          category().copyWith(status: CatalogStatus.archived);
      expect(archivedButEnabled.isArchived, isTrue);
      expect(archivedButEnabled.enabled, isTrue);

      final activeButDisabled = category(enabled: false);
      expect(activeButDisabled.isActive, isTrue);
      expect(activeButDisabled.enabled, isFalse);
    });

    test('copyWith preserves fields not overridden', () {
      final original = category(order: 10);
      final renamed = original.copyWith(name: 'Pin iPhone (mới)');

      expect(renamed.name, 'Pin iPhone (mới)');
      expect(renamed.code, original.code);
      expect(renamed.order, 10);
    });
  });

  group('ServiceCategoryModel.fromFirestore', () {
    test(
        'legacy document without enabled/order does not crash and defaults sensibly',
        () {
      final doc = _MockDocumentSnapshot();
      when(() => doc.id).thenReturn('cat-legacy');
      when(() => doc.data()).thenReturn({
        'code': 'iphone_battery',
        'name': 'Pin iPhone',
        'status': 'active',
      });

      final model = ServiceCategoryModel.fromFirestore(doc);

      expect(model.id, 'cat-legacy');
      expect(model.enabled, isTrue);
      expect(model.order, 0);
      expect(model.description, isNull);
    });

    test('round-trips through toFirestore/fromFirestore', () {
      final now = DateTime(2026, 1, 1);
      final original = ServiceCategoryModel(
        id: 'cat-1',
        code: 'iphone_battery',
        name: 'Pin iPhone',
        description: 'Danh mục pin',
        enabled: false,
        order: 5,
        status: CatalogStatus.active,
        createdAt: now,
        updatedAt: now,
        createdBy: 'user-1',
      );

      final doc = _MockDocumentSnapshot();
      when(() => doc.id).thenReturn(original.id);
      when(() => doc.data()).thenReturn(original.toFirestore());

      final roundTripped = ServiceCategoryModel.fromFirestore(doc);

      expect(roundTripped.code, original.code);
      expect(roundTripped.name, original.name);
      expect(roundTripped.description, original.description);
      expect(roundTripped.enabled, original.enabled);
      expect(roundTripped.order, original.order);
    });
  });
}
