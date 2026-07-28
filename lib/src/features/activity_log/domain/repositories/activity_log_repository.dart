import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/activity_log_entity.dart';

abstract class ActivityLogRepository {
  Future<Either<Failure, void>> writeLog(ActivityLogEntity log);
}
