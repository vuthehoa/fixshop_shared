import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/value_objects/device_filter.dart';
import '../datasources/device_remote_datasource.dart';
import '../models/device_model.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource _dataSource;

  DeviceRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, DeviceEntity>> getDevice(String id) =>
      _run(() => _dataSource.getDevice(id));

  @override
  Future<Either<Failure, DeviceEntity>> getDeviceByCode(String deviceCode) =>
      _run(() => _dataSource.getDeviceByCode(deviceCode));

  @override
  Future<Either<Failure, PaginatedResult<DeviceEntity>>> getDevices(
    DeviceFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    final result = await _run(
        () => _dataSource.getDevices(filter, startAfter: startAfter));
    return result.map(
      (page) => PaginatedResult<DeviceEntity>(
        items: page.items,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
      ),
    );
  }

  @override
  Future<Either<Failure, List<DeviceEntity>>> getActiveDevices(
          {String? customerId}) =>
      _run(() => _dataSource.getActiveDevices(customerId: customerId));

  @override
  Future<Either<Failure, DeviceEntity>> createDevice(DeviceEntity entity) =>
      _run(() => _dataSource.createDevice(DeviceModel.fromEntity(entity)));

  @override
  Future<Either<Failure, DeviceEntity>> updateDevice(DeviceEntity entity) =>
      _run(() => _dataSource.updateDevice(DeviceModel.fromEntity(entity)));

  @override
  Future<Either<Failure, void>> archiveDevice(String id) =>
      _runVoid(() => _dataSource.archiveDevice(id));

  @override
  Future<Either<Failure, void>> restoreDevice(String id) =>
      _runVoid(() => _dataSource.restoreDevice(id));

  @override
  Future<Either<Failure, DeviceEntity>> activateWarranty(
    String id, {
    required int warrantyPeriodMonths,
  }) =>
      _run(() => _dataSource.activateWarranty(id,
          warrantyPeriodMonths: warrantyPeriodMonths));

  @override
  Future<Either<Failure, DeviceEntity>> voidWarranty(String id) =>
      _run(() => _dataSource.voidWarranty(id));

  @override
  Future<Either<Failure, DeviceEntity>> restoreWarranty(String id) =>
      _run(() => _dataSource.restoreWarranty(id));

  Future<Either<Failure, T>> _run<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on DuplicateCodeException catch (e) {
      return Left(DuplicateCodeFailure(e.message));
    } on DuplicateSerialNumberException catch (e) {
      return Left(DuplicateSerialNumberFailure(e.message));
    } on DuplicateImeiException catch (e) {
      return Left(DuplicateImeiFailure(e.message));
    } on HasActiveChildrenException catch (e) {
      return Left(HasActiveChildrenFailure(e.message));
    } on OperationNotAllowedException catch (e) {
      return Left(OperationNotAllowedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> _runVoid(Future<void> Function() fn) =>
      _run<void>(fn);
}
