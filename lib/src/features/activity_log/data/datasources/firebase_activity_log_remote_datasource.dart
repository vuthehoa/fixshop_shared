import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/activity_log_model.dart';
import 'activity_log_remote_datasource.dart';

class FirebaseActivityLogRemoteDataSource
    implements ActivityLogRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseActivityLogRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<void> writeLog(ActivityLogModel log) async {
    try {
      await _firestore
          .collection(FirestoreConstants.activityLogs)
          .add(log.toFirestore());
    } catch (e) {
      throw ServerException('Failed to write activity log: $e');
    }
  }
}
