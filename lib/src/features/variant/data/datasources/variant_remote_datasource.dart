import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/paginated_result.dart';
import '../../domain/value_objects/variant_filter.dart';
import '../models/variant_model.dart';

abstract class VariantRemoteDataSource {
  Future<VariantModel> getVariant(String id);

  Future<PaginatedResult<VariantModel>> getVariants(
    VariantFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<List<VariantModel>> getActiveVariants({String? parentId});

  Future<VariantModel> createVariant(VariantModel entity);

  Future<VariantModel> updateVariant(VariantModel entity);

  Future<void> archiveVariant(String id);

  Future<void> restoreVariant(String id);
}
