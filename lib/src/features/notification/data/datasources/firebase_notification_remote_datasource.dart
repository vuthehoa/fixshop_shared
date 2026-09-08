import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/value_objects/notification_filter.dart';
import '../models/notification_model.dart';
import 'notification_remote_datasource.dart';

class FirebaseNotificationRemoteDataSource
    implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseNotificationRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.notifications);

  @override
  Future<NotificationModel> createNotification(NotificationModel entity) async {
    final ref = _collection.doc();
    final created = NotificationModel(
      id: ref.id,
      type: entity.type,
      title: entity.title,
      body: entity.body,
      customerId: entity.customerId,
      customerName: entity.customerName,
      targetType: entity.targetType,
      targetId: entity.targetId,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
    );
    await ref.set(created.toFirestore());
    return created;
  }

  @override
  Future<PaginatedResult<NotificationModel>> getNotifications(
    NotificationFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (filter.type != null) {
      query = query.where('type', whereIn: filter.type!.readAliases);
    }
    if (filter.customerId != null) {
      query = query.where('customerId', isEqualTo: filter.customerId);
    }
    if (filter.unreadOnly == true) {
      query = query.where('readAt', isNull: true);
    }

    query = query.orderBy('createdAt', descending: true).limit(filter.pageSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final items = snapshot.docs.map(NotificationModel.fromFirestore).toList();

    return PaginatedResult(
      items: items,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == filter.pageSize,
    );
  }

  @override
  Future<NotificationModel> markAsRead(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy thông báo: $id');
    }
    await _collection
        .doc(id)
        .update({'readAt': Timestamp.fromDate(DateTime.now())});
    final updated = await _collection.doc(id).get();
    return NotificationModel.fromFirestore(updated);
  }

  @override
  Future<bool> hasRecentNotification({
    required String targetId,
    required NotificationType type,
    required DateTime since,
  }) async {
    final snapshot = await _collection
        .where('targetId', isEqualTo: targetId)
        .where('type', whereIn: type.readAliases)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
