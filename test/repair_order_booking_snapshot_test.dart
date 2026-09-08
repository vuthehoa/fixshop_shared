import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

RepairOrderEntity _baseOrder({String customerId = 'customer-1'}) {
  final now = DateTime(2026, 1, 1);
  return RepairOrderEntity(
    id: 'order-1',
    repairOrderCode: 'RO-001',
    customerId: customerId,
    customerName: 'Nguyen Van A',
    customerPhone: '0900000000',
    deviceId: 'device-1',
    deviceCode: 'DV-001',
    deviceName: 'iPhone 15 Pro Max',
    serialNumber: 'SN-001',
    manufacturerId: 'manufacturer-1',
    manufacturerName: 'Apple',
    createdBy: 'user-0',
    problemDescription: 'Pin yếu',
    createdAt: now,
    updatedAt: now,
  );
}

/// Exact transcription of `FirestoreRepairBookingSubmissionRepository
/// ._toFirestore` in fixshop_mobile_app — see that file's field order and
/// values for the source of truth this fixture mirrors.
Map<String, dynamic> _mobileM4GuestBookingPayload() => {
      'bookingRequestId': 'booking-req-1',
      'source': 'customer_app',
      'currentStatus': 'pending',
      'repairOrderCode': '',
      'customerId': null,
      'customerName': 'Nguyen Van B',
      'customerPhone': '0911111111',
      'contact': {
        'name': 'Nguyen Van B',
        'phone': '0911111111',
        'email': 'b@example.com'
      },
      'deviceId': '',
      'deviceCode': '',
      'deviceName': 'iPhone 13 Pro Max',
      'serialNumber': '',
      'manufacturerId': '',
      'manufacturerName': 'Apple',
      'deviceSnapshot': {
        'catalogModelId': 'iphone_13_pro_max',
        'commercialModelName': 'iPhone 13 Pro Max',
        'brand': 'Apple',
        'platform': 'ios',
        'hardwareIdentifier': 'iPhone14,3',
        'deviceType': 'phone',
        'osVersion': '17.0',
      },
      'serviceSnapshot': {
        'categoryId': 'cat-1',
        'categoryCode': 'iphone_battery',
        'categoryName': 'Pin iPhone',
        'serviceId': 'svc-1',
        'variantCode': 'battery_with_flex',
        'variantName': 'Pin có cổ',
        'basePrice': 800000,
        'currency': 'VND',
        'selectedAddons': [
          {
            'code': 'fix_3utools_duplicate',
            'name': 'Fix trùng 3uTools',
            'price': 0
          },
        ],
        'estimatedPrice': 800000,
      },
      'estimatedCost': 800000,
      'appointment': {
        'date': Timestamp.fromDate(DateTime(2026, 2, 1)),
        'slotId': 'slot-1',
        'slotStart': '09:00',
        'slotEnd': '10:00',
        'slotDisplayLabel': '09:00 - 10:00',
      },
      'fulfillmentMethod': 'pickup',
      'pickupAddress': '123 Le Loi, Q1',
      'problemDescription': 'Pin tụt nhanh',
      'attachments': <String>[],
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 15)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 15)),
    };

void main() {
  group('RepairOrderEntity — new booking fields are additive', () {
    test(
        'a plain-constructed legacy-shaped order has null booking fields by default',
        () {
      final order = _baseOrder();
      expect(order.bookingRequestId, isNull);
      expect(order.source, isNull);
      expect(order.contact, isNull);
      expect(order.deviceSnapshot, isNull);
      expect(order.serviceSnapshot, isNull);
      expect(order.appointment, isNull);
      expect(order.fulfillmentMethod, isNull);
      expect(order.isGuestBooking, isFalse);
    });
  });

  group('RepairOrderModel.fromFirestore — legacy compatibility', () {
    test('a legacy document with none of the M4 fields parses without crashing',
        () {
      final doc = _MockDocumentSnapshot();
      when(() => doc.id).thenReturn('legacy-1');
      when(() => doc.data()).thenReturn({
        'repairOrderCode': 'RO-100',
        'customerId': 'customer-1',
        'customerName': 'Old Customer',
        'customerPhone': '0900000000',
        'deviceId': 'device-1',
        'deviceCode': 'DV-100',
        'deviceName': 'iPhone 12',
        'serialNumber': 'SN-100',
        'manufacturerId': 'm-1',
        'manufacturerName': 'Apple',
        'createdBy': 'user-1',
        'currentStatus': 'pending',
        'problemDescription': 'Vỡ màn hình',
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final model = RepairOrderModel.fromFirestore(doc);

      expect(model.repairOrderCode, 'RO-100');
      expect(model.bookingRequestId, isNull);
      expect(model.source, isNull);
      expect(model.contact, isNull);
      expect(model.isGuestBooking, isFalse);
    });
  });

  group('RepairOrderModel.fromFirestore — Mobile M4 customer-app booking parse',
      () {
    test(
        'the exact mobile M4 guest payload parses into every typed field correctly',
        () {
      final doc = _MockDocumentSnapshot();
      when(() => doc.id).thenReturn('booking-req-1');
      when(() => doc.data()).thenReturn(_mobileM4GuestBookingPayload());

      final model = RepairOrderModel.fromFirestore(doc);

      expect(model.bookingRequestId, 'booking-req-1');
      expect(model.source, RepairOrderSource.customerApp);
      expect(model.repairOrderCode,
          ''); // empty, not null — legacy parser compatibility
      expect(model.customerId,
          ''); // Firestore null -> '' per existing entity contract
      expect(model.isGuestBooking, isTrue);

      expect(model.contact, isNotNull);
      expect(model.contact!.name, 'Nguyen Van B');
      expect(model.contact!.phone, '0911111111');
      expect(model.contact!.email, 'b@example.com');

      expect(model.deviceSnapshot, isNotNull);
      expect(model.deviceSnapshot!.catalogModelId, 'iphone_13_pro_max');
      expect(model.deviceSnapshot!.hardwareIdentifier, 'iPhone14,3');

      expect(model.serviceSnapshot, isNotNull);
      expect(model.serviceSnapshot!.categoryCode, 'iphone_battery');
      expect(model.serviceSnapshot!.basePrice, 800000);
      expect(model.serviceSnapshot!.estimatedPrice, 800000);

      // Zero-price addon must survive parsing intact — never dropped or
      // coerced into "missing".
      expect(model.serviceSnapshot!.selectedAddons, hasLength(1));
      expect(model.serviceSnapshot!.selectedAddons.single.price, 0);
      expect(model.serviceSnapshot!.selectedAddons.single.code,
          'fix_3utools_duplicate');

      expect(model.appointment, isNotNull);
      expect(model.appointment!.date, DateTime(2026, 2, 1));
      expect(model.appointment!.slotDisplayLabel, '09:00 - 10:00');

      expect(model.fulfillmentMethod, RepairFulfillmentMethod.pickup);
      expect(model.pickupAddress, '123 Le Loi, Q1');
      expect(model.storeAddress, isNull);

      // Legacy-compatible fields still populated for old readers.
      expect(model.customerName, 'Nguyen Van B');
      expect(model.estimatedCost, 800000);
      expect(model.currentStatus, RepairOrderStatus.pending);
    });

    test(
        'an authenticated customer booking (customerId + createdBy present) is not a guest booking',
        () {
      final payload = _mobileM4GuestBookingPayload();
      payload['customerId'] = 'customer-42';
      payload['createdBy'] = 'firebase-uid-42';

      final doc = _MockDocumentSnapshot();
      when(() => doc.id).thenReturn('booking-req-2');
      when(() => doc.data()).thenReturn(payload);

      final model = RepairOrderModel.fromFirestore(doc);

      expect(model.customerId, 'customer-42');
      expect(model.createdBy, 'firebase-uid-42');
      expect(model.isGuestBooking, isFalse);
    });

    test(
        'fulfillmentMethod storeDropOff with no pickupAddress parses correctly',
        () {
      final payload = _mobileM4GuestBookingPayload();
      payload['fulfillmentMethod'] = 'storeDropOff';
      payload.remove('pickupAddress');
      payload['storeAddress'] = 'FixShop Q1 Store';

      final doc = _MockDocumentSnapshot();
      when(() => doc.id).thenReturn('booking-req-3');
      when(() => doc.data()).thenReturn(payload);

      final model = RepairOrderModel.fromFirestore(doc);

      expect(model.fulfillmentMethod, RepairFulfillmentMethod.storeDropOff);
      expect(model.pickupAddress, isNull);
      expect(model.storeAddress, 'FixShop Q1 Store');
    });
  });

  group('RepairOrderModel — round trip', () {
    test('toFirestore -> fromFirestore preserves every booking field', () {
      final original =
          RepairOrderModel.fromEntity(_baseOrder(customerId: '')).copyWith(
        bookingRequestId: 'req-99',
        source: RepairOrderSource.customerApp,
        contact: const BookingContactSnapshot(name: 'A', phone: '090'),
        deviceSnapshot: const BookingDeviceSnapshot(
          commercialModelName: 'iPhone 15',
          brand: 'Apple',
          platform: 'ios',
          hardwareIdentifier: 'iPhone16,1',
          deviceType: 'phone',
          osVersion: '18.0',
        ),
        serviceSnapshot: const BookingServiceSnapshot(
          categoryId: 'cat-1',
          categoryCode: 'iphone_battery',
          categoryName: 'Pin iPhone',
          serviceId: 'svc-1',
          variantCode: 'battery_with_flex',
          variantName: 'Pin có cổ',
          basePrice: 600000,
          selectedAddons: [
            BookingAddonSnapshot(code: 'a1', name: 'A1', price: 0)
          ],
          estimatedPrice: 600000,
        ),
        appointment: BookingAppointmentSnapshot(
          date: DateTime(2026, 3, 1),
          slotId: 's1',
          slotStart: '10:00',
          slotEnd: '11:00',
          slotDisplayLabel: '10:00 - 11:00',
        ),
        fulfillmentMethod: RepairFulfillmentMethod.pickup,
        pickupAddress: '1 Main St',
      );

      final asModel = RepairOrderModel.fromEntity(original);
      final doc = _MockDocumentSnapshot();
      when(() => doc.id).thenReturn(asModel.id);
      when(() => doc.data()).thenReturn(asModel.toFirestore());

      final restored = RepairOrderModel.fromFirestore(doc);

      expect(restored.bookingRequestId, 'req-99');
      expect(restored.source, RepairOrderSource.customerApp);
      expect(restored.serviceSnapshot!.selectedAddons.single.price, 0);
      expect(restored.appointment!.date, DateTime(2026, 3, 1));
      expect(restored.fulfillmentMethod, RepairFulfillmentMethod.pickup);
    });
  });
}
