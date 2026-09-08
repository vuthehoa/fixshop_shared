import '../../../repair_order/domain/entities/repair_order_entity.dart';
import '../entities/dashboard_summary.dart';

/// Pure, Firestore-free transformation of already-fetched repair orders into
/// dashboard read-model shapes. Kept separate from
/// `FirebaseDashboardRemoteDataSource` specifically so it can be unit tested
/// without a Firestore instance — mirrors why
/// `RepairOrderStatusTransitionService` is its own pure service.
abstract final class DashboardAggregator {
  /// Counts [orders] by status. Every [RepairOrderStatus] value is present
  /// in the result (defaulting to 0) so the UI never has to special-case a
  /// missing key.
  static Map<RepairOrderStatus, int> countByStatus(
      List<RepairOrderEntity> orders) {
    final counts = {for (final s in RepairOrderStatus.values) s: 0};
    for (final order in orders) {
      counts[order.currentStatus] = (counts[order.currentStatus] ?? 0) + 1;
    }
    return counts;
  }

  /// Groups [activeOrders] (expected to already exclude delivered/cancelled)
  /// by technician. Orders with no assigned technician are excluded — there
  /// is nothing to attribute workload to yet.
  static List<TechnicianWorkload> technicianWorkloadFrom(
    List<RepairOrderEntity> activeOrders,
  ) {
    final byTechnician = <String, List<RepairOrderEntity>>{};
    for (final order in activeOrders) {
      final id = order.technicianId;
      if (id == null) continue;
      byTechnician.putIfAbsent(id, () => []).add(order);
    }

    final result = byTechnician.entries.map((entry) {
      final orders = entry.value;
      return TechnicianWorkload(
        technicianId: entry.key,
        technicianName: orders.first.technicianName ?? '—',
        activeCount: orders.length,
        repairingCount: orders
            .where((o) => o.currentStatus == RepairOrderStatus.repairing)
            .length,
        testingCount: orders
            .where((o) => o.currentStatus == RepairOrderStatus.testing)
            .length,
        completedNotDeliveredCount: orders
            .where((o) => o.currentStatus == RepairOrderStatus.completed)
            .length,
      );
    }).toList();

    result.sort((a, b) => b.activeCount.compareTo(a.activeCount));
    return result;
  }
}
