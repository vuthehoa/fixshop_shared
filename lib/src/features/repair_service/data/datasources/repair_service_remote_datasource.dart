import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/paginated_result.dart';
import '../../domain/value_objects/repair_service_filter.dart';
import '../../domain/value_objects/repair_service_write_context.dart';
import '../models/repair_service_model.dart';

abstract class RepairServiceRemoteDataSource {
  Future<RepairServiceModel> getRepairService(String id);

  Future<PaginatedResult<RepairServiceModel>> getRepairServices(
    RepairServiceFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<List<RepairServiceModel>> getActiveRepairServices({String? parentId});

  /// Every write below also writes `catalog_eligibility/{id}` in the SAME
  /// batch/transaction (Firestore Rules require it).
  Future<RepairServiceModel> createRepairService(
    RepairServiceModel entity, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  });

  Future<RepairServiceModel> updateRepairService(
    RepairServiceModel entity, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  });

  Future<void> archiveRepairService(
    String id, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  });

  Future<void> restoreRepairService(
    String id, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  });
}
