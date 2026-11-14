import '../../../auth/domain/entities/user_entity.dart';
import '../entities/repair_order_entity.dart';
import 'repair_order_status_transition_service.dart';

/// Role-based layer on top of [RepairOrderStatusTransitionService].
///
/// This is the EXACT mirror of `firestore.rules` (fixshop_cms,
/// `roTransitionAllowed` / `roSameStatusEdit`). The rules are the authority —
/// this class only exists so the CMS never offers an action the server would
/// reject. Change both together (rules tests:
/// `test/repair_orders_transitions.rules.test.mjs`).
///
/// | role        | allowed transitions (from → to)                                   |
/// |-------------|-------------------------------------------------------------------|
/// | admin       | every edge of the base workflow graph                             |
/// | manager     | every edge of the base workflow graph                             |
/// | reception   | pending→confirmed, confirmed→received, received→assigned,          |
/// |             | completed→delivered, cancel from pending/confirmed/received/assigned|
/// | technician  | received→assigned (self only); on orders assigned to them:        |
/// |             | assigned→diagnosing, diagnosing→diagnosed, diagnosed→waitingParts, |
/// |             | diagnosed→repairing, waitingParts→repairing, repairing→testing,    |
/// |             | testing→completed, testing→repairing                               |
/// | customer    | none                                                              |
abstract final class RepairOrderRolePolicy {
  static const _reception = <(RepairOrderStatus, RepairOrderStatus)>{
    (RepairOrderStatus.pending, RepairOrderStatus.confirmed),
    (RepairOrderStatus.confirmed, RepairOrderStatus.received),
    (RepairOrderStatus.received, RepairOrderStatus.assigned),
    (RepairOrderStatus.completed, RepairOrderStatus.delivered),
    (RepairOrderStatus.pending, RepairOrderStatus.cancelled),
    (RepairOrderStatus.confirmed, RepairOrderStatus.cancelled),
    (RepairOrderStatus.received, RepairOrderStatus.cancelled),
    (RepairOrderStatus.assigned, RepairOrderStatus.cancelled),
  };

  /// Technician edges that require the order to be assigned to the caller.
  static const _technicianAssigned = <(RepairOrderStatus, RepairOrderStatus)>{
    (RepairOrderStatus.assigned, RepairOrderStatus.diagnosing),
    (RepairOrderStatus.diagnosing, RepairOrderStatus.diagnosed),
    (RepairOrderStatus.diagnosed, RepairOrderStatus.waitingParts),
    (RepairOrderStatus.diagnosed, RepairOrderStatus.repairing),
    (RepairOrderStatus.waitingParts, RepairOrderStatus.repairing),
    (RepairOrderStatus.repairing, RepairOrderStatus.testing),
    (RepairOrderStatus.testing, RepairOrderStatus.completed),
    (RepairOrderStatus.testing, RepairOrderStatus.repairing),
  };

  /// [isAssignedToActor]: the order's current `technicianId == actor uid`.
  /// [assigningSelf]: for received→assigned, the new technician is the actor.
  static bool canTransition(
    UserRole role,
    RepairOrderStatus from,
    RepairOrderStatus to, {
    bool isAssignedToActor = false,
    bool assigningSelf = false,
  }) {
    if (!RepairOrderStatusTransitionService.canTransition(from, to)) {
      return false;
    }
    return switch (role) {
      UserRole.admin || UserRole.manager => true,
      UserRole.reception => _reception.contains((from, to)),
      UserRole.technician => (from == RepairOrderStatus.received &&
              to == RepairOrderStatus.assigned &&
              assigningSelf) ||
          (_technicianAssigned.contains((from, to)) && isAssignedToActor),
      UserRole.customer => false,
    };
  }

  /// Transitions the actor may perform on [order] right now.
  static Set<RepairOrderStatus> allowedNextStatuses(
    UserRole role,
    RepairOrderEntity order, {
    required String actorId,
  }) {
    final assigned =
        order.technicianId != null && order.technicianId == actorId;
    return RepairOrderStatusTransitionService.allowedNextStatuses(
      order.currentStatus,
    )
        .where(
          (to) => canTransition(
            role,
            order.currentStatus,
            to,
            isAssignedToActor: assigned,
            // A technician can always pick themselves in the assign dialog.
            assigningSelf: role == UserRole.technician,
          ),
        )
        .toSet();
  }

  /// Walk-in intake (`isValidStaffRepairOrderCreate`).
  static bool canCreate(UserRole role) =>
      role == UserRole.admin ||
      role == UserRole.manager ||
      role == UserRole.reception;

  /// Intake/detail edits (code once, description, notes, costs, reception).
  static bool canEditDetails(UserRole role, RepairOrderStatus status) =>
      canCreate(role) && !RepairOrderStatusTransitionService.isTerminal(status);

  /// Diagnosis / repair-execution notes without a status change.
  static bool canEditTechnicalNotes(
    UserRole role,
    RepairOrderStatus status, {
    required bool isAssignedToActor,
  }) {
    if (RepairOrderStatusTransitionService.isTerminal(status)) return false;
    return role == UserRole.admin ||
        role == UserRole.manager ||
        (role == UserRole.technician && isAssignedToActor);
  }

  /// (Re)assign without a status change. A technician may only take the
  /// order themselves ([onlySelf] == true for them).
  static bool canAssign(UserRole role, RepairOrderStatus status) {
    if (status == RepairOrderStatus.cancelled ||
        status == RepairOrderStatus.delivered) {
      return false;
    }
    return role.isCmsUser;
  }

  static bool assignOnlySelf(UserRole role) => role == UserRole.technician;
}
