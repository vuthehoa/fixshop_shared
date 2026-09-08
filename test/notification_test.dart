import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fixshop_shared/fixshop_shared.dart';

class _MockDeviceRepository extends Mock implements DeviceRepository {}

class _MockNotificationRepository extends Mock
    implements NotificationRepository {}

UserEntity _actor(UserRole role) {
  final now = DateTime(2026, 1, 1);
  return UserEntity(
    id: 'user-1',
    email: 'actor@fixshop.test',
    displayName: 'Test Actor',
    role: role,
    createdAt: now,
    updatedAt: now,
  );
}

DeviceEntity _device({
  required String id,
  DateTime? warrantyExpiredAt,
  DateTime? warrantyVoidedAt,
}) {
  final now = DateTime(2026, 1, 1);
  return DeviceEntity(
    id: id,
    deviceCode: 'DV-$id',
    customerId: 'customer-1',
    customerName: 'Nguyen Van A',
    customerPhone: '0900000000',
    manufacturerId: 'manufacturer-1',
    manufacturerName: 'Apple',
    productFamilyId: 'family-1',
    productFamilyName: 'iPhone',
    modelId: 'model-1',
    modelName: 'iPhone 15',
    deviceName: 'iPhone 15 Pro Max',
    serialNumber: 'SN-$id',
    warrantyExpiredAt: warrantyExpiredAt,
    warrantyVoidedAt: warrantyVoidedAt,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const DeviceFilter());
    registerFallbackValue(NotificationType.warrantyExpiring);
    registerFallbackValue(
      NotificationEntity(
        id: '',
        type: NotificationType.warrantyExpiring,
        title: 't',
        body: 'b',
        customerId: 'c',
        customerName: 'n',
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  });

  group('NotificationEntity', () {
    test('isRead reflects readAt', () {
      final unread = NotificationEntity(
        id: '1',
        type: NotificationType.repairCompleted,
        title: 't',
        body: 'b',
        customerId: 'c',
        customerName: 'n',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(unread.isRead, isFalse);
      expect(unread.copyWith(readAt: DateTime(2026, 1, 2)).isRead, isTrue);
    });
  });

  group('ScanWarrantyExpiringNotificationsUseCase', () {
    late _MockDeviceRepository deviceRepository;
    late _MockNotificationRepository notificationRepository;
    late ScanWarrantyExpiringNotificationsUseCase useCase;

    setUp(() {
      deviceRepository = _MockDeviceRepository();
      notificationRepository = _MockNotificationRepository();
      useCase = ScanWarrantyExpiringNotificationsUseCase(
          deviceRepository, notificationRepository);
    });

    test('technician lacks manageWarranty — denied without querying devices',
        () async {
      final result = await useCase(
          ScanWarrantyExpiringParams(actor: _actor(UserRole.technician)));

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<OperationNotAllowedFailure>()),
        (_) => fail('expected Left'),
      );
      verifyNever(() => deviceRepository.getDevices(any()));
    });

    test('reception holds manageWarranty and can run the scan', () async {
      final expiringDevice = _device(
        id: 'device-1',
        warrantyExpiredAt: DateTime.now().add(const Duration(days: 10)),
      );

      when(() => deviceRepository.getDevices(any())).thenAnswer(
        (_) async =>
            Right(PaginatedResult(items: [expiringDevice], hasMore: false)),
      );
      when(() => notificationRepository.hasRecentNotification(
            targetId: any(named: 'targetId'),
            type: any(named: 'type'),
            since: any(named: 'since'),
          )).thenAnswer((_) async => const Right(false));
      when(() => notificationRepository.createNotification(any())).thenAnswer(
          (invocation) async => Right(invocation.positionalArguments.first));

      final result = await useCase(
          ScanWarrantyExpiringParams(actor: _actor(UserRole.reception)));

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (count) => expect(count, 1));
      verify(() => notificationRepository.createNotification(any())).called(1);
    });

    test('skips devices with a voided warranty', () async {
      final voidedDevice = _device(
        id: 'device-2',
        warrantyExpiredAt: DateTime.now().add(const Duration(days: 5)),
        warrantyVoidedAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      when(() => deviceRepository.getDevices(any())).thenAnswer(
        (_) async =>
            Right(PaginatedResult(items: [voidedDevice], hasMore: false)),
      );

      final result = await useCase(
          ScanWarrantyExpiringParams(actor: _actor(UserRole.manager)));

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (count) => expect(count, 0));
      verifyNever(() => notificationRepository.createNotification(any()));
    });

    test('skips devices already notified within the dedupe window', () async {
      final device = _device(
        id: 'device-3',
        warrantyExpiredAt: DateTime.now().add(const Duration(days: 10)),
      );

      when(() => deviceRepository.getDevices(any())).thenAnswer(
        (_) async => Right(PaginatedResult(items: [device], hasMore: false)),
      );
      when(() => notificationRepository.hasRecentNotification(
            targetId: any(named: 'targetId'),
            type: any(named: 'type'),
            since: any(named: 'since'),
          )).thenAnswer((_) async => const Right(true));

      final result = await useCase(
          ScanWarrantyExpiringParams(actor: _actor(UserRole.admin)));

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (count) => expect(count, 0));
      verifyNever(() => notificationRepository.createNotification(any()));
    });

    test('empty device result — zero notifications created, no crash',
        () async {
      when(() => deviceRepository.getDevices(any())).thenAnswer(
        (_) async => const Right(PaginatedResult(items: [], hasMore: false)),
      );

      final result = await useCase(
          ScanWarrantyExpiringParams(actor: _actor(UserRole.admin)));

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (count) => expect(count, 0));
    });
  });
}
