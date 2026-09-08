import 'package:flutter_test/flutter_test.dart';

import 'package:fixshop_shared/fixshop_shared.dart';

void main() {
  group('RepairOrderStatusTransitionService — Sprint 9 delivery rules', () {
    test('completed -> delivered is valid', () {
      expect(
        RepairOrderStatusTransitionService.canTransition(
          RepairOrderStatus.completed,
          RepairOrderStatus.delivered,
        ),
        isTrue,
      );
    });

    test('delivered is terminal — every outgoing transition is invalid', () {
      for (final target in RepairOrderStatus.values) {
        expect(
          RepairOrderStatusTransitionService.canTransition(
              RepairOrderStatus.delivered, target),
          isFalse,
          reason: 'delivered -> ${target.name} must be invalid',
        );
      }
      expect(
        RepairOrderStatusTransitionService.allowedNextStatuses(
            RepairOrderStatus.delivered),
        isEmpty,
      );
      expect(
          RepairOrderStatusTransitionService.isTerminal(
              RepairOrderStatus.delivered),
          isTrue);
    });

    test('delivery is blocked from every non-completed status', () {
      final nonCompleted = RepairOrderStatus.values
          .where((s) => s != RepairOrderStatus.completed)
          .toList();

      for (final from in nonCompleted) {
        expect(
          RepairOrderStatusTransitionService.canTransition(
              from, RepairOrderStatus.delivered),
          isFalse,
          reason: '${from.name} -> delivered must be invalid',
        );
      }
    });

    test(
        'testing -> repairing (failed-test loop) remains valid — Sprint 8 regression',
        () {
      expect(
        RepairOrderStatusTransitionService.canTransition(
          RepairOrderStatus.testing,
          RepairOrderStatus.repairing,
        ),
        isTrue,
      );
    });

    test('cancelled is terminal', () {
      expect(
          RepairOrderStatusTransitionService.isTerminal(
              RepairOrderStatus.cancelled),
          isTrue);
    });
  });

  group('RepairOrderStatusTransitionService — Sprint 10 full transition matrix',
      () {
    // The authoritative map, mirrored here so a change to the production map
    // fails this test loudly rather than silently drifting.
    const expected = <RepairOrderStatus, Set<RepairOrderStatus>>{
      RepairOrderStatus.pending: {
        RepairOrderStatus.confirmed,
        RepairOrderStatus.cancelled
      },
      RepairOrderStatus.confirmed: {
        RepairOrderStatus.received,
        RepairOrderStatus.cancelled
      },
      RepairOrderStatus.received: {
        RepairOrderStatus.assigned,
        RepairOrderStatus.cancelled
      },
      RepairOrderStatus.assigned: {
        RepairOrderStatus.diagnosing,
        RepairOrderStatus.cancelled
      },
      RepairOrderStatus.diagnosing: {
        RepairOrderStatus.diagnosed,
        RepairOrderStatus.cancelled
      },
      RepairOrderStatus.diagnosed: {
        RepairOrderStatus.waitingParts,
        RepairOrderStatus.repairing,
        RepairOrderStatus.cancelled,
      },
      RepairOrderStatus.waitingParts: {
        RepairOrderStatus.repairing,
        RepairOrderStatus.cancelled
      },
      RepairOrderStatus.repairing: {
        RepairOrderStatus.testing,
        RepairOrderStatus.cancelled
      },
      RepairOrderStatus.testing: {
        RepairOrderStatus.completed,
        RepairOrderStatus.repairing,
        RepairOrderStatus.cancelled,
      },
      RepairOrderStatus.completed: {
        RepairOrderStatus.delivered,
        RepairOrderStatus.cancelled
      },
      RepairOrderStatus.delivered: {},
      RepairOrderStatus.cancelled: {},
    };

    for (final from in RepairOrderStatus.values) {
      for (final to in RepairOrderStatus.values) {
        final shouldAllow = expected[from]!.contains(to);
        test(
          '${from.name} -> ${to.name} is ${shouldAllow ? "allowed" : "rejected"}',
          () {
            expect(
              RepairOrderStatusTransitionService.canTransition(from, to),
              shouldAllow,
            );
          },
        );
      }
    }

    test('cancelled is terminal — every outgoing transition is invalid', () {
      for (final target in RepairOrderStatus.values) {
        expect(
          RepairOrderStatusTransitionService.canTransition(
              RepairOrderStatus.cancelled, target),
          isFalse,
          reason: 'cancelled -> ${target.name} must be invalid',
        );
      }
      expect(
        RepairOrderStatusTransitionService.allowedNextStatuses(
            RepairOrderStatus.cancelled),
        isEmpty,
      );
    });

    test('every non-terminal status can reach cancelled', () {
      for (final from in RepairOrderStatus.values) {
        if (RepairOrderStatusTransitionService.isTerminal(from)) continue;
        expect(
          RepairOrderStatusTransitionService.canTransition(
              from, RepairOrderStatus.cancelled),
          isTrue,
          reason:
              '${from.name} -> cancelled must be valid (cancellable from every active stage)',
        );
      }
    });
  });
}
