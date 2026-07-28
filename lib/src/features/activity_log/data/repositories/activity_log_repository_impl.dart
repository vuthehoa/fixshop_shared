import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/activity_log_entity.dart';
import '../../domain/repositories/activity_log_repository.dart';
import '../datasources/activity_log_remote_datasource.dart';
import '../models/activity_log_model.dart';

class ActivityLogRepositoryImpl implements ActivityLogRepository {
  final ActivityLogRemoteDataSource _dataSource;

  ActivityLogRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, void>> writeLog(ActivityLogEntity log) async {
    try {
      await _dataSource.writeLog(ActivityLogModel.fromEntity(log));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
