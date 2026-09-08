import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../device/domain/repositories/device_repository.dart';
import '../../../device/domain/value_objects/device_filter.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

/// Staff-triggered scan for devices whose warranty is about to expire — the
/// closest honest implementation of the BRD's "upcoming warranty
/// expiration" notification. There is no background scheduler/Cloud
/// Function in this repository, so this cannot run automatically; a CMS
/// user runs it from the Notification Center, and it is itself logged as an
/// ActivityLog entry (see `ActivityActions.scanWarrantyExpirations`) since
/// it's a real, privileged, customer-communication-generating action.
///
/// Reuses `DeviceFilter.warrantyExpiringFrom/To` (already existed since the
/// Device module) rather than adding a new query — see the Sprint 14 report.
class ScanWarrantyExpiringNotificationsUseCase
    extends UseCase<int, ScanWarrantyExpiringParams> {
  final DeviceRepository _deviceRepository;
  final NotificationRepository _notificationRepository;

  ScanWarrantyExpiringNotificationsUseCase(
      this._deviceRepository, this._notificationRepository);

  @override
  Future<Either<Failure, int>> call(ScanWarrantyExpiringParams params) async {
    if (!PermissionResolver.hasPermission(
        params.actor.role, Permission.manageWarranty)) {
      return const Left(
        OperationNotAllowedFailure(
            'Bạn không có quyền quét cảnh báo bảo hành.'),
      );
    }

    final now = DateTime.now();
    final devicesResult = await _deviceRepository.getDevices(
      DeviceFilter(
        warrantyExpiringFrom: now,
        warrantyExpiringTo: now.add(Duration(days: params.withinDays)),
        pageSize: 500,
      ),
    );

    return devicesResult.fold(
      (failure) async => Left(failure),
      (page) async {
        var created = 0;
        final dedupeSince =
            now.subtract(Duration(days: params.dedupeWindowDays));

        for (final device in page.items) {
          if (device.warrantyVoidedAt != null) continue;

          final recentResult =
              await _notificationRepository.hasRecentNotification(
            targetId: device.id,
            type: NotificationType.warrantyExpiring,
            since: dedupeSince,
          );
          final alreadyNotified = recentResult.fold((_) => false, (v) => v);
          if (alreadyNotified) continue;

          await _notificationRepository.createNotification(
            NotificationEntity(
              id: '',
              type: NotificationType.warrantyExpiring,
              title: 'Bảo hành sắp hết hạn',
              body:
                  'Thiết bị ${device.deviceName} (${device.deviceCode}) của khách hàng '
                  '${device.customerName} sẽ hết hạn bảo hành vào '
                  '${device.warrantyExpiredAt?.toIso8601String().split('T').first}.',
              customerId: device.customerId,
              customerName: device.customerName,
              targetType: 'device',
              targetId: device.id,
              createdBy: params.actor.id,
              createdAt: now,
            ),
          );
          created++;
        }
        return Right(created);
      },
    );
  }
}

class ScanWarrantyExpiringParams extends Equatable {
  final UserEntity actor;
  final int withinDays;
  final int dedupeWindowDays;

  const ScanWarrantyExpiringParams({
    required this.actor,
    this.withinDays = 30,
    this.dedupeWindowDays = 30,
  });

  @override
  List<Object?> get props => [actor, withinDays, dedupeWindowDays];
}
