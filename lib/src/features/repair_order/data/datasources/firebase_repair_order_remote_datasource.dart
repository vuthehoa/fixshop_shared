import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../device/domain/entities/device_entity.dart';
import '../../domain/entities/delivery_info.dart';
import '../../domain/entities/reception_info.dart';
import '../../domain/entities/repair_execution_info.dart';
import '../../domain/entities/repair_order_assignment_entry.dart';
import '../../domain/entities/repair_order_entity.dart';
import '../../domain/entities/repair_order_timeline_entry.dart';
import '../../domain/services/repair_order_status_transition_service.dart';
import '../../domain/value_objects/repair_order_filter.dart';
import '../models/repair_order_model.dart';
import 'repair_order_remote_datasource.dart';

class FirebaseRepairOrderRemoteDataSource
    implements RepairOrderRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseRepairOrderRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.repairOrders);

  CollectionReference<Map<String, dynamic>> get _devicesCollection =>
      _firestore.collection(FirestoreConstants.devices);

  @override
  Future<RepairOrderModel> getRepairOrder(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy đơn sửa chữa: $id');
    }
    return RepairOrderModel.fromFirestore(doc);
  }

  @override
  Future<PaginatedResult<RepairOrderModel>> getRepairOrders(
    RepairOrderFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (filter.status != null) {
      query = query.where('currentStatus', isEqualTo: filter.status!.name);
    }
    if (filter.technicianId != null) {
      query = query.where('technicianId', isEqualTo: filter.technicianId);
    }
    if (filter.manufacturerId != null) {
      query = query.where('manufacturerId', isEqualTo: filter.manufacturerId);
    }
    if (filter.customerId != null) {
      query = query.where('customerId', isEqualTo: filter.customerId);
    }
    if (filter.createdFrom != null) {
      query = query.where('createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(filter.createdFrom!));
    }
    if (filter.createdTo != null) {
      query = query.where('createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(filter.createdTo!));
    }

    query = query.orderBy('createdAt', descending: true).limit(filter.pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final models = snapshot.docs.map((RepairOrderModel.fromFirestore)).toList();

    // Client-side text search — Firestore has no native full-text search.
    final filtered =
        filter.searchQuery == null || filter.searchQuery!.trim().isEmpty
            ? models
            : models.where((o) {
                final q = filter.searchQuery!.trim().toLowerCase();
                return o.repairOrderCode.toLowerCase().contains(q) ||
                    o.customerName.toLowerCase().contains(q) ||
                    o.customerPhone.toLowerCase().contains(q) ||
                    o.deviceName.toLowerCase().contains(q) ||
                    o.deviceCode.toLowerCase().contains(q) ||
                    o.serialNumber.toLowerCase().contains(q) ||
                    (o.imei?.toLowerCase().contains(q) ?? false) ||
                    (o.technicianName?.toLowerCase().contains(q) ?? false) ||
                    o.currentStatus.displayName.toLowerCase().contains(q);
              }).toList();

    return PaginatedResult(
      items: filtered,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == filter.pageSize,
    );
  }

  @override
  Future<RepairOrderModel> createRepairOrder(
    RepairOrderModel entity, {
    required UserEntity actor,
  }) async {
    final deviceDoc = await _devicesCollection.doc(entity.deviceId).get();
    if (!deviceDoc.exists) {
      throw NotFoundException('Không tìm thấy thiết bị: ${entity.deviceId}');
    }
    final deviceData = deviceDoc.data() as Map<String, dynamic>;
    if (DeviceStatus.fromName(deviceData['status'] as String?) ==
        DeviceStatus.archived) {
      throw const OperationNotAllowedException(
        'Không thể tạo đơn sửa chữa cho thiết bị đã lưu trữ.',
      );
    }

    await _ensureNoActiveOrderForDevice(entity.deviceId);
    await _ensureUniqueCode(entity.repairOrderCode);

    final ref = _collection.doc();
    final now = DateTime.now();
    final created = RepairOrderModel(
      id: ref.id,
      repairOrderCode: entity.repairOrderCode,
      customerId: entity.customerId,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      deviceId: entity.deviceId,
      deviceCode: entity.deviceCode,
      deviceName: entity.deviceName,
      serialNumber: entity.serialNumber,
      imei: entity.imei,
      manufacturerId: entity.manufacturerId,
      manufacturerName: entity.manufacturerName,
      createdBy: entity.createdBy,
      currentStatus: RepairOrderStatus.pending,
      problemDescription: entity.problemDescription,
      customerRequest: entity.customerRequest,
      internalNote: entity.internalNote,
      estimatedCost: entity.estimatedCost,
      expectedCompletionDate: entity.expectedCompletionDate,
      attachments: entity.attachments,
      timeline: [
        RepairOrderTimelineEntry(
          type: RepairOrderTimelineEntryType.created,
          message: 'Đơn sửa chữa đã được tạo.',
          actorId: actor.id,
          actorRole: actor.role,
          timestamp: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    await ref.set(created.toFirestore());
    return created;
  }

  @override
  Future<RepairOrderModel> updateRepairOrder(RepairOrderModel entity) async {
    final current = await _fetch(entity.id);
    _ensureNotTerminal(current);
    if (entity.repairOrderCode.trim() != current.repairOrderCode) {
      await _ensureUniqueCode(entity.repairOrderCode, exceptId: entity.id);
    }
    await _collection.doc(entity.id).update(entity.toUpdateMap());
    return _reload(entity.id);
  }

  @override
  Future<RepairOrderModel> receiveDevice(
    String id, {
    required ReceptionInfo reception,
    required UserEntity actor,
  }) async {
    final current = await _fetch(id);
    _ensureTransitionAllowed(current.currentStatus, RepairOrderStatus.received);

    final now = DateTime.now();
    final timeline = [
      ...current.timeline,
      RepairOrderTimelineEntry(
        type: RepairOrderTimelineEntryType.received,
        message: 'Đã tiếp nhận thiết bị.',
        actorId: actor.id,
        actorRole: actor.role,
        timestamp: now,
      ),
    ];

    await _collection.doc(id).update({
      'currentStatus': RepairOrderStatus.received.name,
      'receivedAt': Timestamp.fromDate(now),
      'receivedBy': actor.id,
      'reception': reception.toMap(),
      'timeline': RepairOrderModel.timelineToFirestore(timeline),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _reload(id);
  }

  @override
  Future<RepairOrderModel> updateReceptionInfo(
    String id, {
    required ReceptionInfo reception,
    required UserEntity actor,
  }) async {
    final current = await _fetch(id);
    _ensureNotTerminal(current);
    await _collection.doc(id).update({
      'reception': reception.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _reload(id);
  }

  @override
  Future<RepairOrderModel> updateDiagnosis(
    String id, {
    required String diagnosis,
    required UserEntity actor,
  }) async {
    final current = await _fetch(id);
    _ensureNotTerminal(current);
    final now = DateTime.now();
    final timeline = [
      ...current.timeline,
      RepairOrderTimelineEntry(
        type: RepairOrderTimelineEntryType.diagnosisUpdated,
        message: 'Đã cập nhật chẩn đoán.',
        actorId: actor.id,
        actorRole: actor.role,
        timestamp: now,
      ),
    ];

    await _collection.doc(id).update({
      'diagnosis': diagnosis,
      'timeline': RepairOrderModel.timelineToFirestore(timeline),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _reload(id);
  }

  @override
  Future<RepairOrderModel> assignTechnician(
    String id, {
    required String technicianId,
    required String technicianName,
    required UserEntity actor,
  }) async {
    final current = await _fetch(id);
    if (current.isCancelled || current.isDelivered) {
      throw const OperationNotAllowedException(
        'Không thể phân công kỹ thuật viên cho đơn đã huỷ hoặc đã giao trả.',
      );
    }

    // Only the very first assignment is itself a status transition
    // (received → assigned); reassigning later keeps the current status.
    final isFirstAssignment =
        current.currentStatus == RepairOrderStatus.received;
    if (isFirstAssignment) {
      _ensureTransitionAllowed(
          current.currentStatus, RepairOrderStatus.assigned);
    }

    final now = DateTime.now();
    final history = [
      ...current.assignmentHistory,
      RepairOrderAssignmentEntry(
        technicianId: technicianId,
        technicianName: technicianName,
        assignedBy: actor.id,
        assignedAt: now,
      ),
    ];
    final timeline = [
      ...current.timeline,
      RepairOrderTimelineEntry(
        type: RepairOrderTimelineEntryType.assigned,
        message: 'Đã phân công kỹ thuật viên: $technicianName.',
        actorId: actor.id,
        actorRole: actor.role,
        timestamp: now,
      ),
    ];

    await _collection.doc(id).update({
      'technicianId': technicianId,
      'technicianName': technicianName,
      'assignedBy': actor.id,
      if (isFirstAssignment) 'currentStatus': RepairOrderStatus.assigned.name,
      if (isFirstAssignment) 'assignedAt': Timestamp.fromDate(now),
      'assignmentHistory':
          RepairOrderModel.assignmentHistoryToFirestore(history),
      'timeline': RepairOrderModel.timelineToFirestore(timeline),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _reload(id);
  }

  @override
  Future<RepairOrderModel> changeStatus(
    String id, {
    required RepairOrderStatus to,
    required UserEntity actor,
  }) async {
    final current = await _fetch(id);
    _ensureTransitionAllowed(current.currentStatus, to);

    final now = DateTime.now();
    final timelineType = switch (to) {
      RepairOrderStatus.completed => RepairOrderTimelineEntryType.completed,
      RepairOrderStatus.delivered => RepairOrderTimelineEntryType.delivered,
      _ => RepairOrderTimelineEntryType.statusChanged,
    };
    final timeline = [
      ...current.timeline,
      RepairOrderTimelineEntry(
        type: timelineType,
        message:
            'Trạng thái: ${current.currentStatus.displayName} → ${to.displayName}.',
        actorId: actor.id,
        actorRole: actor.role,
        timestamp: now,
      ),
    ];

    final update = <String, dynamic>{
      'currentStatus': to.name,
      'timeline': RepairOrderModel.timelineToFirestore(timeline),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // First entry into "repairing" marks when the actual repair work began.
    if (to == RepairOrderStatus.repairing && current.startedAt == null) {
      update['startedAt'] = Timestamp.fromDate(now);
    }
    if (to == RepairOrderStatus.completed) {
      update['completedAt'] = Timestamp.fromDate(now);
      update['completedBy'] = actor.id;
    }
    if (to == RepairOrderStatus.delivered) {
      update['deliveredAt'] = Timestamp.fromDate(now);
    }

    await _collection.doc(id).update(update);
    return _reload(id);
  }

  @override
  Future<RepairOrderModel> cancelRepairOrder(
    String id, {
    required UserEntity actor,
    String? reason,
  }) async {
    final current = await _fetch(id);
    _ensureTransitionAllowed(
        current.currentStatus, RepairOrderStatus.cancelled);

    final now = DateTime.now();
    final timeline = [
      ...current.timeline,
      RepairOrderTimelineEntry(
        type: RepairOrderTimelineEntryType.cancelled,
        message: reason == null || reason.trim().isEmpty
            ? 'Đơn sửa chữa đã bị huỷ.'
            : 'Đơn sửa chữa đã bị huỷ: $reason',
        actorId: actor.id,
        actorRole: actor.role,
        timestamp: now,
        metadata: reason == null ? null : {'reason': reason},
      ),
    ];

    await _collection.doc(id).update({
      'currentStatus': RepairOrderStatus.cancelled.name,
      'cancelledAt': Timestamp.fromDate(now),
      'timeline': RepairOrderModel.timelineToFirestore(timeline),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _reload(id);
  }

  // ── Sprint 8 — repair execution & testing loop ──────────────────────────

  @override
  Future<RepairOrderModel> startDiagnosis(String id,
      {required UserEntity actor}) async {
    final current = await _fetch(id);
    _ensureTransitionAllowed(
        current.currentStatus, RepairOrderStatus.diagnosing);

    final now = DateTime.now();
    final timeline = [
      ...current.timeline,
      RepairOrderTimelineEntry(
        type: RepairOrderTimelineEntryType.diagnosisStarted,
        message: 'Đã bắt đầu chẩn đoán.',
        actorId: actor.id,
        actorRole: actor.role,
        timestamp: now,
      ),
    ];

    await _collection.doc(id).update({
      'currentStatus': RepairOrderStatus.diagnosing.name,
      'timeline': RepairOrderModel.timelineToFirestore(timeline),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _reload(id);
  }

  @override
  Future<RepairOrderModel> completeDiagnosis(
    String id, {
    required String diagnosis,
    required UserEntity actor,
  }) async {
    final current = await _fetch(id);
    _ensureTransitionAllowed(
        current.currentStatus, RepairOrderStatus.diagnosed);

    final now = DateTime.now();
    final timeline = [
      ...current.timeline,
      RepairOrderTimelineEntry(
        type: RepairOrderTimelineEntryType.diagnosisCompleted,
        message: 'Đã hoàn tất chẩn đoán.',
        actorId: actor.id,
        actorRole: actor.role,
        timestamp: now,
      ),
    ];

    await _collection.doc(id).update({
      'currentStatus': RepairOrderStatus.diagnosed.name,
      'diagnosis': diagnosis,
      'timeline': RepairOrderModel.timelineToFirestore(timeline),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _reload(id);
  }

  @override
  Future<RepairOrderModel> startRepair(
    String id, {
    required RepairExecutionInfo execution,
    required UserEntity actor,
  }) async {
    final current = await _fetch(id);
    _ensureTransitionAllowed(
        current.currentStatus, RepairOrderStatus.repairing);

    final now = DateTime.now();
    final updatedExecution = execution.copyWith(
      workStartedAt: now,
      lastUpdatedBy: actor.id,
      lastUpdatedAt: now,
    );
    final timeline = [
      ...current.timeline,
      RepairOrderTimelineEntry(
        type: RepairOrderTimelineEntryType.repairStarted,
        message: 'Đã bắt đầu sửa chữa.',
        actorId: actor.id,
        actorRole: actor.role,
        timestamp: now,
      ),
    ];

    await _collection.doc(id).update({
      'currentStatus': RepairOrderStatus.repairing.name,
      // The historical "first ever repair start" — never overwritten,
      // including on a later testing→repairing retry.
      if (current.startedAt == null) 'startedAt': Timestamp.fromDate(now),
      'repairExecution':
          RepairOrderModel.repairExecutionToFirestore(updatedExecution),
      'timeline': RepairOrderModel.timelineToFirestore(timeline),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _reload(id);
  }

  @override
  Future<RepairOrderModel> updateRepairExecution(
    String id, {
    required RepairExecutionInfo execution,
    required UserEntity actor,
  }) async {
    final current = await _fetch(id);
    _ensureNotTerminal(current);
    final now = DateTime.now();
    // Preserve the attempt's start/completion timestamps — this call only
    // edits the technician-authored notes/method fields.
    final updatedExecution =
        (current.repairExecution ?? const RepairExecutionInfo()).copyWith(
      repairNotes: execution.repairNotes,
      repairMethod: execution.repairMethod,
      technicianNotes: execution.technicianNotes,
      lastUpdatedBy: actor.id,
      lastUpdatedAt: now,
    );
    final timeline = [
      ...current.timeline,
      RepairOrderTimelineEntry(
        type: RepairOrderTimelineEntryType.repairUpdated,
        message: 'Đã cập nhật tiến độ sửa chữa.',
        actorId: actor.id,
        actorRole: actor.role,
        timestamp: now,
      ),
    ];

    await _collection.doc(id).update({
      'repairExecution':
          RepairOrderModel.repairExecutionToFirestore(updatedExecution),
      'timeline': RepairOrderModel.timelineToFirestore(timeline),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _reload(id);
  }

  @override
  Future<RepairOrderModel> submitForTesting(String id,
      {required UserEntity actor}) async {
    final current = await _fetch(id);
    _ensureTransitionAllowed(current.currentStatus, RepairOrderStatus.testing);

    final now = DateTime.now();
    final updatedExecution =
        (current.repairExecution ?? const RepairExecutionInfo()).copyWith(
      workCompletedAt: now,
      lastUpdatedBy: actor.id,
      lastUpdatedAt: now,
    );
    final timeline = [
      ...current.timeline,
      RepairOrderTimelineEntry(
        type: RepairOrderTimelineEntryType.sentToTesting,
        message: 'Đã gửi thiết bị đi kiểm tra.',
        actorId: actor.id,
        actorRole: actor.role,
        timestamp: now,
      ),
    ];

    await _collection.doc(id).update({
      'currentStatus': RepairOrderStatus.testing.name,
      'repairExecution':
          RepairOrderModel.repairExecutionToFirestore(updatedExecution),
      'timeline': RepairOrderModel.timelineToFirestore(timeline),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _reload(id);
  }

  @override
  Future<RepairOrderModel> passTesting(String id,
      {required UserEntity actor}) async {
    final current = await _fetch(id);
    _ensureTransitionAllowed(
        current.currentStatus, RepairOrderStatus.completed);

    final now = DateTime.now();
    final timeline = [
      ...current.timeline,
      RepairOrderTimelineEntry(
        type: RepairOrderTimelineEntryType.testingPassed,
        message: 'Kiểm tra đạt yêu cầu — đơn sửa chữa đã hoàn thành.',
        actorId: actor.id,
        actorRole: actor.role,
        timestamp: now,
      ),
    ];

    await _collection.doc(id).update({
      'currentStatus': RepairOrderStatus.completed.name,
      'completedAt': Timestamp.fromDate(now),
      'completedBy': actor.id,
      'timeline': RepairOrderModel.timelineToFirestore(timeline),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _reload(id);
  }

  @override
  Future<RepairOrderModel> failTesting(
    String id, {
    required UserEntity actor,
    String? notes,
  }) async {
    final current = await _fetch(id);
    _ensureTransitionAllowed(
        current.currentStatus, RepairOrderStatus.repairing);

    final now = DateTime.now();
    // Work resumes — clear the previous attempt's completion stamp, but
    // never touch `startedAt` (the historical first-start record) or
    // technician notes already on file.
    final updatedExecution =
        (current.repairExecution ?? const RepairExecutionInfo()).copyWith(
      clearWorkCompletedAt: true,
      lastUpdatedBy: actor.id,
      lastUpdatedAt: now,
    );
    final timeline = [
      ...current.timeline,
      RepairOrderTimelineEntry(
        type: RepairOrderTimelineEntryType.testingFailed,
        message: notes == null || notes.trim().isEmpty
            ? 'Kiểm tra không đạt — quay lại sửa chữa.'
            : 'Kiểm tra không đạt — quay lại sửa chữa: $notes',
        actorId: actor.id,
        actorRole: actor.role,
        timestamp: now,
        metadata: notes == null ? null : {'notes': notes},
      ),
    ];

    await _collection.doc(id).update({
      'currentStatus': RepairOrderStatus.repairing.name,
      'repairExecution':
          RepairOrderModel.repairExecutionToFirestore(updatedExecution),
      'timeline': RepairOrderModel.timelineToFirestore(timeline),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _reload(id);
  }

  @override
  Future<RepairOrderModel> deliverRepairOrder(
    String id, {
    required DeliveryInfo delivery,
    required UserEntity actor,
  }) async {
    final current = await _fetch(id);
    _ensureTransitionAllowed(
        current.currentStatus, RepairOrderStatus.delivered);

    if (delivery.recipientName.trim().isEmpty) {
      throw const OperationNotAllowedException(
        'Vui lòng cho biết người nhận thiết bị trước khi giao trả.',
      );
    }

    final now = DateTime.now();
    final timeline = [
      ...current.timeline,
      RepairOrderTimelineEntry(
        type: RepairOrderTimelineEntryType.delivered,
        message:
            'Đã giao trả thiết bị cho ${delivery.recipientName} (${delivery.recipientRelationship.displayName}).',
        actorId: actor.id,
        actorRole: actor.role,
        timestamp: now,
        metadata: {
          'recipientName': delivery.recipientName,
          'recipientRelationship': delivery.recipientRelationship.name,
          if (delivery.handoverNotes != null)
            'handoverNotes': delivery.handoverNotes,
        },
      ),
    ];

    await _collection.doc(id).update({
      'currentStatus': RepairOrderStatus.delivered.name,
      'deliveredAt': Timestamp.fromDate(now),
      'deliveredBy': actor.id,
      'deliveryInfo': delivery.toMap(),
      'timeline': RepairOrderModel.timelineToFirestore(timeline),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _reload(id);
  }

  Future<RepairOrderModel> _fetch(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy đơn sửa chữa: $id');
    }
    return RepairOrderModel.fromFirestore(doc);
  }

  Future<RepairOrderModel> _reload(String id) => _fetch(id);

  void _ensureTransitionAllowed(RepairOrderStatus from, RepairOrderStatus to) {
    if (!RepairOrderStatusTransitionService.canTransition(from, to)) {
      throw OperationNotAllowedException(
        'Không thể chuyển trạng thái từ "${from.displayName}" sang "${to.displayName}".',
      );
    }
  }

  /// DELIVERED and CANCELLED are terminal — every mutation path that isn't
  /// itself a status transition must still refuse to write once an order has
  /// reached one of them. UI button visibility (`item.isActive`) is not
  /// sufficient on its own; this is the business-layer half of that guard.
  void _ensureNotTerminal(RepairOrderModel current) {
    if (current.isDelivered || current.isCancelled) {
      throw const OperationNotAllowedException(
        'Đơn sửa chữa đã ở trạng thái cuối (đã giao trả hoặc đã huỷ) và không thể chỉnh sửa.',
      );
    }
  }

  /// "One active repair order per device" — active meaning neither
  /// delivered nor cancelled. Not transactional — a narrow race window is
  /// accepted (see sprint notes for the equivalent uniqueness checks).
  Future<void> _ensureNoActiveOrderForDevice(String deviceId) async {
    final snapshot =
        await _collection.where('deviceId', isEqualTo: deviceId).get();
    final hasActive = snapshot.docs.any((doc) {
      final status =
          RepairOrderStatus.fromName(doc.data()['currentStatus'] as String?);
      return status != RepairOrderStatus.delivered &&
          status != RepairOrderStatus.cancelled;
    });
    if (hasActive) {
      throw const OperationNotAllowedException(
        'Thiết bị này đã có một đơn sửa chữa đang xử lý.',
      );
    }
  }

  /// [exceptId] excludes the order being updated from its own uniqueness
  /// check, so re-saving an unchanged code never self-rejects.
  Future<void> _ensureUniqueCode(String code, {String? exceptId}) async {
    final snapshot = await _collection
        .where('repairOrderCode', isEqualTo: code.trim())
        .get();
    final hasConflict = snapshot.docs.any((doc) => doc.id != exceptId);
    if (hasConflict) {
      throw DuplicateCodeException('Mã đơn sửa chữa "$code" đã tồn tại.');
    }
  }
}
