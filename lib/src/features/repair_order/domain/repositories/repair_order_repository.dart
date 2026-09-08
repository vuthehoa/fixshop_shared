import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/delivery_info.dart';
import '../entities/reception_info.dart';
import '../entities/repair_execution_info.dart';
import '../entities/repair_order_entity.dart';
import '../value_objects/repair_order_filter.dart';

abstract class RepairOrderRepository {
  Future<Either<Failure, RepairOrderEntity>> getRepairOrder(String id);

  Future<Either<Failure, PaginatedResult<RepairOrderEntity>>> getRepairOrders(
    RepairOrderFilter filter, {
    DocumentSnapshot? startAfter,
  });

  /// Fails if the device is archived or already has another active (not
  /// delivered/cancelled) repair order. [actor] stamps the initial
  /// "Created" timeline entry.
  Future<Either<Failure, RepairOrderEntity>> createRepairOrder(
    RepairOrderEntity entity, {
    required UserEntity actor,
  });

  /// Generic field edits (problem description, customer request, internal
  /// note, costs, expected completion date, attachments). Never changes
  /// `currentStatus`.
  Future<Either<Failure, RepairOrderEntity>> updateRepairOrder(
      RepairOrderEntity entity);

  /// `confirmed` → `received`. Sets `receivedAt`/`receivedBy` and stores the
  /// reception checklist.
  Future<Either<Failure, RepairOrderEntity>> receiveDevice(
    String id, {
    required ReceptionInfo reception,
    required UserEntity actor,
  });

  /// Edits the reception checklist without touching `currentStatus` — used
  /// after the initial receive when reception needs to correct/add details.
  Future<Either<Failure, RepairOrderEntity>> updateReceptionInfo(
    String id, {
    required ReceptionInfo reception,
    required UserEntity actor,
  });

  /// Free-text diagnosis update. Logged as its own timeline entry type,
  /// distinct from a generic field edit.
  Future<Either<Failure, RepairOrderEntity>> updateDiagnosis(
    String id, {
    required String diagnosis,
    required UserEntity actor,
  });

  /// Assigns (or reassigns) exactly one technician. Transitions
  /// `received` → `assigned` on the first assignment; reassigning later
  /// only updates `technicianId` and appends to `assignmentHistory`.
  Future<Either<Failure, RepairOrderEntity>> assignTechnician(
    String id, {
    required String technicianId,
    required String technicianName,
    required UserEntity actor,
  });

  /// Generic forward transitions validated against
  /// `RepairOrderStatusTransitionService` — everything except `received`
  /// (see [receiveDevice]), `assigned` (see [assignTechnician]) and
  /// `cancelled` (see [cancelRepairOrder]).
  Future<Either<Failure, RepairOrderEntity>> changeStatus(
    String id, {
    required RepairOrderStatus to,
    required UserEntity actor,
  });

  Future<Either<Failure, RepairOrderEntity>> cancelRepairOrder(
    String id, {
    required UserEntity actor,
    String? reason,
  });

  // ── Sprint 8 — repair execution & testing loop ──────────────────────────

  /// `assigned` → `diagnosing`.
  Future<Either<Failure, RepairOrderEntity>> startDiagnosis(
    String id, {
    required UserEntity actor,
  });

  /// `diagnosing` → `diagnosed`. Also records the diagnosis result (same
  /// field `RepairOrderEntity.diagnosis` used by [updateDiagnosis] — not a
  /// duplicate).
  Future<Either<Failure, RepairOrderEntity>> completeDiagnosis(
    String id, {
    required String diagnosis,
    required UserEntity actor,
  });

  /// `diagnosed` or `waitingParts` → `repairing`. Stamps
  /// `RepairOrderEntity.startedAt` only the first time (never overwritten
  /// afterwards) and sets `repairExecution.workStartedAt` for this attempt.
  Future<Either<Failure, RepairOrderEntity>> startRepair(
    String id, {
    required RepairExecutionInfo execution,
    required UserEntity actor,
  });

  /// Edits `repairExecution` notes without changing `currentStatus`.
  Future<Either<Failure, RepairOrderEntity>> updateRepairExecution(
    String id, {
    required RepairExecutionInfo execution,
    required UserEntity actor,
  });

  /// `repairing` → `testing`. Stamps `repairExecution.workCompletedAt` for
  /// this attempt.
  Future<Either<Failure, RepairOrderEntity>> submitForTesting(
    String id, {
    required UserEntity actor,
  });

  /// `testing` → `completed`. Sets `completedAt`/`completedBy`.
  Future<Either<Failure, RepairOrderEntity>> passTesting(
    String id, {
    required UserEntity actor,
  });

  /// `testing` → `repairing`. The failed-test loop — does NOT touch
  /// `RepairOrderEntity.startedAt`; clears `repairExecution.workCompletedAt`
  /// since work resumes.
  Future<Either<Failure, RepairOrderEntity>> failTesting(
    String id, {
    required UserEntity actor,
    String? notes,
  });

  // ── Sprint 9 — completion, delivery & customer handover ─────────────────

  /// `completed` → `delivered`. Fails unless the order is currently
  /// `completed` and [delivery] identifies a recipient. Sets
  /// `deliveredAt`/`deliveredBy` (the existing Sprint 7 fields — never
  /// duplicated) and stores [delivery] as `deliveryInfo`. Appends to the
  /// existing `delivered` timeline entry type rather than introducing a new
  /// one, since it represents the same business fact.
  Future<Either<Failure, RepairOrderEntity>> deliverRepairOrder(
    String id, {
    required DeliveryInfo delivery,
    required UserEntity actor,
  });
}
