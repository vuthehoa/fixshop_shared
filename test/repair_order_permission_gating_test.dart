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

RepairOrderEntity _order(
    {RepairOrderStatus status = RepairOrderStatus.received}) {
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
    currentStatus: status,
    problemDescription: 'Màn hình vỡ',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_actor(UserRole.admin));
  });

  group('AssignRepairOrderTechnicianUseCase — Sprint 10 reconfirmation', () {
    late _MockRepairOrderRepository repository;
    late AssignRepairOrderTechnicianUseCase useCase;

    setUp(() {
      repository = _MockRepairOrderRepository();
      useCase = AssignRepairOrderTechnicianUseCase(repository);
    });

    test('technician cannot assign — denied without touching the repository',
        () async {
      final params = AssignRepairOrderTechnicianParams(
        id: 'order-1',
        technicianId: 'tech-1',
        technicianName: 'Le Van B',
        actor: _actor(UserRole.technician),
      );

      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<OperationNotAllowedFailure>()),
        (_) => fail('expected a Left(OperationNotAllowedFailure)'),
      );
      verifyNever(() => repository.assignTechnician(
            any(),
            technicianId: any(named: 'technicianId'),
            technicianName: any(named: 'technicianName'),
            actor: any(named: 'actor'),
          ));
    });

    test('reception can assign', () async {
      final order = _order(status: RepairOrderStatus.assigned);
      when(() => repository.assignTechnician(
            any(),
            technicianId: any(named: 'technicianId'),
            technicianName: any(named: 'technicianName'),
            actor: any(named: 'actor'),
          )).thenAnswer((_) async => Right(order));

      final params = AssignRepairOrderTechnicianParams(
        id: 'order-1',
        technicianId: 'tech-1',
        technicianName: 'Le Van B',
        actor: _actor(UserRole.reception),
      );

      final result = await useCase(params);

      expect(result.isRight(), isTrue);
      verify(() => repository.assignTechnician(
            'order-1',
            technicianId: 'tech-1',
            technicianName: 'Le Van B',
            actor: any(named: 'actor'),
          )).called(1);
    });

    test('manager and admin hold assignRepairOrder', () {
      expect(
        PermissionResolver.hasPermission(
            UserRole.manager, Permission.assignRepairOrder),
        isTrue,
      );
      expect(
        PermissionResolver.hasPermission(
            UserRole.admin, Permission.assignRepairOrder),
        isTrue,
      );
    });

    test('technician does NOT hold assignRepairOrder', () {
      expect(
        PermissionResolver.hasPermission(
            UserRole.technician, Permission.assignRepairOrder),
        isFalse,
      );
    });
  });

  group(
      'FailTestingUseCase — preserves historical startedAt via the repository contract',
      () {
    test(
        'delegates notes through unchanged and does not touch startedAt directly',
        () async {
      final repository = _MockRepairOrderRepository();
      final useCase = FailTestingUseCase(repository);
      final beforeFailure = _order(status: RepairOrderStatus.testing).copyWith(
        startedAt: DateTime(2025, 12, 1),
      );
      final afterFailure =
          beforeFailure.copyWith(currentStatus: RepairOrderStatus.repairing);

      when(() => repository.failTesting(
            any(),
            actor: any(named: 'actor'),
            notes: any(named: 'notes'),
          )).thenAnswer((_) async => Right(afterFailure));

      final result = await useCase(FailTestingParams(
        id: 'order-1',
        actor: _actor(UserRole.technician),
        notes: 'Màn hình vẫn còn sọc',
      ));

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (updated) => expect(updated.startedAt, beforeFailure.startedAt),
      );
      verify(() => repository.failTesting(
            'order-1',
            actor: any(named: 'actor'),
            notes: 'Màn hình vẫn còn sọc',
          )).called(1);
    });
  });
}
