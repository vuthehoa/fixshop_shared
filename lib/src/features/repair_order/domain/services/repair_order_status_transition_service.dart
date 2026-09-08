import '../entities/repair_order_entity.dart';

/// Single source of truth for which [RepairOrderStatus] transitions are
/// legal. Every status change — generic, receive, assign, or cancel — must
/// go through [canTransition] before writing. Never hardcode a transition
/// check in a widget or cubit.
abstract final class RepairOrderStatusTransitionService {
  static const Map<RepairOrderStatus, Set<RepairOrderStatus>> _allowed = {
    RepairOrderStatus.pending: {
      RepairOrderStatus.confirmed,
      RepairOrderStatus.cancelled,
    },
    RepairOrderStatus.confirmed: {
      RepairOrderStatus.received,
      RepairOrderStatus.cancelled,
    },
    RepairOrderStatus.received: {
      RepairOrderStatus.assigned,
      RepairOrderStatus.cancelled,
    },
    RepairOrderStatus.assigned: {
      RepairOrderStatus.diagnosing,
      RepairOrderStatus.cancelled,
    },
    RepairOrderStatus.diagnosing: {
      RepairOrderStatus.diagnosed,
      RepairOrderStatus.cancelled,
    },
    RepairOrderStatus.diagnosed: {
      RepairOrderStatus.waitingParts,
      RepairOrderStatus.repairing,
      RepairOrderStatus.cancelled,
    },
    RepairOrderStatus.waitingParts: {
      RepairOrderStatus.repairing,
      RepairOrderStatus.cancelled,
    },
    RepairOrderStatus.repairing: {
      RepairOrderStatus.testing,
      RepairOrderStatus.cancelled,
    },
    RepairOrderStatus.testing: {
      RepairOrderStatus.completed,
      // Sprint 8 — a failed test sends the order back for further repair
      // work. `RepairOrderEntity.startedAt` (the first-ever repair start)
      // is never touched by this loop; only `repairExecution.workStartedAt`
      // (the current attempt) moves.
      RepairOrderStatus.repairing,
      RepairOrderStatus.cancelled,
    },
    RepairOrderStatus.completed: {
      RepairOrderStatus.delivered,
      RepairOrderStatus.cancelled,
    },
    // Terminal — no further transitions.
    RepairOrderStatus.delivered: {},
    RepairOrderStatus.cancelled: {},
  };

  static bool canTransition(RepairOrderStatus from, RepairOrderStatus to) {
    return _allowed[from]?.contains(to) ?? false;
  }

  static Set<RepairOrderStatus> allowedNextStatuses(RepairOrderStatus from) {
    return _allowed[from] ?? const {};
  }

  static bool isTerminal(RepairOrderStatus status) =>
      allowedNextStatuses(status).isEmpty;
}
