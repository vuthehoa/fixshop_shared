import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/paginated_result.dart';
import '../../domain/value_objects/manufacturer_filter.dart';
import '../models/manufacturer_model.dart';

abstract class ManufacturerRemoteDataSource {
  Future<ManufacturerModel> getManufacturer(String id);

  Future<PaginatedResult<ManufacturerModel>> getManufacturers(
    ManufacturerFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<List<ManufacturerModel>> getActiveManufacturers();

  Future<ManufacturerModel> createManufacturer(ManufacturerModel entity);

  Future<ManufacturerModel> updateManufacturer(ManufacturerModel entity);

  Future<void> archiveManufacturer(String id);

  Future<void> restoreManufacturer(String id);
}
