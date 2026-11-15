import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/delivery_info.dart';
import '../../domain/entities/reception_info.dart';
import '../../domain/entities/repair_booking_snapshot.dart';
import '../../domain/entities/repair_execution_info.dart';
import '../../domain/entities/repair_order_assignment_entry.dart';
import '../../domain/entities/repair_order_entity.dart';
import '../../domain/entities/repair_order_timeline_entry.dart';

class RepairOrderModel extends RepairOrderEntity {
  const RepairOrderModel({
    required super.id,
    required super.repairOrderCode,
    required super.customerId,
    required super.customerName,
    required super.customerPhone,
    required super.deviceId,
    required super.deviceCode,
    required super.deviceName,
    required super.serialNumber,
    super.imei,
    required super.manufacturerId,
    required super.manufacturerName,
    super.technicianId,
    super.technicianName,
    required super.createdBy,
    super.receivedBy,
    super.assignedBy,
    super.completedBy,
    super.deliveredBy,
    super.currentStatus,
    required super.problemDescription,
    super.customerRequest,
    super.internalNote,
    super.diagnosis,
    super.estimatedCost,
    super.actualCost,
    super.expectedCompletionDate,
    super.receivedAt,
    super.assignedAt,
    super.startedAt,
    super.completedAt,
    super.deliveredAt,
    super.cancelledAt,
    super.attachments,
    super.reception,
    super.repairExecution,
    super.deliveryInfo,
    super.assignmentHistory,
    super.timeline,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    super.bookingRequestId,
    super.source,
    super.contact,
    super.deviceSnapshot,
    super.serviceSnapshot,
    super.appointment,
    super.fulfillmentMethod,
    super.pickupAddress,
    super.storeAddress,
    super.serviceItems,
    super.receiptKey,
  });

  static DateTime? _date(dynamic value) => (value as Timestamp?)?.toDate();

  static RepairExecutionInfo? _repairExecutionFromFirestore(dynamic raw) {
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(raw as Map);
    return RepairExecutionInfo.fromMap({
      ...map,
      'workStartedAt': _date(map['workStartedAt']),
      'workCompletedAt': _date(map['workCompletedAt']),
      'lastUpdatedAt': _date(map['lastUpdatedAt']),
    });
  }

  factory RepairOrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RepairOrderModel(
      id: doc.id,
      repairOrderCode: data['repairOrderCode'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      deviceId: data['deviceId'] as String? ?? '',
      deviceCode: data['deviceCode'] as String? ?? '',
      deviceName: data['deviceName'] as String? ?? '',
      serialNumber: data['serialNumber'] as String? ?? '',
      imei: data['imei'] as String?,
      manufacturerId: data['manufacturerId'] as String? ?? '',
      manufacturerName: data['manufacturerName'] as String? ?? '',
      technicianId: data['technicianId'] as String?,
      technicianName: data['technicianName'] as String?,
      createdBy: data['createdBy'] as String? ?? '',
      receivedBy: data['receivedBy'] as String?,
      assignedBy: data['assignedBy'] as String?,
      completedBy: data['completedBy'] as String?,
      deliveredBy: data['deliveredBy'] as String?,
      currentStatus:
          RepairOrderStatus.fromName(data['currentStatus'] as String?),
      problemDescription: data['problemDescription'] as String? ?? '',
      customerRequest: data['customerRequest'] as String?,
      internalNote: data['internalNote'] as String?,
      diagnosis: data['diagnosis'] as String?,
      estimatedCost: (data['estimatedCost'] as num?)?.toDouble(),
      actualCost: (data['actualCost'] as num?)?.toDouble(),
      expectedCompletionDate: _date(data['expectedCompletionDate']),
      receivedAt: _date(data['receivedAt']),
      assignedAt: _date(data['assignedAt']),
      startedAt: _date(data['startedAt']),
      completedAt: _date(data['completedAt']),
      deliveredAt: _date(data['deliveredAt']),
      cancelledAt: _date(data['cancelledAt']),
      attachments:
          (data['attachments'] as List<dynamic>?)?.cast<String>() ?? const [],
      reception: data['reception'] == null
          ? null
          : ReceptionInfo.fromMap(
              (data['reception'] as Map).cast<String, dynamic>()),
      repairExecution: _repairExecutionFromFirestore(data['repairExecution']),
      deliveryInfo: data['deliveryInfo'] == null
          ? null
          : DeliveryInfo.fromMap(
              (data['deliveryInfo'] as Map).cast<String, dynamic>()),
      assignmentHistory:
          (data['assignmentHistory'] as List<dynamic>? ?? []).map((raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        return RepairOrderAssignmentEntry.fromMap({
          ...map,
          'assignedAt': _date(map['assignedAt']),
        });
      }).toList(),
      timeline: (data['timeline'] as List<dynamic>? ?? []).map((raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        return RepairOrderTimelineEntry.fromMap({
          ...map,
          'timestamp': _date(map['timestamp']),
        });
      }).toList(),
      createdAt: _date(data['createdAt']) ?? DateTime.now(),
      updatedAt: _date(data['updatedAt']) ?? DateTime.now(),
      deletedAt: _date(data['deletedAt']),
      bookingRequestId: data['bookingRequestId'] as String?,
      source: RepairOrderSource.fromName(data['source'] as String?),
      contact: data['contact'] == null
          ? null
          : BookingContactSnapshot.fromMap(
              (data['contact'] as Map).cast<String, dynamic>()),
      deviceSnapshot: data['deviceSnapshot'] == null
          ? null
          : BookingDeviceSnapshot.fromMap(
              (data['deviceSnapshot'] as Map).cast<String, dynamic>()),
      serviceSnapshot: data['serviceSnapshot'] == null
          ? null
          : BookingServiceSnapshot.fromMap(
              (data['serviceSnapshot'] as Map).cast<String, dynamic>()),
      appointment: data['appointment'] == null
          ? null
          : BookingAppointmentSnapshot.fromMap(
              (data['appointment'] as Map).cast<String, dynamic>()),
      fulfillmentMethod: RepairFulfillmentMethod.fromName(
          data['fulfillmentMethod'] as String?),
      pickupAddress: data['pickupAddress'] as String?,
      storeAddress: data['storeAddress'] as String?,
      serviceItems: BookingServiceItem.listFromFirestore(data['serviceItems']),
      receiptKey:
          data['receiptKey'] is String ? data['receiptKey'] as String : null,
    );
  }

  factory RepairOrderModel.fromEntity(RepairOrderEntity entity) {
    return RepairOrderModel(
      id: entity.id,
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
      technicianId: entity.technicianId,
      technicianName: entity.technicianName,
      createdBy: entity.createdBy,
      receivedBy: entity.receivedBy,
      assignedBy: entity.assignedBy,
      completedBy: entity.completedBy,
      deliveredBy: entity.deliveredBy,
      currentStatus: entity.currentStatus,
      problemDescription: entity.problemDescription,
      customerRequest: entity.customerRequest,
      internalNote: entity.internalNote,
      diagnosis: entity.diagnosis,
      estimatedCost: entity.estimatedCost,
      actualCost: entity.actualCost,
      expectedCompletionDate: entity.expectedCompletionDate,
      receivedAt: entity.receivedAt,
      assignedAt: entity.assignedAt,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      deliveredAt: entity.deliveredAt,
      cancelledAt: entity.cancelledAt,
      attachments: entity.attachments,
      reception: entity.reception,
      repairExecution: entity.repairExecution,
      deliveryInfo: entity.deliveryInfo,
      assignmentHistory: entity.assignmentHistory,
      timeline: entity.timeline,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      bookingRequestId: entity.bookingRequestId,
      source: entity.source,
      contact: entity.contact,
      deviceSnapshot: entity.deviceSnapshot,
      serviceSnapshot: entity.serviceSnapshot,
      appointment: entity.appointment,
      fulfillmentMethod: entity.fulfillmentMethod,
      pickupAddress: entity.pickupAddress,
      storeAddress: entity.storeAddress,
      serviceItems: entity.serviceItems,
      receiptKey: entity.receiptKey,
    );
  }

  static Timestamp? _ts(DateTime? value) =>
      value == null ? null : Timestamp.fromDate(value);

  /// Public so the datasource can reuse it for partial updates (e.g.
  /// appending one timeline entry) without re-fetching/rebuilding the whole
  /// document via [toFirestore].
  static List<Map<String, dynamic>> assignmentHistoryToFirestore(
    List<RepairOrderAssignmentEntry> history,
  ) =>
      history
          .map((e) =>
              {...e.toMap(), 'assignedAt': Timestamp.fromDate(e.assignedAt)})
          .toList();

  static List<Map<String, dynamic>> timelineToFirestore(
    List<RepairOrderTimelineEntry> timeline,
  ) =>
      timeline
          .map((e) =>
              {...e.toMap(), 'timestamp': Timestamp.fromDate(e.timestamp)})
          .toList();

  static Map<String, dynamic>? repairExecutionToFirestore(
      RepairExecutionInfo? execution) {
    if (execution == null) return null;
    return {
      ...execution.toMap(),
      'workStartedAt': _ts(execution.workStartedAt),
      'workCompletedAt': _ts(execution.workCompletedAt),
      'lastUpdatedAt': _ts(execution.lastUpdatedAt),
    };
  }

  List<Map<String, dynamic>> _assignmentHistoryList() =>
      assignmentHistoryToFirestore(assignmentHistory);

  List<Map<String, dynamic>> _timelineList() => timelineToFirestore(timeline);

  Map<String, dynamic> toFirestore() {
    return {
      'repairOrderCode': repairOrderCode,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deviceId': deviceId,
      'deviceCode': deviceCode,
      'deviceName': deviceName,
      'serialNumber': serialNumber,
      'imei': imei,
      'manufacturerId': manufacturerId,
      'manufacturerName': manufacturerName,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'createdBy': createdBy,
      'receivedBy': receivedBy,
      'assignedBy': assignedBy,
      'completedBy': completedBy,
      'deliveredBy': deliveredBy,
      'currentStatus': currentStatus.name,
      'problemDescription': problemDescription,
      'customerRequest': customerRequest,
      'internalNote': internalNote,
      'diagnosis': diagnosis,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'expectedCompletionDate': _ts(expectedCompletionDate),
      'receivedAt': _ts(receivedAt),
      'assignedAt': _ts(assignedAt),
      'startedAt': _ts(startedAt),
      'completedAt': _ts(completedAt),
      'deliveredAt': _ts(deliveredAt),
      'cancelledAt': _ts(cancelledAt),
      'attachments': attachments,
      'reception': reception?.toMap(),
      'repairExecution': repairExecutionToFirestore(repairExecution),
      'deliveryInfo': deliveryInfo?.toMap(),
      'assignmentHistory': _assignmentHistoryList(),
      'timeline': _timelineList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': _ts(deletedAt),
      if (bookingRequestId != null) 'bookingRequestId': bookingRequestId,
      if (source != null) 'source': source!.wireName,
      if (contact != null) 'contact': contact!.toMap(),
      if (deviceSnapshot != null) 'deviceSnapshot': deviceSnapshot!.toMap(),
      if (serviceSnapshot != null) 'serviceSnapshot': serviceSnapshot!.toMap(),
      if (appointment != null) 'appointment': appointment!.toMap(),
      if (fulfillmentMethod != null)
        'fulfillmentMethod': fulfillmentMethod!.wireName,
      if (pickupAddress != null) 'pickupAddress': pickupAddress,
      if (storeAddress != null) 'storeAddress': storeAddress,
      // Preserved verbatim when the order has them; never synthesised for a
      // legacy order (old readers rely on their absence).
      if (serviceItems != null)
        'serviceItems': serviceItems!.map((i) => i.toMap()).toList(),
      if (receiptKey != null) 'receiptKey': receiptKey,
    };
  }

  /// Update payload for generic field edits only — never touches
  /// `currentStatus`, `technicianId`, `reception`, `assignmentHistory`,
  /// `timeline` or any lifecycle timestamp. Those go through their own
  /// dedicated repository methods. `repairOrderCode` IS included here (the
  /// datasource re-checks uniqueness, excluding this order's own id, before
  /// writing) since the form dialog exposes it as an editable field in both
  /// create and edit mode.
  Map<String, dynamic> toUpdateMap() {
    return {
      'repairOrderCode': repairOrderCode,
      'problemDescription': problemDescription,
      'customerRequest': customerRequest,
      'internalNote': internalNote,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'expectedCompletionDate': _ts(expectedCompletionDate),
      'attachments': attachments,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
