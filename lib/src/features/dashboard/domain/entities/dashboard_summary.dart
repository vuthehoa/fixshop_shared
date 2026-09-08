import 'package:equatable/equatable.dart';

import '../../../repair_order/domain/entities/repair_order_entity.dart';

/// Per-technician operational workload, derived entirely from the
/// denormalized `technicianId`/`technicianName` already stored on
/// [RepairOrderEntity] — no separate read of the Employee collection is
/// needed, and nothing about the technician is duplicated here beyond what
/// the repair order already carries.
class TechnicianWorkload extends Equatable {
  final String technicianId;
  final String technicianName;

  /// Orders currently assigned to this technician that are neither
  /// delivered nor cancelled.
  final int activeCount;
  final int repairingCount;
  final int testingCount;

  /// Completed but not yet delivered — still "on" this technician's record
  /// until handover.
  final int completedNotDeliveredCount;

  const TechnicianWorkload({
    required this.technicianId,
    required this.technicianName,
    required this.activeCount,
    required this.repairingCount,
    required this.testingCount,
    required this.completedNotDeliveredCount,
  });

  @override
  List<Object?> get props => [
        technicianId,
        technicianName,
        activeCount,
        repairingCount,
        testingCount,
        completedNotDeliveredCount,
      ];
}

/// Read-model aggregate for the operational dashboard. Nothing here is a new
/// source of truth — every value is derived at request time from the
/// existing `repair_orders`, `customers` and `devices` collections. Never
/// persisted; recomputed on every dashboard load.
class DashboardSummary extends Equatable {
  final int totalRepairOrders;

  /// All 12 [RepairOrderStatus] values as keys, including `delivered` and
  /// `cancelled` — the single map the status-distribution chart renders
  /// from, so the UI never hardcodes a partial status list.
  final Map<RepairOrderStatus, int> statusCounts;

  final List<TechnicianWorkload> technicianWorkload;

  final int totalActiveCustomers;
  final int totalActiveDevices;

  /// Warranty is owned by DeviceEntity and derived (never stored) via
  /// [WarrantyStatus] — these counts are computed by reading Device records,
  /// never by denormalizing warranty fields anywhere in this aggregate.
  final int devicesWarrantyActive;
  final int devicesWarrantyExpired;
  final int devicesWarrantyVoided;
  final int devicesWarrantyNotActivated;

  /// Repair orders created within [rangeFrom]..[rangeTo], or `null` when no
  /// date range was requested (the range itself is optional — see
  /// `GetDashboardSummaryUseCase`).
  final int? newRepairOrdersInRange;
  final DateTime? rangeFrom;
  final DateTime? rangeTo;

  const DashboardSummary({
    required this.totalRepairOrders,
    required this.statusCounts,
    required this.technicianWorkload,
    required this.totalActiveCustomers,
    required this.totalActiveDevices,
    required this.devicesWarrantyActive,
    required this.devicesWarrantyExpired,
    required this.devicesWarrantyVoided,
    required this.devicesWarrantyNotActivated,
    this.newRepairOrdersInRange,
    this.rangeFrom,
    this.rangeTo,
  });

  int get deliveredCount => statusCounts[RepairOrderStatus.delivered] ?? 0;
  int get cancelledCount => statusCounts[RepairOrderStatus.cancelled] ?? 0;

  /// Neither delivered nor cancelled — mirrors [RepairOrderEntity.isActive].
  int get activeRepairOrders =>
      totalRepairOrders - deliveredCount - cancelledCount;

  @override
  List<Object?> get props => [
        totalRepairOrders,
        statusCounts,
        technicianWorkload,
        totalActiveCustomers,
        totalActiveDevices,
        devicesWarrantyActive,
        devicesWarrantyExpired,
        devicesWarrantyVoided,
        devicesWarrantyNotActivated,
        newRepairOrdersInRange,
        rangeFrom,
        rangeTo,
      ];
}
