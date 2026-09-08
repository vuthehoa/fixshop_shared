import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fixshop_shared/fixshop_shared.dart';

class _MockRepairOrderRepository extends Mock
    implements RepairOrderRepository {}

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

RepairOrderEntity _order() {
  final now = DateTime(2026, 1, 1);
  return RepairOrderEntity(
    id: 'order-1',
    repairOrderCode: 'RO-001',
    customerId: 'customer-1',
    customerName: 'Nguyen Van A',
    customerPhone: '0900000000',
    deviceId: 'device-1',
    deviceCode: 'DV-001',
    deviceName: 'iPhone 15 Pro Max',
    serialNumber: 'SN-001',
    manufacturerId: 'manufacturer-1',
    manufacturerName: 'Apple',
    createdBy: 'user-0',
    currentStatus: RepairOrderStatus.completed,
    problemDescription: 'Màn hình vỡ',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const DeliveryInfo(recipientName: 'fallback'),
    );
    registerFallbackValue(_actor(UserRole.admin));
  });

  group('DeliverRepairOrderUseCase — permission gating', () {
    late _MockRepairOrderRepository repository;
    late DeliverRepairOrderUseCase useCase;

    setUp(() {
      repository = _MockRepairOrderRepository();
      useCase = DeliverRepairOrderUseCase(repository);
    });

    test(
        'reception lacks completeRepairOrder — denied without touching the repository',
        () async {
      final params = DeliverRepairOrderParams(
        id: 'order-1',
        delivery: const DeliveryInfo(recipientName: 'Nguyen Van B'),
        actor: _actor(UserRole.reception),
      );

      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<OperationNotAllowedFailure>()),
        (_) => fail('expected a Left(OperationNotAllowedFailure)'),
      );
      verifyNever(() => repository.deliverRepairOrder(
            any(),
            delivery: any(named: 'delivery'),
            actor: any(named: 'actor'),
          ));
    });

    test('technician holds completeRepairOrder — delegates to the repository',
        () async {
      final order = _order();
      when(() => repository.deliverRepairOrder(
                any(),
                delivery: any(named: 'delivery'),
                actor: any(named: 'actor'),
              ))
          .thenAnswer((_) async => Right(
              order.copyWith(currentStatus: RepairOrderStatus.delivered)));

      final params = DeliverRepairOrderParams(
        id: 'order-1',
        delivery: const DeliveryInfo(recipientName: 'Nguyen Van B'),
        actor: _actor(UserRole.technician),
      );

      final result = await useCase(params);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected a Right(RepairOrderEntity)'),
        (updated) => expect(updated.currentStatus, RepairOrderStatus.delivered),
      );
      verify(() => repository.deliverRepairOrder(
            'order-1',
            delivery: any(named: 'delivery'),
            actor: any(named: 'actor'),
          )).called(1);
    });

    test('manager and admin also hold completeRepairOrder', () {
      expect(
        PermissionResolver.hasPermission(
            UserRole.manager, Permission.completeRepairOrder),
        isTrue,
      );
      expect(
        PermissionResolver.hasPermission(
            UserRole.admin, Permission.completeRepairOrder),
        isTrue,
      );
    });
  });
}
