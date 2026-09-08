import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/device_entity.dart';
import '../value_objects/device_filter.dart';

abstract class DeviceRepository {
  Future<Either<Failure, DeviceEntity>> getDevice(String id);

  /// Resolves a device by its canonical, human-scannable [deviceCode] —
  /// the identifier the QR payload encodes (see `QrPayloadBuilder`). Fails
  /// with [NotFoundFailure] if no device has that code.
  Future<Either<Failure, DeviceEntity>> getDeviceByCode(String deviceCode);

  Future<Either<Failure, PaginatedResult<DeviceEntity>>> getDevices(
    DeviceFilter filter, {
    DocumentSnapshot? startAfter,
  });

  /// Unpaginated, non-archived list — feeds dropdowns (e.g. the device
  /// picker Warranty/Repair Order will need in Sprint 6+), optionally
  /// scoped to a single customer.
  Future<Either<Failure, List<DeviceEntity>>> getActiveDevices(
      {String? customerId});

  Future<Either<Failure, DeviceEntity>> createDevice(DeviceEntity entity);

  Future<Either<Failure, DeviceEntity>> updateDevice(DeviceEntity entity);

  Future<Either<Failure, void>> archiveDevice(String id);

  Future<Either<Failure, void>> restoreDevice(String id);

  /// Activates the embedded warranty. Fails if already activated, if the
  /// device is archived, or if the device has no customer/purchase date.
  /// Also transitions [DeviceEntity.status] to [DeviceStatus.underWarranty]
  /// — warranty activation is part of the device lifecycle, not a
  /// side-channel update.
  Future<Either<Failure, DeviceEntity>> activateWarranty(
    String id, {
    required int warrantyPeriodMonths,
  });

  /// Manually ends a warranty before its natural expiration date.
  Future<Either<Failure, DeviceEntity>> voidWarranty(String id);

  /// Reverses a manual void. Natural time-based expiration is not affected
  /// by this — a warranty restored past its `warrantyExpiredAt` reads back
  /// as [WarrantyStatus.expired] immediately.
  Future<Either<Failure, DeviceEntity>> restoreWarranty(String id);
}
