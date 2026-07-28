import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/activity_log_entity.dart';
import '../repositories/activity_log_repository.dart';

class WriteActivityLogUseCase extends UseCase<void, ActivityLogEntity> {
  final ActivityLogRepository _repository;

  WriteActivityLogUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ActivityLogEntity params) {
    return _repository.writeLog(params);
  }
}
