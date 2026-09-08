import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/qr/qr_payload_builder.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

/// The single entry point for "scanned/typed QR payload → Device" — the CMS
/// lookup half of the QR flow (see `QrPayloadBuilder` for the encode half).
/// Parsing happens here, not in the UI, so any future consumer of the same
/// payload format (e.g. a future Customer App) has one canonical place this
/// logic could be shared from.
class LookupDeviceByQrUseCase
    extends UseCase<DeviceEntity, LookupDeviceByQrParams> {
  final DeviceRepository _repository;

  LookupDeviceByQrUseCase(this._repository);

  @override
  Future<Either<Failure, DeviceEntity>> call(LookupDeviceByQrParams params) {
    final deviceCode = QrPayloadBuilder.parseDeviceCode(params.payload);
    if (deviceCode == null) {
      return Future.value(
        const Left(OperationNotAllowedFailure('Mã QR không hợp lệ.')),
      );
    }
    return _repository.getDeviceByCode(deviceCode);
  }
}

class LookupDeviceByQrParams extends Equatable {
  final String payload;

  const LookupDeviceByQrParams(this.payload);

  @override
  List<Object> get props => [payload];
}
