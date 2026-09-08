import 'package:flutter_test/flutter_test.dart';

import 'package:fixshop_shared/fixshop_shared.dart';

RepairOrderEntity _order({
  required String id,
  required RepairOrderStatus status,
  String? technicianId,
  String? technicianName,
}) {
  final now = DateTime(2026, 1, 1);
  return RepairOrderEntity(
    id: id,
    repairOrderCode: 'RO-$id',
    customerId: 'customer-1',
    customerName: 'Nguyen Van A',
    customerPhone: '0900000000',
    deviceId: 'device-1',
    deviceCode: 'DV-001',
    deviceName: 'iPhone 15 Pro Max',
    serialNumber: 'SN-001',
    manufacturerId: 'manufacturer-1',
    manufacturerName: 'Apple',
    createdBy: 'user-0',
    currentStatus: status,
    technicianId: technicianId,
    technicianName: technicianName,
    problemDescription: 'Màn hình vỡ',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('DashboardAggregator.countByStatus', () {
    test('counts every status, defaulting missing ones to 0', () {
      final orders = [
        _order(id: '1', status: RepairOrderStatus.pending),
        _order(id: '2', status: RepairOrderStatus.pending),
        _order(id: '3', status: RepairOrderStatus.repairing),
        _order(id: '4', status: RepairOrderStatus.testing),
      ];

      final counts = DashboardAggregator.countByStatus(orders);

      expect(counts[RepairOrderStatus.pending], 2);
      expect(counts[RepairOrderStatus.repairing], 1);
      expect(counts[RepairOrderStatus.testing], 1);
      expect(counts[RepairOrderStatus.confirmed], 0);
      expect(counts[RepairOrderStatus.delivered], 0);
      expect(counts.length, RepairOrderStatus.values.length);
    });

    test('empty dataset — every status is 0', () {
      final counts = DashboardAggregator.countByStatus(const []);
      for (final status in RepairOrderStatus.values) {
        expect(counts[status], 0);
      }
    });
  });

  group('DashboardAggregator.technicianWorkloadFrom', () {
    test('groups by technician and buckets repairing/testing/completed', () {
      final orders = [
        _order(
          id: '1',
          status: RepairOrderStatus.repairing,
          technicianId: 'tech-1',
          technicianName: 'Le Van B',
        ),
        _order(
          id: '2',
          status: RepairOrderStatus.testing,
          technicianId: 'tech-1',
          technicianName: 'Le Van B',
        ),
        _order(
          id: '3',
          status: RepairOrderStatus.completed,
          technicianId: 'tech-2',
          technicianName: 'Tran Van C',
        ),
        // No technician assigned yet — excluded from workload entirely.
        _order(id: '4', status: RepairOrderStatus.received),
      ];

      final workload = DashboardAggregator.technicianWorkloadFrom(orders);

      expect(workload.length, 2);
      final tech1 = workload.firstWhere((w) => w.technicianId == 'tech-1');
      expect(tech1.activeCount, 2);
      expect(tech1.repairingCount, 1);
      expect(tech1.testingCount, 1);
      expect(tech1.completedNotDeliveredCount, 0);

      final tech2 = workload.firstWhere((w) => w.technicianId == 'tech-2');
      expect(tech2.activeCount, 1);
      expect(tech2.completedNotDeliveredCount, 1);
    });

    test('empty dataset — no workload entries', () {
      expect(DashboardAggregator.technicianWorkloadFrom(const []), isEmpty);
    });

    test('sorted by active workload descending', () {
      final orders = [
        _order(
          id: '1',
          status: RepairOrderStatus.repairing,
          technicianId: 'tech-low',
          technicianName: 'Low',
        ),
        _order(
          id: '2',
          status: RepairOrderStatus.repairing,
          technicianId: 'tech-high',
          technicianName: 'High',
        ),
        _order(
          id: '3',
          status: RepairOrderStatus.testing,
          technicianId: 'tech-high',
          technicianName: 'High',
        ),
      ];

      final workload = DashboardAggregator.technicianWorkloadFrom(orders);

      expect(workload.first.technicianId, 'tech-high');
      expect(workload.first.activeCount, 2);
    });
  });

  group('DashboardSummary — derived getters', () {
    test('activeRepairOrders excludes delivered and cancelled', () {
      const summary = DashboardSummary(
        totalRepairOrders: 10,
        statusCounts: {
          RepairOrderStatus.pending: 3,
          RepairOrderStatus.repairing: 4,
          RepairOrderStatus.delivered: 2,
          RepairOrderStatus.cancelled: 1,
        },
        technicianWorkload: [],
        totalActiveCustomers: 0,
        totalActiveDevices: 0,
        devicesWarrantyActive: 0,
        devicesWarrantyExpired: 0,
        devicesWarrantyVoided: 0,
        devicesWarrantyNotActivated: 0,
      );

      expect(summary.deliveredCount, 2);
      expect(summary.cancelledCount, 1);
      expect(summary.activeRepairOrders, 7);
    });
  });
}
