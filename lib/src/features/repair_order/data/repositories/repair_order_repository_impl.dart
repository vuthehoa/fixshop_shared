import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/delivery_info.dart';
import '../../domain/entities/reception_info.dart';
import '../../domain/entities/repair_execution_info.dart';
import '../../domain/entities/repair_order_entity.dart';
import '../../domain/repositories/repair_order_repository.dart';
import '../../domain/value_objects/repair_order_filter.dart';
import '../datasources/repair_order_remote_datasource.dart';
import '../models/repair_order_model.dart';

class RepairOrderRepositoryImpl implements RepairOrderRepository {
  final RepairOrderRemoteDataSource _dataSource;

  RepairOrderRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, RepairOrderEntity>> getRepairOrder(String id) =>
      _run(() => _dataSource.getRepairOrder(id));

  @override
  Future<Either<Failure, PaginatedResult<RepairOrderEntity>>> getRepairOrders(
    RepairOrderFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    final result = await _run(
        () => _dataSource.getRepairOrders(filter, startAfter: startAfter));
    return result.map(
      (page) => PaginatedResult<RepairOrderEntity>(
        items: page.items,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
      ),
    );
  }

  @override
  Future<Either<Failure, RepairOrderEntity>> createRepairOrder(
    RepairOrderEntity entity, {
    required UserEntity actor,
  }) =>
      _run(() => _dataSource.createRepairOrder(
          RepairOrderModel.fromEntity(entity),
          actor: actor));

  @override
  Future<Either<Failure, RepairOrderEntity>> updateRepairOrder(
          RepairOrderEntity entity) =>
      _run(() =>
          _dataSource.updateRepairOrder(RepairOrderModel.fromEntity(entity)));

  @override
  Future<Either<Failure, RepairOrderEntity>> receiveDevice(
    String id, {
    required ReceptionInfo reception,
    required UserEntity actor,
  }) =>
      _run(() =>
          _dataSource.receiveDevice(id, reception: reception, actor: actor));

  @override
  Future<Either<Failure, RepairOrderEntity>> updateReceptionInfo(
    String id, {
    required ReceptionInfo reception,
    required UserEntity actor,
  }) =>
      _run(() => _dataSource.updateReceptionInfo(id,
          reception: reception, actor: actor));

  @override
  Future<Either<Failure, RepairOrderEntity>> updateDiagnosis(
    String id, {
    required String diagnosis,
    required UserEntity actor,
  }) =>
      _run(() =>
          _dataSource.updateDiagnosis(id, diagnosis: diagnosis, actor: actor));

  @override
  Future<Either<Failure, RepairOrderEntity>> assignTechnician(
    String id, {
    required String technicianId,
    required String technicianName,
    required UserEntity actor,
  }) =>
      _run(() => _dataSource.assignTechnician(
            id,
            technicianId: technicianId,
            technicianName: technicianName,
            actor: actor,
          ));

  @override
  Future<Either<Failure, RepairOrderEntity>> changeStatus(
    String id, {
    required RepairOrderStatus to,
    required UserEntity actor,
  }) =>
      _run(() => _dataSource.changeStatus(id, to: to, actor: actor));

  @override
  Future<Either<Failure, RepairOrderEntity>> cancelRepairOrder(
    String id, {
    required UserEntity actor,
    String? reason,
  }) =>
      _run(() =>
          _dataSource.cancelRepairOrder(id, actor: actor, reason: reason));

  @override
  Future<Either<Failure, RepairOrderEntity>> startDiagnosis(
    String id, {
    required UserEntity actor,
  }) =>
      _run(() => _dataSource.startDiagnosis(id, actor: actor));

  @override
  Future<Either<Failure, RepairOrderEntity>> completeDiagnosis(
    String id, {
    required String diagnosis,
    required UserEntity actor,
  }) =>
      _run(() => _dataSource.completeDiagnosis(id,
          diagnosis: diagnosis, actor: actor));

  @override
  Future<Either<Failure, RepairOrderEntity>> startRepair(
    String id, {
    required RepairExecutionInfo execution,
    required UserEntity actor,
  }) =>
      _run(() =>
          _dataSource.startRepair(id, execution: execution, actor: actor));

  @override
  Future<Either<Failure, RepairOrderEntity>> updateRepairExecution(
    String id, {
    required RepairExecutionInfo execution,
    required UserEntity actor,
  }) =>
      _run(() => _dataSource.updateRepairExecution(id,
          execution: execution, actor: actor));

  @override
  Future<Either<Failure, RepairOrderEntity>> submitForTesting(
    String id, {
    required UserEntity actor,
  }) =>
      _run(() => _dataSource.submitForTesting(id, actor: actor));

  @override
  Future<Either<Failure, RepairOrderEntity>> passTesting(
    String id, {
    required UserEntity actor,
  }) =>
      _run(() => _dataSource.passTesting(id, actor: actor));

  @override
  Future<Either<Failure, RepairOrderEntity>> failTesting(
    String id, {
    required UserEntity actor,
    String? notes,
  }) =>
      _run(() => _dataSource.failTesting(id, actor: actor, notes: notes));

  @override
  Future<Either<Failure, RepairOrderEntity>> deliverRepairOrder(
    String id, {
    required DeliveryInfo delivery,
    required UserEntity actor,
  }) =>
      _run(() =>
          _dataSource.deliverRepairOrder(id, delivery: delivery, actor: actor));

  Future<Either<Failure, T>> _run<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on DuplicateCodeException catch (e) {
      return Left(DuplicateCodeFailure(e.message));
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
}
