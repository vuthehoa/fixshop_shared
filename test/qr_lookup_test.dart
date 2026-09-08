import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fixshop_shared/fixshop_shared.dart';

class _MockDeviceRepository extends Mock implements DeviceRepository {}

DeviceEntity _device({
  required String id,
  required String deviceCode,
  String customerId = 'customer-1',
  String customerName = 'Nguyen Van A',
}) {
  final now = DateTime(2026, 1, 1);
  return DeviceEntity(
    id: id,
    deviceCode: deviceCode,
    customerId: customerId,
    customerName: customerName,
    customerPhone: '0900000000',
    manufacturerId: 'manufacturer-1',
    manufacturerName: 'Apple',
    productFamilyId: 'family-1',
    productFamilyName: 'iPhone',
    modelId: 'model-1',
    modelName: 'iPhone 15',
    deviceName: 'iPhone 15 Pro Max',
    serialNumber: 'SN-001',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('QrPayloadBuilder', () {
    test('same device code -> same payload (deterministic)', () {
      expect(QrPayloadBuilder.forDevice('000001'),
          QrPayloadBuilder.forDevice('000001'));
    });

    test('different device codes -> different payloads', () {
      expect(
        QrPayloadBuilder.forDevice('000001'),
        isNot(QrPayloadBuilder.forDevice('000002')),
      );
    });

    test('payload never encodes anything beyond the device code', () {
      expect(QrPayloadBuilder.forDevice('000001'), 'DEVICE-000001');
    });

    test('parseDeviceCode reverses forDevice', () {
      final payload = QrPayloadBuilder.forDevice('000123');
      expect(QrPayloadBuilder.parseDeviceCode(payload), '000123');
    });

    test('parseDeviceCode rejects malformed payloads', () {
      expect(QrPayloadBuilder.parseDeviceCode('NOT-A-DEVICE-CODE'), isNull);
      expect(QrPayloadBuilder.parseDeviceCode(''), isNull);
      expect(QrPayloadBuilder.parseDeviceCode('DEVICE-'), isNull);
    });

    test('DeviceEntity.qrPayload is a pure function of deviceCode', () {
      final a = _device(id: 'a', deviceCode: '000001');
      final b = _device(id: 'b', deviceCode: '000001');
      final c = _device(id: 'c', deviceCode: '000002');

      expect(a.qrPayload, b.qrPayload);
      expect(a.qrPayload, isNot(c.qrPayload));
    });
  });

  group('LookupDeviceByQrUseCase', () {
    late _MockDeviceRepository repository;
    late LookupDeviceByQrUseCase useCase;

    setUp(() {
      repository = _MockDeviceRepository();
      useCase = LookupDeviceByQrUseCase(repository);
    });

    test(
        'valid payload resolves to the Device, exposing Customer/Warranty fields',
        () async {
      final device = _device(id: 'device-1', deviceCode: '000001');
      when(() => repository.getDeviceByCode('000001'))
          .thenAnswer((_) async => Right(device));

      final result =
          await useCase(const LookupDeviceByQrParams('DEVICE-000001'));

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (resolved) {
          expect(resolved.id, 'device-1');
          // Device → Customer resolution: already carried on DeviceEntity,
          // nothing new to duplicate for QR lookup.
          expect(resolved.customerId, 'customer-1');
          // Device → Warranty resolution: derived getter, read straight
          // from the resolved Device — never duplicated onto QR data.
          expect(resolved.warrantyStatus, WarrantyStatus.notActivated);
        },
      );
      verify(() => repository.getDeviceByCode('000001')).called(1);
    });

    test(
        'invalid QR payload format is rejected without touching the repository',
        () async {
      final result =
          await useCase(const LookupDeviceByQrParams('not-a-valid-payload'));

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<OperationNotAllowedFailure>()),
        (_) => fail('expected Left(OperationNotAllowedFailure)'),
      );
      verifyNever(() => repository.getDeviceByCode(any()));
    });

    test('non-existent device propagates NotFoundFailure from the repository',
        () async {
      when(() => repository.getDeviceByCode('999999')).thenAnswer(
          (_) async => const Left(NotFoundFailure('Không tìm thấy thiết bị.')));

      final result =
          await useCase(const LookupDeviceByQrParams('DEVICE-999999'));

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('expected Left(NotFoundFailure)'),
      );
    });
  });
}
