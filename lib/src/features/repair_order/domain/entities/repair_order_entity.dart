import 'package:equatable/equatable.dart';

import 'delivery_info.dart';
import 'reception_info.dart';
import 'repair_booking_snapshot.dart';
import 'repair_order_assignment_entry.dart';
import 'repair_order_timeline_entry.dart';
import 'repair_execution_info.dart';

/// The repair workflow stage. Forward order matches the diagram exactly;
/// [cancelled] is reachable from every non-terminal stage. Never mutate a
/// [RepairOrderEntity.currentStatus] directly — always go through
/// `RepairOrderStatusTransitionService` so a transition can never be skipped
/// or hardcoded ad-hoc in a widget.
///
/// Sprint 8 splits the former single `diagnosis` stage into [diagnosing]
/// (in progress) / [diagnosed] (result recorded) — nothing was deployed yet,
/// so this is a rename, not a migration. Sprint 8 also adds the
/// [testing] → [repairing] failed-test loop.
enum RepairOrderStatus {
  pending,
  confirmed,
  received,
  assigned,
  diagnosing,
  diagnosed,
  waitingParts,
  repairing,
  testing,
  completed,
  delivered,
  cancelled;

  String get displayName => switch (this) {
        RepairOrderStatus.pending => 'Chờ xác nhận',
        RepairOrderStatus.confirmed => 'Đã xác nhận',
        RepairOrderStatus.received => 'Đã tiếp nhận',
        RepairOrderStatus.assigned => 'Đã phân công',
        RepairOrderStatus.diagnosing => 'Đang chẩn đoán',
        RepairOrderStatus.diagnosed => 'Đã chẩn đoán',
        RepairOrderStatus.waitingParts => 'Chờ linh kiện',
        RepairOrderStatus.repairing => 'Đang sửa chữa',
        RepairOrderStatus.testing => 'Đang kiểm tra',
        RepairOrderStatus.completed => 'Đã hoàn thành',
        RepairOrderStatus.delivered => 'Đã giao trả',
        RepairOrderStatus.cancelled => 'Đã huỷ',
      };

  static RepairOrderStatus fromName(String? value) => switch (value) {
        'pending' => RepairOrderStatus.pending,
        'confirmed' => RepairOrderStatus.confirmed,
        'received' => RepairOrderStatus.received,
        'assigned' => RepairOrderStatus.assigned,
        'diagnosing' => RepairOrderStatus.diagnosing,
        'diagnosed' => RepairOrderStatus.diagnosed,
        'waitingParts' => RepairOrderStatus.waitingParts,
        'repairing' => RepairOrderStatus.repairing,
        'testing' => RepairOrderStatus.testing,
        'completed' => RepairOrderStatus.completed,
        'delivered' => RepairOrderStatus.delivered,
        'cancelled' => RepairOrderStatus.cancelled,
        _ => RepairOrderStatus.pending,
      };
}

/// The central business workflow of FixShop — every future technician work,
/// repair history, PDF document, notification and customer-tracking feature
/// is anchored to a RepairOrder.
///
/// [customerName], [customerPhone], [deviceCode], [deviceName],
/// [serialNumber], [imei], [manufacturerId], [manufacturerName] and
/// [technicianName] are denormalized display fields, copied at
/// create/assign time — same convention as [DeviceEntity]'s denormalized
/// relation names. Warranty information is deliberately NOT duplicated here:
/// the detail page reads it straight from the referenced Device.
class RepairOrderEntity extends Equatable {
  final String id;
  final String repairOrderCode;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String deviceId;
  final String deviceCode;
  final String deviceName;
  final String serialNumber;
  final String? imei;
  final String manufacturerId;
  final String manufacturerName;
  final String? technicianId;
  final String? technicianName;
  final String createdBy;
  final String? receivedBy;
  final String? assignedBy;
  final String? completedBy;
  final String? deliveredBy;
  final RepairOrderStatus currentStatus;
  final String problemDescription;
  final String? customerRequest;
  final String? internalNote;
  final String? diagnosis;
  final double? estimatedCost;
  final double? actualCost;
  final DateTime? expectedCompletionDate;
  final DateTime? receivedAt;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final List<String> attachments;
  final ReceptionInfo? reception;
  final RepairExecutionInfo? repairExecution;
  final DeliveryInfo? deliveryInfo;
  final List<RepairOrderAssignmentEntry> assignmentHistory;
  final List<RepairOrderTimelineEntry> timeline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // ── Customer-app booking (Mobile M4) ────────────────────────────────
  // All nullable/additive — legacy documents and CMS/walk-in orders never
  // populate these, and must keep parsing exactly as before. See
  // `fixshop_mobile_app`'s `FirestoreRepairBookingSubmissionRepository`
  // for the exact writer this mirrors.
  final String? bookingRequestId;
  final RepairOrderSource? source;
  final BookingContactSnapshot? contact;
  final BookingDeviceSnapshot? deviceSnapshot;
  final BookingServiceSnapshot? serviceSnapshot;
  final BookingAppointmentSnapshot? appointment;
  final RepairFulfillmentMethod? fulfillmentMethod;
  final String? pickupAddress;
  final String? storeAddress;

  /// True for a booking created by an unauthenticated guest — `source` is
  /// the customer app AND no customer profile is attached. Not an error
  /// state; the CMS surfaces it as a light "Khách chưa đăng nhập" label.
  bool get isGuestBooking =>
      source == RepairOrderSource.customerApp && customerId.isEmpty;

  const RepairOrderEntity({
    required this.id,
    required this.repairOrderCode,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.deviceId,
    required this.deviceCode,
    required this.deviceName,
    required this.serialNumber,
    this.imei,
    required this.manufacturerId,
    required this.manufacturerName,
    this.technicianId,
    this.technicianName,
    required this.createdBy,
    this.receivedBy,
    this.assignedBy,
    this.completedBy,
    this.deliveredBy,
    this.currentStatus = RepairOrderStatus.pending,
    required this.problemDescription,
    this.customerRequest,
    this.internalNote,
    this.diagnosis,
    this.estimatedCost,
    this.actualCost,
    this.expectedCompletionDate,
    this.receivedAt,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.attachments = const [],
    this.reception,
    this.repairExecution,
    this.deliveryInfo,
    this.assignmentHistory = const [],
    this.timeline = const [],
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.bookingRequestId,
    this.source,
    this.contact,
    this.deviceSnapshot,
    this.serviceSnapshot,
    this.appointment,
    this.fulfillmentMethod,
    this.pickupAddress,
    this.storeAddress,
  });

  bool get isCancelled => currentStatus == RepairOrderStatus.cancelled;
  bool get isDelivered => currentStatus == RepairOrderStatus.delivered;

  /// "Active" here means still in the workflow — neither delivered back to
  /// the customer nor cancelled. Used by the "one active order per device"
  /// business rule.
  bool get isActive => !isDelivered && !isCancelled;

  RepairOrderEntity copyWith({
    String? id,
    String? repairOrderCode,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? deviceId,
    String? deviceCode,
    String? deviceName,
    String? serialNumber,
    String? imei,
    String? manufacturerId,
    String? manufacturerName,
    String? technicianId,
    String? technicianName,
    String? createdBy,
    String? receivedBy,
    String? assignedBy,
    String? completedBy,
    String? deliveredBy,
    RepairOrderStatus? currentStatus,
    String? problemDescription,
    String? customerRequest,
    String? internalNote,
    String? diagnosis,
    double? estimatedCost,
    double? actualCost,
    DateTime? expectedCompletionDate,
    DateTime? receivedAt,
    DateTime? assignedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    List<String>? attachments,
    ReceptionInfo? reception,
    RepairExecutionInfo? repairExecution,
    DeliveryInfo? deliveryInfo,
    List<RepairOrderAssignmentEntry>? assignmentHistory,
    List<RepairOrderTimelineEntry>? timeline,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? bookingRequestId,
    RepairOrderSource? source,
    BookingContactSnapshot? contact,
    BookingDeviceSnapshot? deviceSnapshot,
    BookingServiceSnapshot? serviceSnapshot,
    BookingAppointmentSnapshot? appointment,
    RepairFulfillmentMethod? fulfillmentMethod,
    String? pickupAddress,
    String? storeAddress,
  }) {
    return RepairOrderEntity(
      id: id ?? this.id,
      repairOrderCode: repairOrderCode ?? this.repairOrderCode,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deviceId: deviceId ?? this.deviceId,
      deviceCode: deviceCode ?? this.deviceCode,
      deviceName: deviceName ?? this.deviceName,
      serialNumber: serialNumber ?? this.serialNumber,
      imei: imei ?? this.imei,
      manufacturerId: manufacturerId ?? this.manufacturerId,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      createdBy: createdBy ?? this.createdBy,
      receivedBy: receivedBy ?? this.receivedBy,
      assignedBy: assignedBy ?? this.assignedBy,
      completedBy: completedBy ?? this.completedBy,
      deliveredBy: deliveredBy ?? this.deliveredBy,
      currentStatus: currentStatus ?? this.currentStatus,
      problemDescription: problemDescription ?? this.problemDescription,
      customerRequest: customerRequest ?? this.customerRequest,
      internalNote: internalNote ?? this.internalNote,
      diagnosis: diagnosis ?? this.diagnosis,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      expectedCompletionDate:
          expectedCompletionDate ?? this.expectedCompletionDate,
      receivedAt: receivedAt ?? this.receivedAt,
      assignedAt: assignedAt ?? this.assignedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      attachments: attachments ?? this.attachments,
      reception: reception ?? this.reception,
      repairExecution: repairExecution ?? this.repairExecution,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
      assignmentHistory: assignmentHistory ?? this.assignmentHistory,
      timeline: timeline ?? this.timeline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      bookingRequestId: bookingRequestId ?? this.bookingRequestId,
      source: source ?? this.source,
      contact: contact ?? this.contact,
      deviceSnapshot: deviceSnapshot ?? this.deviceSnapshot,
      serviceSnapshot: serviceSnapshot ?? this.serviceSnapshot,
      appointment: appointment ?? this.appointment,
      fulfillmentMethod: fulfillmentMethod ?? this.fulfillmentMethod,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      storeAddress: storeAddress ?? this.storeAddress,
    );
  }

  @override
  List<Object?> get props => [
        id,
        repairOrderCode,
        customerId,
        customerName,
        customerPhone,
        deviceId,
        deviceCode,
        deviceName,
        serialNumber,
        imei,
        manufacturerId,
        manufacturerName,
        technicianId,
        technicianName,
        createdBy,
        receivedBy,
        assignedBy,
        completedBy,
        deliveredBy,
        currentStatus,
        problemDescription,
        customerRequest,
        internalNote,
        diagnosis,
        estimatedCost,
        actualCost,
        expectedCompletionDate,
        receivedAt,
        assignedAt,
        startedAt,
        completedAt,
        deliveredAt,
        cancelledAt,
        attachments,
        reception,
        repairExecution,
        deliveryInfo,
        assignmentHistory,
        timeline,
        createdAt,
        updatedAt,
        deletedAt,
        bookingRequestId,
        source,
        contact,
        deviceSnapshot,
        serviceSnapshot,
        appointment,
        fulfillmentMethod,
        pickupAddress,
        storeAddress,
      ];
}
