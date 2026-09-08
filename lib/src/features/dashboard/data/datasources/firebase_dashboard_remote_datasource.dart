import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../device/data/models/device_model.dart';
import '../../../device/domain/entities/device_entity.dart';
import '../../../repair_order/data/models/repair_order_model.dart';
import '../../../repair_order/domain/entities/repair_order_entity.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/services/dashboard_aggregator.dart';
import 'dashboard_remote_datasource.dart';

class FirebaseDashboardRemoteDataSource implements DashboardRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseDashboardRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _repairOrders =>
      _firestore.collection(FirestoreConstants.repairOrders);

  CollectionReference<Map<String, dynamic>> get _customers =>
      _firestore.collection(FirestoreConstants.customers);

  CollectionReference<Map<String, dynamic>> get _devices =>
      _firestore.collection(FirestoreConstants.devices);

  @override
  Future<DashboardSummary> getDashboardSummary({
    DateTime? createdFrom,
    DateTime? createdTo,
  }) async {
    // Terminal-state counts are cheap Firestore count() aggregations — no
    // document bodies are read. The remaining (non-terminal) statuses are
    // small enough as a working set to fetch in full, which is also what
    // technician workload needs to group by.
    final totalCountFuture = _repairOrders.count().get();
    final deliveredCountFuture = _repairOrders
        .where('currentStatus', isEqualTo: RepairOrderStatus.delivered.name)
        .count()
        .get();
    final cancelledCountFuture = _repairOrders
        .where('currentStatus', isEqualTo: RepairOrderStatus.cancelled.name)
        .count()
        .get();
    final activeOrdersFuture =
        _repairOrders.where('currentStatus', whereNotIn: [
      RepairOrderStatus.delivered.name,
      RepairOrderStatus.cancelled.name,
    ]).get();
    final activeCustomersFuture =
        _customers.where('status', isEqualTo: 'active').count().get();
    final activeDevicesFuture = _devices
        .where('status', isNotEqualTo: DeviceStatus.archived.name)
        .count()
        .get();
    // Firestore's `isNotEqualTo` also matches "field exists and != value",
    // so this is exactly "devices whose warranty was ever activated" — a
    // working set expected to be far smaller than the full device catalog.
    final warrantedDevicesFuture =
        _devices.where('warrantyActivatedAt', isNotEqualTo: null).get();

    final results = await Future.wait([
      totalCountFuture,
      deliveredCountFuture,
      cancelledCountFuture,
      activeOrdersFuture,
      activeCustomersFuture,
      activeDevicesFuture,
      warrantedDevicesFuture,
    ]);

    final totalCount = (results[0] as AggregateQuerySnapshot).count ?? 0;
    final deliveredCount = (results[1] as AggregateQuerySnapshot).count ?? 0;
    final cancelledCount = (results[2] as AggregateQuerySnapshot).count ?? 0;
    final activeOrders = (results[3] as QuerySnapshot<Map<String, dynamic>>)
        .docs
        .map(RepairOrderModel.fromFirestore)
        .toList();
    final activeCustomersCount =
        (results[4] as AggregateQuerySnapshot).count ?? 0;
    final activeDevicesCount =
        (results[5] as AggregateQuerySnapshot).count ?? 0;
    final warrantedDevices = (results[6] as QuerySnapshot<Map<String, dynamic>>)
        .docs
        .map(DeviceModel.fromFirestore)
        .toList();

    final statusCounts = DashboardAggregator.countByStatus(activeOrders);
    statusCounts[RepairOrderStatus.delivered] = deliveredCount;
    statusCounts[RepairOrderStatus.cancelled] = cancelledCount;

    var warrantyActive = 0;
    var warrantyExpired = 0;
    var warrantyVoided = 0;
    for (final device in warrantedDevices) {
      switch (device.warrantyStatus) {
        case WarrantyStatus.active:
          warrantyActive++;
        case WarrantyStatus.expired:
          warrantyExpired++;
        case WarrantyStatus.voided:
          warrantyVoided++;
        case WarrantyStatus.notActivated:
          break; // excluded by the warrantyActivatedAt != null query itself.
      }
    }
    final warrantyNotActivated = activeDevicesCount - warrantedDevices.length;

    int? newOrdersInRange;
    if (createdFrom != null && createdTo != null) {
      final rangeSnapshot = await _repairOrders
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(createdFrom))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(createdTo))
          .count()
          .get();
      newOrdersInRange = rangeSnapshot.count ?? 0;
    }

    return DashboardSummary(
      totalRepairOrders: totalCount,
      statusCounts: statusCounts,
      technicianWorkload:
          DashboardAggregator.technicianWorkloadFrom(activeOrders),
      totalActiveCustomers: activeCustomersCount,
      totalActiveDevices: activeDevicesCount,
      devicesWarrantyActive: warrantyActive,
      devicesWarrantyExpired: warrantyExpired,
      devicesWarrantyVoided: warrantyVoided,
      devicesWarrantyNotActivated:
          warrantyNotActivated < 0 ? 0 : warrantyNotActivated,
      newRepairOrdersInRange: newOrdersInRange,
      rangeFrom: createdFrom,
      rangeTo: createdTo,
    );
  }
}
