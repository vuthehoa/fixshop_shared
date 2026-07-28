import '../models/activity_log_model.dart';

abstract class ActivityLogRemoteDataSource {
  Future<void> writeLog(ActivityLogModel log);
}
