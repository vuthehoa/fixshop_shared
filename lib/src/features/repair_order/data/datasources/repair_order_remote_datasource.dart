import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/paginated_result.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/delivery_info.dart';
import '../../domain/entities/reception_info.dart';
import '../../domain/entities/repair_execution_info.dart';
import '../../domain/entities/repair_order_entity.dart';
import '../../domain/value_objects/repair_order_filter.dart';
import '../models/repair_order_model.dart';

abstract class RepairOrderRemoteDataSource {
  Future<RepairOrderModel> getRepairOrder(String id);

  Future<PaginatedResult<RepairOrderModel>> getRepairOrders(
    RepairOrderFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<RepairOrderModel> createRepairOrder(RepairOrderModel entity,
      {required UserEntity actor});

  Future<RepairOrderModel> updateRepairOrder(RepairOrderModel entity);

  Future<RepairOrderModel> receiveDevice(
    String id, {
    required ReceptionInfo reception,
    required UserEntity actor,
  });

  Future<RepairOrderModel> updateReceptionInfo(
    String id, {
    required ReceptionInfo reception,
    required UserEntity actor,
  });

  Future<RepairOrderModel> updateDiagnosis(
    String id, {
    required String diagnosis,
    required UserEntity actor,
  });

  Future<RepairOrderModel> assignTechnician(
    String id, {
    required String technicianId,
    required String technicianName,
    required UserEntity actor,
  });

  Future<RepairOrderModel> changeStatus(
    String id, {
    required RepairOrderStatus to,
    required UserEntity actor,
  });

  Future<RepairOrderModel> cancelRepairOrder(
    String id, {
    required UserEntity actor,
    String? reason,
  });

  // ── Sprint 8 — repair execution & testing loop ──────────────────────────

  Future<RepairOrderModel> startDiagnosis(String id,
      {required UserEntity actor});

  Future<RepairOrderModel> completeDiagnosis(
    String id, {
    required String diagnosis,
    required UserEntity actor,
  });

  Future<RepairOrderModel> startRepair(
    String id, {
    required RepairExecutionInfo execution,
    required UserEntity actor,
  });

  Future<RepairOrderModel> updateRepairExecution(
    String id, {
    required RepairExecutionInfo execution,
    required UserEntity actor,
  });

  Future<RepairOrderModel> submitForTesting(String id,
      {required UserEntity actor});

  Future<RepairOrderModel> passTesting(String id, {required UserEntity actor});

  Future<RepairOrderModel> failTesting(
    String id, {
    required UserEntity actor,
    String? notes,
  });

  // ── Sprint 9 — completion, delivery & customer handover ─────────────────

  Future<RepairOrderModel> deliverRepairOrder(
    String id, {
    required DeliveryInfo delivery,
    required UserEntity actor,
  });
}
