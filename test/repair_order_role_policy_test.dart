import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';

/// Must stay identical to fixshop_cms test/repair_orders_transitions.rules.test.mjs.
void main() {
  const s = RepairOrderStatus.values;
  final edges = <(RepairOrderStatus, RepairOrderStatus)>[
    for (final f in s)
      for (final t in RepairOrderStatusTransitionService.allowedNextStatuses(f))
        (f, t),
  ];
  const reception = {
    'pending>confirmed',
    'confirmed>received',
    'received>assigned',
    'completed>delivered',
    'pending>cancelled',
    'confirmed>cancelled',
    'received>cancelled',
    'assigned>cancelled',
  };
  const tech = {
    'received>assigned',
    'assigned>diagnosing',
    'diagnosing>diagnosed',
    'diagnosed>waitingParts',
    'diagnosed>repairing',
    'waitingParts>repairing',
    'repairing>testing',
    'testing>completed',
    'testing>repairing',
  };

  test('base graph has 22 edges (same list as the rules)', () {
    expect(edges.length, 22);
  });

  for (final role in UserRole.values) {
    test('matrix — ${role.name}', () {
      for (final (f, t) in edges) {
        final key = '${f.name}>${t.name}';
        final expected = switch (role) {
          UserRole.admin || UserRole.manager => true,
          UserRole.reception => reception.contains(key),
          UserRole.technician => tech.contains(key),
          UserRole.customer => false,
        };
        expect(
          RepairOrderRolePolicy.canTransition(role, f, t,
              isAssignedToActor: true, assigningSelf: true),
          expected,
          reason: '${role.name} $key',
        );
      }
    });
  }

  test('technician needs the order assigned to them; self-assign only', () {
    expect(
      RepairOrderRolePolicy.canTransition(UserRole.technician,
          RepairOrderStatus.assigned, RepairOrderStatus.diagnosing),
      isFalse,
    );
    expect(
      RepairOrderRolePolicy.canTransition(UserRole.technician,
          RepairOrderStatus.received, RepairOrderStatus.assigned),
      isFalse,
    );
  });

  test('non-graph edges are never allowed', () {
    expect(
      RepairOrderRolePolicy.canTransition(UserRole.admin,
          RepairOrderStatus.pending, RepairOrderStatus.completed),
      isFalse,
    );
    expect(
      RepairOrderRolePolicy.canTransition(UserRole.admin,
          RepairOrderStatus.delivered, RepairOrderStatus.cancelled),
      isFalse,
    );
  });

  test('create / edit gates', () {
    expect(RepairOrderRolePolicy.canCreate(UserRole.technician), isFalse);
    expect(RepairOrderRolePolicy.canCreate(UserRole.reception), isTrue);
    expect(
      RepairOrderRolePolicy.canEditDetails(
          UserRole.admin, RepairOrderStatus.delivered),
      isFalse,
    );
    expect(
      RepairOrderRolePolicy.canEditTechnicalNotes(
          UserRole.technician, RepairOrderStatus.repairing,
          isAssignedToActor: false),
      isFalse,
    );
  });
}
