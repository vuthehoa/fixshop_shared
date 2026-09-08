import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/paginated_result.dart';
import '../../domain/value_objects/repair_service_filter.dart';
import '../models/repair_service_model.dart';

abstract class RepairServiceRemoteDataSource {
  Future<RepairServiceModel> getRepairService(String id);

  Future<PaginatedResult<RepairServiceModel>> getRepairServices(
    RepairServiceFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<List<RepairServiceModel>> getActiveRepairServices({String? parentId});

  Future<RepairServiceModel> createRepairService(RepairServiceModel entity);

  Future<RepairServiceModel> updateRepairService(RepairServiceModel entity);

  Future<void> archiveRepairService(String id);

  Future<void> restoreRepairService(String id);
}
